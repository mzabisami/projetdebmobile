class SecurityScore {
  final String zoneId; // Identifiant de la zone (ex: "zone_001")
  final double lighting; // Éclairage        → valeur entre 0 et 1
  final double traffic; // Trafic           → valeur entre 0 et 1
  final double crowding; // Fréquentation    → valeur entre 0 et 1
  final double cyclingPath; // Piste cyclable   → valeur entre 0 et 1
  final double latitude; // Position GPS
  final double longitude;

  SecurityScore({
    required this.zoneId,
    required this.lighting,
    required this.traffic,
    required this.crowding,
    required this.cyclingPath,
    required this.latitude,
    required this.longitude,
  });

  // Depuis un Map JSON (pour lire le fichier JSON)
  factory SecurityScore.fromMap(Map<String, dynamic> map) {
    return SecurityScore(
      zoneId: map['zoneId'] ?? '',
      lighting: (map['lighting'] ?? 0).toDouble(),
      traffic: (map['traffic'] ?? 0).toDouble(),
      crowding: (map['crowding'] ?? 0).toDouble(),
      cyclingPath: (map['cyclingPath'] ?? 0).toDouble(),
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
    );
  }

  // Score global calculé par Adam et que je va utiliser pour calculer le score final de points
  double get globalScore {
    return (lighting + (1 - traffic) + crowding + cyclingPath) / 4 * 100;
  }
}
