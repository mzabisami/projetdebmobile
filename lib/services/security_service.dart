import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeles/score_securite.dart';
import 'overpass_service.dart';
import 'crimeometer_service.dart';
import 'weather_service.dart';

class SecurityService {

  List<SecurityScore> _zones = [];
  final CrimeoMeterService _crimeometer = CrimeoMeterService();

  // Charge les zones depuis Firestore
  Future<void> loadZones() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('security_zones').get();

      _zones = snapshot.docs.map((QueryDocumentSnapshot doc) {
        return SecurityScore.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      // Firestore indisponible — les zones restent vides
    }
  }

  // Retourne la zone géographique la plus proche via Haversine
  SecurityScore? getNearestZone(double userLat, double userLon) {
    if (_zones.isEmpty) return null;

    SecurityScore? nearest;
    double minDistance = double.infinity;

    for (final SecurityScore zone in _zones) {
      final double dist = _calculateDistance(
        userLat, userLon,
        zone.latitude, zone.longitude,
      );
      if (dist < minDistance) {
        minDistance = dist;
        nearest = zone;
      }
    }

    return nearest;
  }

  // Calcule le score pondéré de sécurité (0–100)
  double calculateSecurityScore({
    required double lighting,
    required double traffic,
    required double crowding,
    required double cyclingPath,
  }) {
    const double wLighting    = 0.30;
    const double wTraffic     = 0.25;
    const double wCrowding    = 0.20;
    const double wCyclingPath = 0.25;

    final double score =
        (lighting      * wLighting)    +
        ((1 - traffic) * wTraffic)     +
        (crowding      * wCrowding)    +
        (cyclingPath   * wCyclingPath);

    return (score * 100).clamp(0, 100);
  }

  // Score complet : Overpass + CrimeoMeter (mock) + météo, tout en parallèle
  Future<double> getScoreForPosition(double lat, double lon) async {
    try {
      final List<dynamic> results = await Future.wait([
        OverpassService().getUrbanFactors(lat, lon),
        _crimeometer.getDangerFactor(lat, lon),
        WeatherService().getWeatherPenalty(lat, lon),
      ]);

      final Map<String, double> urban   = results[0] as Map<String, double>;
      final double              trafic  = results[1] as double;
      final int                 weather = results[2] as int;

      final double base = calculateSecurityScore(
        lighting:    urban['eclairage']!,
        traffic:     trafic,
        crowding:    urban['frequentation']!,
        cyclingPath: urban['pisteCyclable']!,
      );

      return (base + weather).clamp(0.0, 100.0);
    } catch (e) {
      return 50.0;
    }
  }

  // Alias maintenu pour compatibilité — délègue à getScoreForPosition
  Future<double> getAdjustedScore(double lat, double lon) =>
      getScoreForPosition(lat, lon);

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  List<SecurityScore> getZones() => List.unmodifiable(_zones);

  double _toRad(double deg) => deg * pi / 180;
}
