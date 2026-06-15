class Trajets {
  final String id; // ID unique du trajet
  final String userId; // Qui a fait ce trajet
  final String startPoint; // Nom du point de départ
  final String endPoint; // Nom du point d'arrivée
  final String mode; // "vélo", "bus", "métro", "voiture"
  final double co2; // CO2 émis en grammes (adam)
  final int points; // Points gagnés (adam)
  final double securityScore; // Score sécurité du trajet (yassine)
  final DateTime date; // Date du trajet
  final bool isEco; // Trajet écologique ? (boolean)

  Trajets({
    required this.id,
    required this.userId,
    required this.startPoint,
    required this.endPoint,
    required this.mode,
    required this.co2,
    required this.points,
    required this.securityScore,
    required this.date,
    required this.isEco,
  });

  // Vers Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'startPoint': startPoint,
      'endPoint': endPoint,
      'mode': mode,
      'co2': co2,
      'points': points,
      'securityScore': securityScore,
      'date': date.toIso8601String(),
      'isEco': isEco,
    };
  }

  // Depuis Firebase
  factory Trajets.fromMap(Map<String, dynamic> map) {
    return Trajets(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      startPoint: map['startPoint'] ?? '',
      endPoint: map['endPoint'] ?? '',
      mode: map['mode'] ?? '',
      co2: (map['co2'] ?? 0).toDouble(),
      points: map['points'] ?? 0,
      securityScore: (map['securityScore'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      isEco: map['isEco'] ?? false,
    );
  }
}
