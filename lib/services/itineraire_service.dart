import 'dart:convert';

import 'package:devmobile/modeles/infos_trajets.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ItineraireServices {
  static LatLng? depart;
  static LatLng? arrivee;
  static String departLabel = 'Départ';
  static String arriveeLabel = 'Arrivée';
  static String modeActuel = 'foot';
  static Map<String, InfosTrajet> trajetsParMode = {
    'foot': InfosTrajet(mode: 'foot'),
    'bike': InfosTrajet(mode: 'bike'),
    'car': InfosTrajet(mode: 'car'),
  };

  static String formaterDuree(int duree) {
    if (duree < 60) {
      return '$duree min';
    } else {
      int heures = duree ~/ 60;
      int minutes = duree % 60;
      return '$heures h $minutes min';
    }
  }

  static Future<LatLng?> getCoordLieu(String lieu) async {
    if (lieu.trim().isEmpty) {
      return null;
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(lieu)}&format=json&limit=1',
    );

    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          return LatLng(
            double.parse(data[0]['lat']),
            double.parse(data[0]['lon']),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la recherche du lieu : $e');
    }
    return null;
  }

  static Future<String> getNomLieu(LatLng point) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}',
    );
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? '';
      }
    } catch (e) {
      debugPrint('Erreur lors de la recherche du nom de la ville : $e');
    }
    return '';
  }

  static Future<void> calculerTousTrajets() async {
    if (depart == null || arrivee == null) {
      return;
    }
    List<String> modes = ['foot', 'bike', 'car'];

    for (String mode in modes) {
      trajetsParMode[mode]!.depart = depart;
      trajetsParMode[mode]!.arrivee = arrivee;
      final url = Uri.parse(
        'https://routing.openstreetmap.de/routed-$mode/route/v1/driving/'
        '${depart!.longitude},${depart!.latitude};${arrivee!.longitude},${arrivee!.latitude}?overview=full&geometries=geojson',
      );

      try {
        final response = await http.get(url, headers: _headers);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final coords = data['routes'][0]['geometry']['coordinates'];

            trajetsParMode[mode]!.trajet = coords
                .map<LatLng>((point) => LatLng(point[1], point[0]))
                .toList();
            trajetsParMode[mode]!.distance =
                data['routes'][0]['distance'] / 1000; // Convertir en km
            trajetsParMode[mode]!.duree = (data['routes'][0]['duration'] / 60)
                .round(); // Convertir en minutes
            trajetsParMode[mode]!.co2 =
                trajetsParMode[mode]!.distance *
                (mode == 'car' ? 120 : 0); // 120g CO2/km pour la voiture
          }
        }
      } catch (e) {
        debugPrint('Erreur lors du calcul du trajet : $e');
      }
    }
  }

  static const Map<String, String> _headers = {
    'User-Agent': 'EcoSafe/1.0 (com.example.devmobile)',
    'Accept': 'application/json',
  };
}
