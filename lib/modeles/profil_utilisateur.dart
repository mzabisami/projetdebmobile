class UserProfile {
  final String id;          // UID Firebase
  final String name;        // Prénom
  final String email;
  final int totalPoints;    // Points cumulés
  final int totalRoutes;    // Nombre de trajets effectués
  final int ecoRoutes;      // Nombre de trajets écologiques

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.totalPoints,
    required this.totalRoutes,
    required this.ecoRoutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id':          id,
      'name':        name,
      'email':       email,
      'totalPoints': totalPoints,
      'totalRoutes': totalRoutes,
      'ecoRoutes':   ecoRoutes,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id:          map['id']          ?? '',
      name:        map['name']        ?? '',
      email:       map['email']       ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      totalRoutes: map['totalRoutes'] ?? 0,
      ecoRoutes:   map['ecoRoutes']   ?? 0,
    );
  }
}
