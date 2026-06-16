import base64
import json
import os
import socket
import subprocess
import time
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WEB_DIR = ROOT / "build" / "web"
OUT_DIR = ROOT / "presentation_assets" / "screenshots"
HTTP_PORT = 8765
DEBUG_PORT = 9224
WIDTH = 390
HEIGHT = 844


class DevToolsSocket:
    def __init__(self, ws_url: str):
        if not ws_url.startswith("ws://"):
            raise ValueError("Only ws:// URLs are supported")
        without_scheme = ws_url[len("ws://") :]
        host_port, path = without_scheme.split("/", 1)
        if ":" in host_port:
            host, port = host_port.split(":", 1)
            port = int(port)
        else:
            host, port = host_port, 80
        self.host = host
        self.path = "/" + path
        self.sock = socket.create_connection((host, port), timeout=10)
        self._connect()
        self.next_id = 1

    def _connect(self):
        key = base64.b64encode(os.urandom(16)).decode("ascii")
        request = (
            f"GET {self.path} HTTP/1.1\r\n"
            f"Host: {self.host}\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            "Sec-WebSocket-Version: 13\r\n\r\n"
        )
        self.sock.sendall(request.encode("ascii"))
        response = b""
        while b"\r\n\r\n" not in response:
            response += self.sock.recv(4096)
        if b" 101 " not in response.split(b"\r\n", 1)[0]:
            raise RuntimeError(response.decode("latin1", errors="replace"))

    def _send_frame(self, payload: bytes):
        header = bytearray([0x81])
        length = len(payload)
        if length < 126:
            header.append(0x80 | length)
        elif length < 65536:
            header.append(0x80 | 126)
            header.extend(length.to_bytes(2, "big"))
        else:
            header.append(0x80 | 127)
            header.extend(length.to_bytes(8, "big"))
        mask = os.urandom(4)
        masked = bytes(payload[i] ^ mask[i % 4] for i in range(length))
        self.sock.sendall(bytes(header) + mask + masked)

    def _read_exact(self, n: int) -> bytes:
        data = b""
        while len(data) < n:
            chunk = self.sock.recv(n - len(data))
            if not chunk:
                raise RuntimeError("WebSocket closed")
            data += chunk
        return data

    def _recv_frame(self):
        first, second = self._read_exact(2)
        opcode = first & 0x0F
        masked = bool(second & 0x80)
        length = second & 0x7F
        if length == 126:
            length = int.from_bytes(self._read_exact(2), "big")
        elif length == 127:
            length = int.from_bytes(self._read_exact(8), "big")
        mask = self._read_exact(4) if masked else b""
        payload = self._read_exact(length)
        if masked:
            payload = bytes(payload[i] ^ mask[i % 4] for i in range(length))
        return opcode, payload

    def send(self, method: str, params=None):
        msg_id = self.next_id
        self.next_id += 1
        message = {"id": msg_id, "method": method}
        if params is not None:
            message["params"] = params
        self._send_frame(json.dumps(message).encode("utf-8"))
        return msg_id

    def call(self, method: str, params=None, timeout=15):
        msg_id = self.send(method, params)
        deadline = time.time() + timeout
        while time.time() < deadline:
            opcode, payload = self._recv_frame()
            if opcode == 8:
                raise RuntimeError("WebSocket closed by browser")
            if opcode == 9:
                continue
            if opcode != 1:
                continue
            data = json.loads(payload.decode("utf-8"))
            if data.get("id") == msg_id:
                if "error" in data:
                    raise RuntimeError(data["error"])
                return data.get("result", {})
        raise TimeoutError(method)

    def close(self):
        try:
            self.sock.close()
        except OSError:
            pass


def wait_for_json(url: str, timeout=15):
    deadline = time.time() + timeout
    last_error = None
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(url, timeout=2) as response:
                return json.loads(response.read().decode("utf-8"))
        except Exception as exc:
            last_error = exc
            time.sleep(0.25)
    raise RuntimeError(f"Timed out waiting for {url}: {last_error}")


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    server = subprocess.Popen(
        [
            "python",
            "-m",
            "http.server",
            str(HTTP_PORT),
            "--bind",
            "127.0.0.1",
            "--directory",
            str(WEB_DIR),
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    env_chrome = os.environ.get("CHROME_PATH", "").strip()
    chrome_path = Path(env_chrome) if env_chrome else Path()
    if not env_chrome or not chrome_path.exists():
        chrome_path = Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe")
    if not chrome_path.exists():
        chrome_path = Path(r"C:\Program Files\Microsoft\Edge\Application\msedge.exe")

    profile = ROOT / "presentation_assets" / "chrome-profile"
    profile.mkdir(parents=True, exist_ok=True)
    url = f"http://127.0.0.1:{HTTP_PORT}/"
    chrome = subprocess.Popen(
        [
            str(chrome_path),
            "--headless=new",
            f"--remote-debugging-port={DEBUG_PORT}",
            f"--user-data-dir={profile}",
            f"--window-size={WIDTH},{HEIGHT}",
            "--disable-gpu",
            "--no-first-run",
            "--disable-dev-shm-usage",
            "--hide-scrollbars",
            url,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    client = None
    try:
        wait_for_json(f"http://127.0.0.1:{DEBUG_PORT}/json/version")
        pages = wait_for_json(f"http://127.0.0.1:{DEBUG_PORT}/json/list")
        page = next((p for p in pages if p.get("type") == "page"), pages[0])
        client = DevToolsSocket(page["webSocketDebuggerUrl"])

        client.call("Page.enable")
        client.call(
            "Emulation.setDeviceMetricsOverride",
            {
                "width": WIDTH,
                "height": HEIGHT,
                "deviceScaleFactor": 1,
                "mobile": True,
                "screenOrientation": {"type": "portraitPrimary", "angle": 0},
            },
        )
        client.call("Page.navigate", {"url": url})
        time.sleep(8)

        tabs = [
            ("01_carte", 39),
            ("02_transport", 117),
            ("03_securite", 195),
            ("04_profil", 273),
            ("05_boutique", 351),
        ]

        for name, x in tabs:
            client.call(
                "Input.dispatchMouseEvent",
                {"type": "mousePressed", "x": x, "y": 805, "button": "left", "clickCount": 1},
            )
            client.call(
                "Input.dispatchMouseEvent",
                {"type": "mouseReleased", "x": x, "y": 805, "button": "left", "clickCount": 1},
            )
            time.sleep(4 if name in {"03_securite", "04_profil"} else 2)
            screenshot = client.call(
                "Page.captureScreenshot",
                {"format": "png", "fromSurface": True, "captureBeyondViewport": False},
            )
            (OUT_DIR / f"{name}.png").write_bytes(base64.b64decode(screenshot["data"]))
            print(OUT_DIR / f"{name}.png")
    finally:
        if client:
            client.close()
        chrome.terminate()
        server.terminate()
        try:
            chrome.wait(timeout=5)
        except subprocess.TimeoutExpired:
            chrome.kill()
        try:
            server.wait(timeout=5)
        except subprocess.TimeoutExpired:
            server.kill()


if __name__ == "__main__":
    main()
