from __future__ import annotations

from pathlib import Path

import fitz


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "Rapport_EcoSafe.pdf"
ASSETS = ROOT / "presentation_assets" / "screenshots"
ICON = ROOT / "web" / "icons" / "Icon-512.png"
PHONE_MAP = ROOT / "android_phone_screen.png"
PHONE_TRANSPORT = ROOT / "android_phone_search.png"

FONT = Path(r"C:\Windows\Fonts\segoeui.ttf")
FONT_BOLD = Path(r"C:\Windows\Fonts\segoeuib.ttf")

PAGE_W, PAGE_H = fitz.paper_size("a4")
MARGIN = 42

GREEN = (0.11, 0.70, 0.45)
GREEN_DARK = (0.04, 0.43, 0.27)
GREEN_SOFT = (0.91, 0.97, 0.94)
BLUE = (0.16, 0.45, 0.95)
BLUE_SOFT = (0.92, 0.95, 1.00)
ORANGE = (0.95, 0.55, 0.13)
ORANGE_SOFT = (1.00, 0.95, 0.87)
RED = (0.84, 0.25, 0.28)
RED_SOFT = (1.00, 0.92, 0.92)
INK = (0.08, 0.12, 0.10)
TEXT = (0.22, 0.27, 0.24)
MUTED = (0.39, 0.45, 0.42)
LINE = (0.84, 0.88, 0.86)
PAPER = (0.97, 0.98, 0.97)
WHITE = (1, 1, 1)


class Report:
    def __init__(self) -> None:
        self.doc = fitz.open()
        self.page_no = 0

    def new_page(self, section: str, title: str, subtitle: str = "") -> fitz.Page:
        page = self.doc.new_page(width=PAGE_W, height=PAGE_H)
        self.page_no += 1
        self._fonts(page)
        page.draw_rect(page.rect, fill=PAPER, color=PAPER)
        page.draw_rect(fitz.Rect(0, 0, 12, PAGE_H), fill=GREEN, color=GREEN)
        self.text(page, (MARGIN, 30, 540, 49), section.upper(), 7.5, GREEN_DARK, bold=True)
        self.text(page, (MARGIN, 49, 548, 84), title, 22, INK, bold=True)
        if subtitle:
            self.text(page, (MARGIN, 85, 548, 112), subtitle, 9.5, MUTED)
        page.draw_line((MARGIN, 119), (PAGE_W - MARGIN, 119), color=LINE, width=0.8)
        self.footer(page)
        return page

    def _fonts(self, page: fitz.Page) -> None:
        page.insert_font(fontname="EcoRegular", fontfile=str(FONT))
        page.insert_font(fontname="EcoBold", fontfile=str(FONT_BOLD))

    def text(
        self,
        page: fitz.Page,
        rect,
        value: str,
        size: float = 10,
        color=TEXT,
        bold: bool = False,
        align: int = fitz.TEXT_ALIGN_LEFT,
        lineheight: float = 1.22,
    ) -> float:
        return page.insert_textbox(
            fitz.Rect(rect),
            value,
            fontname="EcoBold" if bold else "EcoRegular",
            fontsize=size,
            color=color,
            align=align,
            lineheight=lineheight,
        )

    def footer(self, page: fitz.Page) -> None:
        page.draw_line((MARGIN, 807), (PAGE_W - MARGIN, 807), color=LINE, width=0.6)
        self.text(page, (MARGIN, 813, 300, 830), "ECOSAFE  |  RAPPORT DE PROJET", 7, MUTED, bold=True)
        self.text(page, (480, 813, 552, 830), f"{self.page_no:02d}", 8, GREEN_DARK, bold=True, align=fitz.TEXT_ALIGN_RIGHT)

    def box(self, page: fitz.Page, rect, fill=WHITE, border=LINE, width=0.7) -> fitz.Rect:
        r = fitz.Rect(rect)
        page.draw_rect(r, color=border, fill=fill, width=width)
        return r

    def pill(self, page: fitz.Page, x: float, y: float, w: float, label: str, fill=GREEN_SOFT, color=GREEN_DARK) -> None:
        self.box(page, (x, y, x + w, y + 22), fill=fill, border=fill)
        self.text(page, (x + 6, y + 5, x + w - 6, y + 19), label, 7.5, color, bold=True, align=fitz.TEXT_ALIGN_CENTER)

    def heading(self, page: fitz.Page, y: float, title: str, number: str | None = None, color=GREEN_DARK) -> None:
        if number:
            self.box(page, (MARGIN, y, MARGIN + 25, y + 25), fill=color, border=color)
            self.text(page, (MARGIN, y + 5, MARGIN + 25, y + 21), number, 8, WHITE, bold=True, align=fitz.TEXT_ALIGN_CENTER)
            x = MARGIN + 35
        else:
            x = MARGIN
        self.text(page, (x, y + 2, PAGE_W - MARGIN, y + 27), title, 13.5, INK, bold=True)

    def column_heading(self, page: fitz.Page, x: float, y: float, w: float, title: str, number: str, color=GREEN_DARK) -> None:
        self.box(page, (x, y, x + 25, y + 25), fill=color, border=color)
        self.text(page, (x, y + 5, x + 25, y + 21), number, 8, WHITE, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        self.text(page, (x + 35, y + 2, x + w, y + 27), title, 11.5, INK, bold=True)

    def bullets(self, page: fitz.Page, x: float, y: float, w: float, items: list[str], size: float = 9.2, gap: float = 28, color=TEXT) -> None:
        for item in items:
            page.draw_circle((x + 4, y + 7), 2.2, color=GREEN, fill=GREEN)
            self.text(page, (x + 14, y, x + w, y + gap - 2), item, size, color)
            y += gap

    def callout(self, page: fitz.Page, rect, title: str, body: str, accent=GREEN, fill=GREEN_SOFT) -> None:
        r = self.box(page, rect, fill=fill, border=fill)
        page.draw_rect(fitz.Rect(r.x0, r.y0, r.x0 + 5, r.y1), color=accent, fill=accent)
        if r.height < 60:
            self.text(page, (r.x0 + 17, r.y0 + 10, r.x0 + 126, r.y1 - 5), title, 7.7, accent, bold=True)
            self.text(page, (r.x0 + 132, r.y0 + 8, r.x1 - 10, r.y1 - 5), body, 7.5, TEXT)
        else:
            self.text(page, (r.x0 + 17, r.y0 + 12, r.x1 - 12, r.y0 + 31), title, 10, accent, bold=True)
            self.text(page, (r.x0 + 17, r.y0 + 36, r.x1 - 12, r.y1 - 10), body, 8.8, TEXT)

    def image(self, page: fitz.Page, path: Path, rect, border=True) -> None:
        r = fitz.Rect(rect)
        if border:
            self.box(page, r, fill=WHITE, border=LINE)
            r = fitz.Rect(r.x0 + 5, r.y0 + 5, r.x1 - 5, r.y1 - 5)
        page.insert_image(r, filename=str(path), keep_proportion=True)

    def save(self) -> None:
        self.doc.set_metadata(
            {
                "title": "EcoSafe - Rapport détaillé du projet mobile",
                "author": "Mahereiti Teraiamano, Adam Mzabi, Sami M'Halla, Yassine Moumoun",
                "subject": "Conception et réalisation de l'application Flutter EcoSafe",
                "keywords": "EcoSafe, Flutter, Firebase, mobilité, sécurité, écologie",
            }
        )
        toc = [
            [1, "Couverture", 1],
            [1, "Sommaire", 2],
            [1, "Synthèse exécutive", 3],
            [1, "Contexte et besoins", 4],
            [1, "Parcours utilisateur et fonctions", 5],
            [1, "Architecture technique", 6],
            [1, "Carte et calcul d'itinéraires", 7],
            [1, "Comparaison des transports et points", 8],
            [1, "Moteur de sécurité", 9],
            [1, "Profil, statistiques et historique", 10],
            [1, "Boutique de récompenses", 11],
            [1, "Données et persistance", 12],
            [1, "Interface et expérience utilisateur", 13],
            [1, "Qualité et tests", 14],
            [1, "Organisation et contributions", 15],
            [1, "Installation et déploiement", 16],
            [1, "Limites, risques et recommandations", 17],
            [1, "Feuille de route et conclusion", 18],
        ]
        self.doc.set_toc(toc)
        self.doc.save(OUT, garbage=4, deflate=True)


def cover(r: Report) -> None:
    page = r.doc.new_page(width=PAGE_W, height=PAGE_H)
    r.page_no += 1
    r._fonts(page)
    page.draw_rect(page.rect, fill=GREEN_DARK, color=GREEN_DARK)
    page.draw_rect(fitz.Rect(0, 0, PAGE_W, 19), fill=GREEN, color=GREEN)
    page.draw_rect(fitz.Rect(0, 520, PAGE_W, PAGE_H), fill=PAPER, color=PAPER)

    if ICON.exists():
        page.draw_rect(fitz.Rect(43, 49, 111, 117), fill=WHITE, color=WHITE)
        page.insert_image(fitz.Rect(51, 57, 103, 109), filename=str(ICON), keep_proportion=True)
    r.text(page, (132, 52, 540, 79), "APPLICATION MOBILE", 9, GREEN_SOFT, bold=True)
    r.text(page, (132, 75, 540, 142), "EcoSafe", 34, WHITE, bold=True, lineheight=1.05)
    r.text(page, (43, 148, 535, 228), "Rapport détaillé de conception\net de réalisation", 25, WHITE, bold=True, lineheight=1.05)
    r.text(
        page,
        (43, 238, 370, 300),
        "Choisir un trajet plus sûr, plus écologique et plus motivant grâce à une carte interactive, un score de sécurité et un système de récompenses.",
        11,
        GREEN_SOFT,
    )
    r.pill(page, 43, 312, 76, "FLUTTER", fill=GREEN, color=WHITE)
    r.pill(page, 127, 312, 82, "FIREBASE", fill=GREEN, color=WHITE)
    r.pill(page, 217, 312, 128, "OPENSTREETMAP", fill=GREEN, color=WHITE)
    r.pill(page, 43, 348, 104, "MATERIAL 3", fill=GREEN, color=WHITE)
    if PHONE_MAP.exists():
        page.draw_rect(fitz.Rect(390, 280, 548, 594), fill=WHITE, color=WHITE)
        page.insert_image(fitz.Rect(396, 286, 542, 588), filename=str(PHONE_MAP), keep_proportion=True)

    r.text(page, (43, 551, 350, 575), "ÉQUIPE PROJET", 8.5, GREEN_DARK, bold=True)
    names = [
        "Mahereiti Teraiamano",
        "Adam Mzabi",
        "Sami M'Halla",
        "Yassine Moumoun",
    ]
    y = 587
    for idx, name in enumerate(names, 1):
        page.draw_circle((54, y + 8), 10, color=GREEN, fill=GREEN)
        r.text(page, (47, y + 2, 61, y + 15), str(idx), 7, WHITE, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        r.text(page, (73, y, 330, y + 20), name, 10.5, INK, bold=True)
        y += 35
    r.text(page, (43, 750, 360, 774), "ANNÉE UNIVERSITAIRE 2025-2026", 8.5, MUTED, bold=True)
    r.footer(page)


def contents(r: Report) -> None:
    p = r.new_page("Navigation", "Sommaire", "Le rapport est également navigable depuis les signets du lecteur PDF.")
    entries = [
        ("00", "Synthèse exécutive", "03"),
        ("01", "Contexte et besoins", "04"),
        ("02", "Parcours utilisateur et fonctions", "05"),
        ("03", "Architecture technique", "06"),
        ("04", "Carte et calcul d'itinéraires", "07"),
        ("05", "Comparaison des transports et points", "08"),
        ("06", "Moteur de sécurité", "09"),
        ("07", "Profil, statistiques et historique", "10"),
        ("08", "Boutique de récompenses", "11"),
        ("09", "Données et persistance", "12"),
        ("10", "Interface et expérience utilisateur", "13"),
        ("11", "Qualité et tests", "14"),
        ("12", "Organisation et contributions", "15"),
        ("13", "Installation et déploiement", "16"),
        ("14", "Limites, risques et recommandations", "17"),
        ("15", "Feuille de route et conclusion", "18"),
    ]
    for idx, (number, title, page_no) in enumerate(entries):
        col = idx // 8
        row = idx % 8
        x = 42 + col * 265
        y = 144 + row * 74
        fill = GREEN_SOFT if row % 2 == 0 else WHITE
        r.box(p, (x, y, x + 246, y + 61), fill=fill, border=LINE)
        r.text(p, (x + 13, y + 12, x + 47, y + 34), number, 9, GREEN_DARK, bold=True)
        r.text(p, (x + 52, y + 10, x + 204, y + 48), title, 8.7, INK, bold=True)
        r.text(p, (x + 210, y + 18, x + 234, y + 38), page_no, 9, BLUE, bold=True, align=fitz.TEXT_ALIGN_RIGHT)
    r.callout(p, (42, 748, 553, 790), "FIL CONDUCTEUR", "Comprendre le besoin, suivre la conception, examiner chaque module, puis évaluer la qualité et les suites du projet.", accent=BLUE, fill=BLUE_SOFT)


def executive(r: Report) -> None:
    p = r.new_page("00 / Vue d'ensemble", "Synthèse exécutive", "Le projet, son intérêt et ses résultats en une page.")
    r.callout(
        p,
        (42, 139, 553, 213),
        "PROMESSE DU PRODUIT",
        "EcoSafe aide l'utilisateur à arbitrer entre durée, émissions de CO2 et sécurité. L'application transforme ensuite les bons choix en points échangeables contre des récompenses.",
    )
    cards = [
        ("5", "écrans principaux", GREEN, GREEN_SOFT),
        ("4", "modes comparés", BLUE, BLUE_SOFT),
        ("0-100", "score sécurité", ORANGE, ORANGE_SOFT),
    ]
    x = 42
    for value, label, accent, fill in cards:
        r.box(p, (x, 233, x + 158, 307), fill=fill, border=fill)
        r.text(p, (x + 13, 245, x + 145, 274), value, 20, accent, bold=True)
        r.text(p, (x + 13, 279, x + 145, 298), label, 8.2, TEXT, bold=True)
        x += 176

    r.column_heading(p, 42, 335, 245, "Ce qui a été réalisé", "01")
    r.bullets(
        p,
        42,
        374,
        245,
        [
            "Recherche d'un départ et d'une arrivée, géolocalisation et tracé cartographique.",
            "Comparaison vélo, métro, bus et voiture selon temps, CO2, sécurité et points.",
            "Calcul d'un score de sécurité enrichi par l'environnement urbain et la météo.",
            "Historique, profil, indicateurs hebdomadaires et mensuels via Firebase/Firestore.",
            "Catalogue de récompenses local et dépense du solde de points en session.",
        ],
        gap=43,
    )
    r.column_heading(p, 307, 335, 246, "État actuel du prototype", "02", color=BLUE)
    r.bullets(
        p,
        307,
        374,
        246,
        [
            "Analyse statique Flutter : aucune anomalie détectée le 22/06/2026.",
            "Suite de tests : 10 scénarios validés sur 10, dont le démarrage réel d'un trajet et le crédit des points.",
            "L'application tolère l'indisponibilité de Firebase et de plusieurs API grâce à des valeurs de repli.",
            "Le profil utilise encore l'identifiant de démonstration demo-user et la boutique reste mockée.",
        ],
        gap=53,
    )
    r.callout(p, (42, 704, 553, 781), "RÉSULTAT", "Un prototype transversal et démontrable, couvrant tout le parcours : chercher, comparer, démarrer, gagner, suivre et échanger.", accent=BLUE, fill=BLUE_SOFT)


def context(r: Report) -> None:
    p = r.new_page("01 / Cadrage", "Contexte et besoins", "Pourquoi EcoSafe, pour qui, et avec quels objectifs ?")
    r.heading(p, 142, "Problématique", "01")
    r.text(
        p,
        (42, 179, 553, 238),
        "Les applications d'itinéraires classiques privilégient généralement le temps ou la distance. Elles rendent moins visibles deux critères pourtant décisifs : l'impact environnemental et le niveau de sécurité perçu ou mesuré sur le trajet.",
        10,
    )
    problems = [
        ("Choix incomplet", "Le trajet le plus rapide n'est pas forcément le plus sûr ni le moins polluant.", ORANGE_SOFT, ORANGE),
        ("Impact abstrait", "Les grammes de CO2 évités restent difficiles à comprendre sans comparaison.", GREEN_SOFT, GREEN_DARK),
        ("Motivation faible", "Sans retour immédiat, l'utilisateur change rarement ses habitudes de mobilité.", BLUE_SOFT, BLUE),
    ]
    y = 257
    for title, body, fill, accent in problems:
        r.box(p, (42, y, 553, y + 70), fill=fill, border=fill)
        r.text(p, (58, y + 12, 190, y + 31), title, 10.5, accent, bold=True)
        r.text(p, (190, y + 11, 535, y + 54), body, 9, TEXT)
        y += 84
    r.column_heading(p, 42, 522, 245, "Objectifs fonctionnels", "02")
    r.bullets(
        p,
        42,
        562,
        245,
        [
            "Centraliser la décision dans une interface mobile simple.",
            "Donner une valeur comparable au CO2 et à la sécurité.",
            "Récompenser les trajets responsables par des points.",
            "Mémoriser l'activité et montrer les progrès dans le temps.",
        ],
        gap=43,
    )
    r.column_heading(p, 307, 522, 246, "Utilisateurs cibles", "03", color=BLUE)
    r.bullets(
        p,
        307,
        562,
        246,
        [
            "Étudiants et actifs se déplaçant quotidiennement.",
            "Cyclistes et piétons sensibles à l'éclairage et aux infrastructures.",
            "Usagers voulant réduire leur empreinte carbone sans perdre en praticité.",
            "Collectivités ou partenaires souhaitant encourager la mobilité douce.",
        ],
        gap=43,
    )


def journey(r: Report) -> None:
    p = r.new_page("02 / Produit", "Parcours utilisateur et fonctions", "Un flux continu de la recherche du trajet jusqu'à la récompense.")
    steps = [
        ("1", "Définir", "Saisir le départ et l'arrivée, ou utiliser la position GPS."),
        ("2", "Calculer", "Interroger le géocodage et le moteur de routage OpenStreetMap."),
        ("3", "Comparer", "Afficher durée, distance, CO2, sécurité et points par mode."),
        ("4", "Choisir", "Sélectionner le mode puis démarrer le trajet."),
        ("5", "Capitaliser", "Enregistrer l'historique, créditer les points et mettre à jour le profil."),
        ("6", "Récompenser", "Dépenser les points disponibles dans la boutique."),
    ]
    y = 143
    for i, (n, title, body) in enumerate(steps):
        left = 42 if i % 2 == 0 else 307
        if i and i % 2 == 0:
            y += 115
        fill = GREEN_SOFT if i % 3 == 0 else BLUE_SOFT if i % 3 == 1 else ORANGE_SOFT
        accent = GREEN_DARK if i % 3 == 0 else BLUE if i % 3 == 1 else ORANGE
        r.box(p, (left, y, left + 246, y + 94), fill=fill, border=fill)
        p.draw_circle((left + 24, y + 26), 13, color=accent, fill=accent)
        r.text(p, (left + 15, y + 18, left + 33, y + 33), n, 8, WHITE, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        r.text(p, (left + 47, y + 14, left + 230, y + 35), title, 12, INK, bold=True)
        r.text(p, (left + 15, y + 48, left + 230, y + 83), body, 8.5, TEXT)

    r.heading(p, 505, "Navigation principale", "07")
    tabs = [
        ("Carte", "Recherche et visualisation"),
        ("Transport", "Comparaison et sélection"),
        ("Sécurité", "Score, critères et conseils"),
        ("Profil", "Historique et statistiques"),
        ("Boutique", "Catalogue et échanges"),
    ]
    y = 548
    for idx, (tab, desc) in enumerate(tabs):
        color = GREEN_DARK if idx in (0, 4) else BLUE if idx in (1, 3) else ORANGE
        r.box(p, (42, y, 553, y + 39), fill=WHITE, border=LINE)
        r.text(p, (56, y + 10, 145, y + 28), tab, 9.5, color, bold=True)
        r.text(p, (157, y + 10, 535, y + 28), desc, 9, TEXT)
        y += 46


def architecture(r: Report) -> None:
    p = r.new_page("03 / Technique", "Architecture technique", "Une organisation Flutter en couches, connectée à des services externes.")
    layers = [
        ("PRÉSENTATION", "screens/ + navigation/ + config/", "Écrans Material 3, navigation à 5 onglets, thème et composants de carte.", GREEN, GREEN_SOFT),
        ("LOGIQUE MÉTIER", "services/", "Itinéraires, sécurité, points, historique, profil, météo et signalements.", BLUE, BLUE_SOFT),
        ("MODÈLES", "modeles/ + mocks/", "Trajet, zone de danger, score, profil, récompense et données locales.", ORANGE, ORANGE_SOFT),
        ("DONNÉES", "Firestore + JSON + API HTTP", "Persistance cloud, catalogue embarqué, géocodage, routage et contexte urbain.", GREEN_DARK, GREEN_SOFT),
    ]
    y = 145
    for name, folder, desc, accent, fill in layers:
        r.box(p, (42, y, 553, y + 82), fill=fill, border=fill)
        p.draw_rect(fitz.Rect(42, y, 49, y + 82), fill=accent, color=accent)
        r.text(p, (62, y + 12, 205, y + 31), name, 9, accent, bold=True)
        r.text(p, (213, y + 12, 535, y + 31), folder, 9, INK, bold=True)
        r.text(p, (62, y + 41, 535, y + 69), desc, 8.8, TEXT)
        y += 94
    r.heading(p, 536, "Socle technologique", "01")
    techs = [
        ("Flutter / Dart", "Interface multiplateforme et gestion d'état locale."),
        ("Firebase Core", "Initialisation de l'application cloud avec tolérance au délai."),
        ("Cloud Firestore", "Routes, profils, zones et signalements."),
        ("flutter_map", "Rendu OpenStreetMap, marqueurs et polylignes."),
        ("fl_chart", "Graphiques de progression et statistiques."),
        ("http + geolocator", "Appels REST et position courante."),
    ]
    y = 573
    for idx, (name, desc) in enumerate(techs):
        col = idx % 2
        row = idx // 2
        x = 42 + col * 265
        yy = y + row * 65
        r.box(p, (x, yy, x + 246, yy + 53), fill=WHITE, border=LINE)
        r.text(p, (x + 12, yy + 8, x + 228, yy + 25), name, 9, GREEN_DARK, bold=True)
        r.text(p, (x + 12, yy + 28, x + 228, yy + 47), desc, 7.7, TEXT)


def map_page(r: Report) -> None:
    p = r.new_page("04 / Fonctionnalité", "Carte et calcul d'itinéraires", "Le point d'entrée de l'application et le lien entre recherche, carte et transport.")
    r.image(p, PHONE_MAP if PHONE_MAP.exists() else ASSETS / "01_carte.png", (42, 141, 230, 514))
    r.column_heading(p, 256, 142, 297, "Chaîne de traitement", "01")
    chain = [
        ("Recherche", "Nominatim convertit un nom de lieu en latitude/longitude."),
        ("Position", "Geolocator obtient la position de l'appareil, puis un géocodage inverse fournit le libellé."),
        ("Routage", "routing.openstreetmap.de calcule géométrie, distance et durée pour foot, bike et car."),
        ("Affichage", "flutter_map trace la polyline et centre automatiquement la carte sur l'itinéraire."),
    ]
    y = 181
    for title, body in chain:
        r.box(p, (256, y, 553, y + 69), fill=WHITE, border=LINE)
        r.text(p, (269, y + 10, 348, y + 28), title, 9.5, BLUE, bold=True)
        r.text(p, (348, y + 9, 538, y + 57), body, 8.2, TEXT)
        y += 80
    r.heading(p, 540, "Calculs et état partagé", "02")
    r.bullets(
        p,
        42,
        579,
        511,
        [
            "ItineraireServices conserve départ, arrivée, libellés, mode courant et résultat par mode.",
            "La distance reçue en mètres est convertie en kilomètres; la durée en secondes devient un nombre de minutes arrondi.",
            "Pour la voiture, l'estimation actuelle utilise 120 g CO2 par kilomètre; marche et vélo sont considérés à 0 dans ce module.",
            "L'échange départ/arrivée et les boutons de zoom améliorent la manipulation directe de la carte.",
        ],
        gap=41,
    )
    r.callout(p, (42, 747, 553, 790), "FICHIER CENTRAL", "lib/services/itineraire_service.dart, orchestré depuis lib/screens/carte_screen.dart.", accent=BLUE, fill=BLUE_SOFT)


def transport(r: Report) -> None:
    p = r.new_page("05 / Fonctionnalité", "Comparaison des transports et points", "Rendre les arbitrages lisibles et récompenser les choix responsables.")
    r.image(p, PHONE_TRANSPORT if PHONE_TRANSPORT.exists() else ASSETS / "02_transport.png", (360, 142, 553, 525))
    r.heading(p, 142, "Modes proposés", "01")
    modes = [
        ("Vélo", "15 min", "0,0 kg", "92/100", "+40"),
        ("Métro", "18 min", "5,3 kg", "88/100", "+28"),
        ("Bus", "22 min", "8,5 kg", "78/100", "+24"),
        ("Voiture", "12 min", "24,5 kg", "65/100", "+5"),
    ]
    y = 182
    for mode, duration, co2, sec, pts in modes:
        r.box(p, (42, y, 335, y + 62), fill=WHITE, border=LINE)
        r.text(p, (55, y + 10, 125, y + 28), mode, 10, GREEN_DARK, bold=True)
        r.text(p, (128, y + 10, 240, y + 28), f"{duration}  |  {co2}", 8.3, TEXT)
        r.text(p, (55, y + 35, 193, y + 52), f"Sécurité {sec}", 8.3, MUTED)
        r.text(p, (248, y + 18, 319, y + 45), pts, 14, BLUE, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        y += 72
    r.heading(p, 486, "Barème implémenté", "02")
    r.callout(
        p,
        (42, 525, 335, 608),
        "POINTS ÉCO",
        "ratio = (CO2 voiture - CO2 mode) / CO2 voiture\npoints = arrondi(ratio × 25), borné entre 0 et 25.",
        accent=GREEN_DARK,
        fill=GREEN_SOFT,
    )
    r.callout(
        p,
        (42, 620, 335, 729),
        "POINTS SÉCURITÉ",
        "15 points si score ≥ 90; 8 points si score ≥ 75; 5 points si score ≥ 60; sinon 0 point.",
        accent=BLUE,
        fill=BLUE_SOFT,
    )
    r.callout(
        p,
        (360, 548, 553, 729),
        "DÉMARRAGE DU TRAJET",
        "Le bouton n'apparaît que lorsque départ, arrivée et mode sont définis. Au clic, les points sont ajoutés à la session, le trajet est construit puis envoyé à Firestore; la carte redevient l'écran actif.",
        accent=ORANGE,
        fill=ORANGE_SOFT,
    )
    r.text(p, (42, 753, 553, 788), "Remarque : les valeurs illustrées sont les données de démonstration présentes dans TransportScreen.", 8, MUTED)


def security(r: Report) -> None:
    p = r.new_page("06 / Fonctionnalité", "Moteur de sécurité", "Un score pondéré, enrichi par l'environnement urbain et les conditions météo.")
    r.callout(
        p,
        (42, 141, 553, 212),
        "FORMULE PRINCIPALE",
        "Score = 100 × [0,30 × éclairage + 0,25 × (1 - trafic) + 0,20 × fréquentation + 0,25 × piste cyclable]",
        accent=GREEN_DARK,
        fill=GREEN_SOFT,
    )
    factors = [
        ("30 %", "Éclairage", "Nombre de lampadaires OpenStreetMap dans un rayon de 300 m.", ORANGE),
        ("25 %", "Trafic / danger", "Facteur inverse : plus il est élevé, plus la sécurité diminue.", BLUE),
        ("20 %", "Fréquentation", "Présence de voies piétonnes et chemins autour du point.", GREEN_DARK),
        ("25 %", "Piste cyclable", "Présence d'infrastructures vélo dédiées.", (0.46, 0.34, 0.83)),
    ]
    y = 231
    for idx, (pct, title, body, accent) in enumerate(factors):
        x = 42 if idx % 2 == 0 else 307
        yy = y + (idx // 2) * 112
        r.box(p, (x, yy, x + 246, yy + 96), fill=WHITE, border=LINE)
        r.text(p, (x + 13, yy + 13, x + 72, yy + 40), pct, 15, accent, bold=True)
        r.text(p, (x + 78, yy + 14, x + 230, yy + 34), title, 10.5, INK, bold=True)
        r.text(p, (x + 13, yy + 50, x + 230, yy + 85), body, 8.2, TEXT)
    r.heading(p, 468, "Sources et stratégie de repli", "01")
    sources = [
        ("Overpass API", "cycleways, street_lamps, pedestrian et footway; valeurs de repli à 0,5."),
        ("CrimeoMeter", "incidents sur 500 m; token actuellement généré aléatoirement, donc retour fréquent à 0,5."),
        ("Open-Meteo", "pénalités : orage -20, pluie -10, neige -8 et nuit -15."),
        ("Firestore", "zones de sécurité et signalements communautaires, avec requêtes tolérantes aux erreurs."),
    ]
    y = 508
    for name, desc in sources:
        r.box(p, (42, y, 553, y + 48), fill=WHITE, border=LINE)
        r.text(p, (55, y + 9, 150, y + 27), name, 9, BLUE, bold=True)
        r.text(p, (151, y + 8, 535, y + 37), desc, 8.2, TEXT)
        y += 56
    r.callout(p, (42, 744, 553, 791), "ROBUSTESSE", "En cas d'erreur globale, le score retourné est 50/100; tous les résultats restent bornés entre 0 et 100.", accent=ORANGE, fill=ORANGE_SOFT)


def profile(r: Report) -> None:
    p = r.new_page("07 / Fonctionnalité", "Profil, statistiques et historique", "Transformer les trajets enregistrés en suivi personnel compréhensible.")
    r.heading(p, 142, "Indicateurs présentés", "01")
    cards = [
        ("Trajets", "total, semaine, mois", BLUE),
        ("Points", "cumul et progression", GREEN_DARK),
        ("CO2", "impact agrégé", ORANGE),
        ("Sécurité", "score moyen", (0.46, 0.34, 0.83)),
    ]
    x = 42
    for title, desc, accent in cards:
        r.box(p, (x, 181, x + 118, 251), fill=WHITE, border=LINE)
        r.text(p, (x + 10, 194, x + 108, 215), title, 10, accent, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        r.text(p, (x + 8, 222, x + 110, 242), desc, 7.3, MUTED, align=fitz.TEXT_ALIGN_CENTER)
        x += 131

    r.heading(p, 280, "Flux de données", "02")
    flow = [
        ("TransportScreen", "construit un objet Trajets"),
        ("RouteHistoryService", "enregistre routes/{id}"),
        ("UserProfileService", "incrémente le profil"),
        ("Profile / Stats", "agrège et affiche"),
    ]
    y = 320
    for idx, (name, desc) in enumerate(flow):
        x = 42 + idx * 131
        r.box(p, (x, y, x + 116, y + 76), fill=GREEN_SOFT if idx % 2 == 0 else BLUE_SOFT, border=LINE)
        r.text(p, (x + 8, y + 12, x + 108, y + 31), name, 8.5, GREEN_DARK if idx % 2 == 0 else BLUE, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        r.text(p, (x + 8, y + 40, x + 108, y + 66), desc, 7.2, TEXT, align=fitz.TEXT_ALIGN_CENTER)
        if idx < 3:
            p.draw_line((x + 116, y + 38), (x + 131, y + 38), color=MUTED, width=1.1)

    r.column_heading(p, 42, 430, 245, "Agrégations calculées", "03")
    r.bullets(
        p,
        42,
        471,
        245,
        [
            "Somme des points et du CO2 sur tous les trajets.",
            "Nombre de trajets écologiques et score moyen de sécurité.",
            "Fenêtres glissantes de 7 jours et 30 jours.",
            "Flux temps réel via snapshots Firestore pour actualiser les statistiques.",
        ],
        gap=47,
    )
    r.column_heading(p, 307, 430, 246, "Contenu de l'écran", "04", color=BLUE)
    r.bullets(
        p,
        307,
        471,
        246,
        [
            "Avatar, identité utilisateur et badge de points.",
            "Répartition des points écologiques et de sécurité.",
            "Graphiques hebdomadaires et mensuels avec fl_chart.",
            "Cinq trajets récents et accès à l'écran détaillé des statistiques.",
        ],
        gap=47,
    )
    r.callout(p, (42, 688, 553, 781), "MODE DÉMONSTRATION", "La navigation injecte actuellement l'identifiant fixe demo-user. Une authentification réelle devra fournir l'identifiant de chaque utilisateur.", accent=ORANGE, fill=ORANGE_SOFT)


def shop(r: Report) -> None:
    p = r.new_page("08 / Fonctionnalité", "Boutique de récompenses", "Boucler la mécanique d'engagement en transformant les points en avantages.")
    r.image(p, ASSETS / "05_boutique.png", (42, 142, 242, 575))
    r.column_heading(p, 270, 142, 283, "Fonctionnement", "01")
    r.bullets(
        p,
        270,
        181,
        283,
        [
            "Le catalogue est chargé depuis lib/data/rewards.json ou injecté directement dans les tests.",
            "Le solde initial de démonstration vaut 320 points et vit dans un ValueNotifier partagé.",
            "Le bouton Échanger est activé si la récompense est disponible et si le solde est suffisant.",
            "Une transaction réussie déduit immédiatement le coût et affiche une confirmation.",
            "Les cartes indiquent catégorie, coût, disponibilité, remise et icône associée.",
        ],
        gap=57,
    )
    r.column_heading(p, 270, 505, 283, "Catalogue de démonstration", "02")
    rewards = [
        ("Ticket bus journée", "120 pts", "Transport", "-20 %"),
        ("Café offert", "80 pts", "Partenaire", "Disponible"),
        ("Réduction déjeuner", "220 pts", "Food", "Disponible"),
        ("Bon d'achat", "450 pts", "Shopping", "Solde insuffisant"),
    ]
    y = 546
    for name, cost, cat, status in rewards:
        r.box(p, (270, y, 553, y + 48), fill=WHITE, border=LINE)
        r.text(p, (283, y + 8, 430, y + 25), name, 8.7, INK, bold=True)
        r.text(p, (430, y + 8, 538, y + 25), cost, 8.7, GREEN_DARK, bold=True, align=fitz.TEXT_ALIGN_RIGHT)
        r.text(p, (283, y + 28, 405, y + 42), cat, 7.3, BLUE)
        r.text(p, (405, y + 28, 538, y + 42), status, 7.3, MUTED, align=fitz.TEXT_ALIGN_RIGHT)
        y += 55
    r.callout(p, (42, 600, 242, 778), "PORTÉE ACTUELLE", "La boutique fonctionne localement pendant la session. La future version devra persister le solde, les achats et la disponibilité dans Firestore, puis sécuriser les échanges côté serveur.", accent=BLUE, fill=BLUE_SOFT)


def data(r: Report) -> None:
    p = r.new_page("09 / Données", "Données et persistance", "Les objets manipulés, les collections Firestore et les données embarquées.")
    r.heading(p, 142, "Modèles principaux", "01")
    models = [
        ("Trajets", "id, userId, départ, arrivée, mode, distance, CO2, points, sécurité, date, isEco"),
        ("UserProfile", "id, nom, email, totalPoints, totalRoutes, ecoRoutes"),
        ("SecurityScore", "zone, coordonnées, éclairage, trafic, fréquentation, piste cyclable"),
        ("InfosTrajet", "mode, points de géométrie, distance, durée, CO2"),
        ("Reward", "id, nom, description, coût, catégorie, icône, disponibilité, promotion"),
    ]
    y = 180
    for name, attrs in models:
        r.box(p, (42, y, 553, y + 52), fill=WHITE, border=LINE)
        r.text(p, (55, y + 10, 145, y + 30), name, 9, GREEN_DARK, bold=True)
        r.text(p, (145, y + 9, 537, y + 40), attrs, 8.2, TEXT)
        y += 60
    r.heading(p, 495, "Collections et fichiers", "02")
    data_sources = [
        ("routes", "Historique des trajets et métriques calculées.", "Firestore"),
        ("users", "Profil et compteurs agrégés par utilisateur.", "Firestore"),
        ("security_zones", "Critères de sécurité géolocalisés.", "Firestore"),
        ("signalements", "Événements communautaires proches d'un point.", "Firestore"),
        ("security_zones.json", "Zones embarquées utilisées par le module carte.", "Asset"),
        ("rewards.json", "Catalogue de récompenses du prototype.", "Asset"),
    ]
    y = 534
    for idx, (name, purpose, kind) in enumerate(data_sources):
        col = idx % 2
        row = idx // 2
        x = 42 + col * 265
        yy = y + row * 73
        r.box(p, (x, yy, x + 246, yy + 61), fill=GREEN_SOFT if kind == "Firestore" else BLUE_SOFT, border=LINE)
        r.text(p, (x + 11, yy + 9, x + 155, yy + 27), name, 8.7, INK, bold=True)
        r.text(p, (x + 163, yy + 9, x + 235, yy + 27), kind, 7.2, GREEN_DARK if kind == "Firestore" else BLUE, bold=True, align=fitz.TEXT_ALIGN_RIGHT)
        r.text(p, (x + 11, yy + 33, x + 235, yy + 54), purpose, 7.6, TEXT)
    r.callout(p, (42, 756, 553, 792), "COHÉRENCE", "Les modèles proposent des conversions toMap/fromMap afin de limiter la duplication entre l'application et Firestore.", accent=GREEN_DARK, fill=GREEN_SOFT)


def ux(r: Report) -> None:
    p = r.new_page("10 / Design", "Interface et expérience utilisateur", "Une direction visuelle cohérente, centrée sur la comparaison rapide.")
    shots = [
        (ASSETS / "01_carte.png", "CARTE"),
        (ASSETS / "02_transport.png", "TRANSPORT"),
        (ASSETS / "05_boutique.png", "BOUTIQUE"),
    ]
    x = 42
    for path, label in shots:
        r.image(p, path, (x, 142, x + 157, 485))
        r.text(p, (x, 494, x + 157, 512), label, 7.5, GREEN_DARK, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        x += 177
    r.heading(p, 536, "Principes graphiques", "01")
    principles = [
        ("Vert", "mobilité responsable, validation, solde positif"),
        ("Bleu", "information, sécurité, sélection active"),
        ("Orange", "attention, météo, promotion et avertissement"),
        ("Cartes", "hiérarchie par blocs, bordures discrètes et densité maîtrisée"),
        ("Navigation", "cinq destinations fixes accessibles sur tous les écrans"),
        ("Material 3", "thème centralisé, composants réutilisables et états cohérents"),
    ]
    y = 575
    for idx, (title, desc) in enumerate(principles):
        col = idx % 2
        row = idx // 2
        xx = 42 + col * 265
        yy = y + row * 62
        r.box(p, (xx, yy, xx + 246, yy + 51), fill=WHITE, border=LINE)
        accent = GREEN_DARK if title in ("Vert", "Cartes") else BLUE if title in ("Bleu", "Navigation") else ORANGE
        r.text(p, (xx + 11, yy + 8, xx + 80, yy + 26), title, 8.8, accent, bold=True)
        r.text(p, (xx + 80, yy + 7, xx + 232, yy + 42), desc, 7.5, TEXT)
    r.callout(p, (42, 761, 553, 792), "ACCESSIBILITÉ", "Les libellés accompagnent les icônes; les décisions importantes ne reposent pas uniquement sur la couleur.", accent=BLUE, fill=BLUE_SOFT)


def quality(r: Report) -> None:
    p = r.new_page("11 / Validation", "Qualité et tests", "État vérifié du projet au 22 juin 2026.")
    r.box(p, (42, 142, 288, 234), fill=GREEN_SOFT, border=GREEN_SOFT)
    r.text(p, (58, 157, 272, 181), "FLUTTER ANALYZE", 9, GREEN_DARK, bold=True)
    r.text(p, (58, 185, 272, 218), "Aucune anomalie détectée", 15, GREEN_DARK, bold=True)
    r.box(p, (307, 142, 553, 234), fill=GREEN_SOFT, border=GREEN_SOFT)
    r.text(p, (323, 157, 537, 181), "FLUTTER TEST", 9, GREEN_DARK, bold=True)
    r.text(p, (323, 185, 537, 218), "10 réussites / 0 échec", 15, GREEN_DARK, bold=True)

    r.heading(p, 263, "Scénarios couverts", "01")
    tests = [
        ("OK", "Calcul des points écologiques et de sécurité."),
        ("OK", "Gestion du solde et refus d'une dépense trop élevée."),
        ("OK", "Affichage de la navigation et ouverture de la carte."),
        ("OK", "Réutilisation de TransportScreen avec la navigation globale."),
        ("OK", "Apparition du bouton Démarrer après sélection du mode."),
        ("OK", "Démarrage réel : points crédités, mode activé et confirmation affichée."),
        ("OK", "Affichage du catalogue de récompenses mockées."),
        ("OK", "Déduction des points lors d'un échange."),
        ("OK", "Réutilisation de ShopScreen hors navigation."),
        ("OK", "Construction du trajet à partir des coordonnées et de la distance."),
    ]
    y = 302
    for status, label in tests:
        accent = GREEN_DARK if status == "OK" else RED
        fill = GREEN_SOFT if status == "OK" else RED_SOFT
        r.box(p, (42, y, 553, y + 32), fill=WHITE, border=LINE)
        r.box(p, (54, y + 7, 101, y + 25), fill=fill, border=fill)
        r.text(p, (57, y + 10, 98, y + 23), status, 6.5, accent, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        r.text(p, (114, y + 7, 538, y + 27), label, 8.1, TEXT)
        y += 38
    r.callout(
        p,
        (42, 700, 553, 790),
        "VALIDATION DU BOUTON DÉMARRER",
        "Après sélection du vélo, le test appuie réellement sur le bouton, confirme le rappel de navigation, vérifie le crédit de 40 points, le passage au mode bike et l'affichage du message de confirmation.",
        accent=GREEN_DARK,
        fill=GREEN_SOFT,
    )


def team(r: Report) -> None:
    p = r.new_page("12 / Projet", "Organisation et contributions", "Une répartition par domaines, puis une phase d'intégration commune.")
    people = [
        ("Mahereiti Teraiamano", "Carte & navigation", "Carte interactive, recherche dynamique, modes, itinéraires, géolocalisation et intégration Android.", GREEN_DARK, GREEN_SOFT),
        ("Adam Mzabi", "Transport & points", "Écran de comparaison, calcul des points, données CO2/sécurité et logique de sélection du mode.", BLUE, BLUE_SOFT),
        ("Yassine Moumoun", "Sécurité, profil & stats", "Fonctionnalités EcoSafe, score de sécurité, historique, indicateurs et visualisations de profil.", ORANGE, ORANGE_SOFT),
        ("Sami M'Halla", "Firebase, boutique & intégration", "Thème, persistance, catalogue de récompenses, échanges, fusion des branches et finalisation.", (0.46, 0.34, 0.83), (0.95, 0.93, 1.0)),
    ]
    y = 143
    for idx, (name, role, desc, accent, fill) in enumerate(people, 1):
        r.box(p, (42, y, 553, y + 105), fill=fill, border=fill)
        p.draw_circle((67, y + 31), 16, color=accent, fill=accent)
        r.text(p, (55, y + 22, 79, y + 40), str(idx), 9, WHITE, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        r.text(p, (94, y + 14, 337, y + 36), name, 11.5, INK, bold=True)
        r.text(p, (347, y + 15, 535, y + 34), role, 8.5, accent, bold=True, align=fitz.TEXT_ALIGN_RIGHT)
        r.text(p, (94, y + 49, 535, y + 89), desc, 8.7, TEXT)
        y += 117
    r.heading(p, 630, "Méthode de collaboration", "01")
    r.bullets(
        p,
        42,
        669,
        511,
        [
            "Branches spécialisées puis fusions successives vers la branche d'intégration boutique.",
            "Responsabilités fonctionnelles visibles dans l'historique Git et dans la structure du code.",
            "Tests transversaux destinés à sécuriser le calcul des points, la navigation et la boutique.",
        ],
        gap=39,
    )
    r.text(p, (42, 779, 553, 797), "Attribution établie à partir de l'historique Git et de la répartition décrite dans les supports du projet.", 7.5, MUTED)


def install(r: Report) -> None:
    p = r.new_page("13 / Exploitation", "Installation et déploiement", "Reproduire l'environnement, lancer l'application et générer les livrables.")
    r.heading(p, 142, "Prérequis", "01")
    r.bullets(
        p,
        42,
        181,
        511,
        [
            "Flutter compatible avec Dart SDK ^3.10.8 et un navigateur ou un appareil Android.",
            "Accès réseau pour OpenStreetMap, Nominatim, Overpass, Open-Meteo et Firebase.",
            "Configuration Android avec l'autorisation Internet et, selon la cible, les droits de localisation.",
        ],
        gap=39,
    )
    r.heading(p, 314, "Commandes principales", "02")
    commands = [
        ("Installer", r"C:\flutter_sdk\bin\flutter.bat pub get"),
        ("Web", r"C:\flutter_sdk\bin\flutter.bat run -d chrome"),
        ("Android", r"C:\flutter_sdk\bin\flutter.bat run -d <device>"),
        ("Analyser", r"C:\flutter_sdk\bin\flutter.bat analyze"),
        ("Tester", r"C:\flutter_sdk\bin\flutter.bat test"),
        ("Build web", r"C:\flutter_sdk\bin\flutter.bat build web"),
    ]
    y = 353
    for label, command in commands:
        r.box(p, (42, y, 553, y + 48), fill=WHITE, border=LINE)
        r.text(p, (55, y + 10, 125, y + 29), label, 8.5, GREEN_DARK, bold=True)
        r.text(p, (129, y + 10, 538, y + 31), command, 8.2, INK)
        y += 57
    r.heading(p, 708, "Cibles", "03")
    r.text(p, (42, 747, 553, 792), "Le squelette Flutter contient les plateformes Android, iOS, Web, Windows, Linux et macOS. Le projet a surtout été validé sur Chrome et Android; les autres cibles demandent une recette dédiée.", 9, TEXT)


def limitations(r: Report) -> None:
    p = r.new_page("14 / Bilan", "Limites, risques et recommandations", "Ce qui sépare le prototype d'une mise en production fiable.")
    items = [
        ("Sécurité des secrets", "La configuration Firebase est intégrée au code et CrimeoMeter génère un faux token. Utiliser les mécanismes officiels de configuration et un proxy serveur.", RED, RED_SOFT),
        ("Authentification", "demo-user est partagé par tous. Ajouter Firebase Authentication et des règles Firestore par utilisateur.", ORANGE, ORANGE_SOFT),
        ("Persistance des points", "Le solde boutique vit dans la session alors que le profil utilise Firestore. Définir une source de vérité unique et des transactions atomiques.", BLUE, BLUE_SOFT),
        ("Cohérence métier", "Deux formules de points coexistent : PointsService et RouteHistoryService.computePoints. Centraliser le barème dans un service unique.", GREEN_DARK, GREEN_SOFT),
        ("Gestion des erreurs", "Plusieurs catch sont silencieux. Journaliser, informer l'utilisateur et différencier absence de données, réseau indisponible et permission refusée.", RED, RED_SOFT),
        ("API publiques", "Respecter les politiques d'usage OSM, ajouter cache, limitation de débit, timeout et fournisseur de secours.", ORANGE, ORANGE_SOFT),
        ("Tests", "Conserver les tests du bouton et ajouter tests services, règles Firestore, intégration réseau mockée et tests end-to-end Android.", BLUE, BLUE_SOFT),
    ]
    y = 142
    for title, body, accent, fill in items:
        r.box(p, (42, y, 553, y + 81), fill=fill, border=fill)
        r.text(p, (56, y + 11, 188, y + 31), title, 9.3, accent, bold=True)
        r.text(p, (188, y + 10, 537, y + 67), body, 8.2, TEXT)
        y += 91
    r.callout(p, (42, 784 - 47, 553, 790), "PRIORITÉ", "Unifier l'identité utilisateur et les points avant d'élargir le catalogue ou de déployer à grande échelle.", accent=RED, fill=RED_SOFT)


def roadmap(r: Report) -> None:
    p = r.new_page("15 / Suite", "Feuille de route et conclusion", "Passer d'un prototype intégré à un produit robuste et mesurable.")
    roadmap_items = [
        ("1", "Stabiliser", "Maintenir la suite de tests, centraliser les points, fiabiliser les erreurs et documenter les règles Firestore.", GREEN_DARK),
        ("2", "Sécuriser", "Ajouter l'authentification, déplacer les secrets, valider les droits et rendre les échanges atomiques.", BLUE),
        ("3", "Réaliser", "Connecter la boutique et les partenaires, remplacer le mock CrimeoMeter et consolider le score de sécurité.", ORANGE),
        ("4", "Mesurer", "Mettre en place analytics, tests utilisateurs, indicateurs d'usage et suivi de l'impact CO2.", (0.46, 0.34, 0.83)),
        ("5", "Déployer", "Tester toutes les plateformes cibles, mettre en cache les tuiles autorisées et publier avec supervision.", GREEN),
    ]
    y = 143
    for number, title, body, accent in roadmap_items:
        p.draw_circle((64, y + 28), 17, color=accent, fill=accent)
        r.text(p, (51, y + 18, 77, y + 37), number, 9, WHITE, bold=True, align=fitz.TEXT_ALIGN_CENTER)
        if number != "5":
            p.draw_line((64, y + 45), (64, y + 93), color=LINE, width=2)
        r.text(p, (98, y + 8, 225, y + 30), title, 12, INK, bold=True)
        r.text(p, (98, y + 36, 540, y + 75), body, 8.8, TEXT)
        y += 104
    r.callout(
        p,
        (42, 679, 553, 770),
        "CONCLUSION",
        "EcoSafe réunit dans une seule application la mobilité, l'écologie, la sécurité et la motivation. Le prototype démontre la cohérence du concept et la complémentarité du travail de Mahereiti Teraiamano, Adam Mzabi, Sami M'Halla et Yassine Moumoun. Les prochaines étapes sont clairement identifiées pour transformer cette base en service exploitable.",
        accent=GREEN_DARK,
        fill=GREEN_SOFT,
    )
    r.text(p, (42, 782, 553, 800), "FIN DU RAPPORT  |  Merci pour votre lecture", 8, GREEN_DARK, bold=True, align=fitz.TEXT_ALIGN_CENTER)


def main() -> None:
    if not FONT.exists() or not FONT_BOLD.exists():
        raise FileNotFoundError("Les polices Segoe UI nécessaires sont introuvables.")

    report = Report()
    cover(report)
    contents(report)
    executive(report)
    context(report)
    journey(report)
    architecture(report)
    map_page(report)
    transport(report)
    security(report)
    profile(report)
    shop(report)
    data(report)
    ux(report)
    quality(report)
    team(report)
    install(report)
    limitations(report)
    roadmap(report)
    report.save()
    print(OUT)


if __name__ == "__main__":
    main()
