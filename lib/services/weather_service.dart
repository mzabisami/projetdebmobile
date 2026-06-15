import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Retourne une pénalité négative basée sur la météo et l'heure du jour
  Future<int> getWeatherPenalty(double lat, double lon) async {
    try {
      final Uri url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon&current_weather=true',
      );

      final http.Response response = await http.get(url);

      if (response.statusCode != 200) {
        return 0;
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> current =
          data['current_weather'] as Map<String, dynamic>;

      final int weatherCode = (current['weathercode'] as num).toInt();
      final String timeStr = current['time'] as String;
      final int hour = DateTime.parse(timeStr).toLocal().hour;

      int penalty = 0;

      // Pénalités selon le code météo WMO
      if (weatherCode >= 95) {
        penalty -= 20; // Orage
      } else if (weatherCode >= 71 && weatherCode <= 77) {
        penalty -= 8; // Neige
      } else if (weatherCode >= 51 && weatherCode <= 67) {
        penalty -= 10; // Pluie
      }

      // Pénalité nocturne : 22h–6h
      if (hour >= 22 || hour <= 6) {
        penalty -= 15;
      }

      return penalty;
    } catch (e) {
      return 0;
    }
  }
}
