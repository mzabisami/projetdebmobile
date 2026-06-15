import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeles/historique_trajets.dart';
import 'user_profile_service.dart';

class RouteHistoryService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'routes',
  );

  final UserProfileService _profileService = UserProfileService();

  // points = (ecoScore × 0.5 + securityScore × 0.5).round()
  // ecoScore vaut 100 si trajet écologique, 0 sinon
  static int computePoints(double securityScore, bool isEco) {
    final double ecoScore = isEco ? 100.0 : 0.0;
    return (ecoScore * 0.5 + securityScore / 100 * 0.5 * 100).round();
  }

  // Sauvegarde un trajet et incrémente les stats du profil utilisateur
  Future<void> saveRoute(Trajets route) async {
    try {
      final int points = computePoints(route.securityScore, route.isEco);
      final Map<String, dynamic> data = route.toMap();
      data['points'] = points;
      await _collection.doc(route.id).set(data);
      await _profileService.incrementStats(route.userId, points, route.isEco);
    } catch (e) {
      // erreur silencieuse — l'appelant gère l'état d'erreur
    }
  }

  // Tous les Trajets d'un utilisateur, du plus récent au plus ancien
  Future<List<Trajets>> getRoutesForUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((QueryDocumentSnapshot doc) {
        return Trajets.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Trajets des 7 derniers jours
  Future<List<Trajets>> getWeeklyRoutes(String userId) async {
    final DateTime sevenDaysAgo = DateTime.now().subtract(
      const Duration(days: 7),
    );
    try {
      final QuerySnapshot snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThan: sevenDaysAgo.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((QueryDocumentSnapshot doc) {
        return Trajets.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Trajets des 30 derniers jours
  Future<List<Trajets>> getMonthlyRoutes(String userId) async {
    final DateTime thirtyDaysAgo = DateTime.now().subtract(
      const Duration(days: 30),
    );
    try {
      final QuerySnapshot snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThan: thirtyDaysAgo.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((QueryDocumentSnapshot doc) {
        return Trajets.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Statistiques agrégées (une seule requête Future)
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final List<Trajets> allRoutes = await getRoutesForUser(userId);
      final List<Trajets> weekRoutes = await getWeeklyRoutes(userId);
      final List<Trajets> monthRoutes = await getMonthlyRoutes(userId);

      final int totalPoints = allRoutes.fold(
        0,
        (int s, Trajets r) => s + r.points,
      );
      final double totalCo2 = allRoutes.fold(
        0.0,
        (double s, Trajets r) => s + r.co2,
      );
      final int ecoRoutes = allRoutes.where((Trajets r) => r.isEco).length;
      final double avgSecurity = allRoutes.isEmpty
          ? 0
          : allRoutes.fold(0.0, (double s, Trajets r) => s + r.securityScore) /
                allRoutes.length;

      return {
        'totalRoutes': allRoutes.length,
        'totalPoints': totalPoints,
        'totalCo2': totalCo2,
        'ecoRoutes': ecoRoutes,
        'avgSecurity': avgSecurity,
        'weekRoutes': weekRoutes.length,
        'weekPoints': weekRoutes.fold(0, (int s, Trajets r) => s + r.points),
        'weekCo2': weekRoutes.fold(0.0, (double s, Trajets r) => s + r.co2),
        'monthRoutes': monthRoutes.length,
        'monthPoints': monthRoutes.fold(0, (int s, Trajets r) => s + r.points),
        'monthCo2': monthRoutes.fold(0.0, (double s, Trajets r) => s + r.co2),
      };
    } catch (e) {
      return {};
    }
  }

  // Stream temps réel des statistiques — se met à jour à chaque trajet sauvegardé
  Stream<Map<String, dynamic>> watchUserStats(String userId) {
    return _collection.where('userId', isEqualTo: userId).snapshots().map((
      QuerySnapshot snapshot,
    ) {
      final List<Trajets> allRoutes = snapshot.docs
          .map(
            (QueryDocumentSnapshot doc) =>
                Trajets.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      final DateTime sevenDaysAgo = DateTime.now().subtract(
        const Duration(days: 7),
      );
      final DateTime thirtyDaysAgo = DateTime.now().subtract(
        const Duration(days: 30),
      );

      final List<Trajets> weekRoutes = allRoutes
          .where((Trajets r) => r.date.isAfter(sevenDaysAgo))
          .toList();
      final List<Trajets> monthRoutes = allRoutes
          .where((Trajets r) => r.date.isAfter(thirtyDaysAgo))
          .toList();

      final int totalPoints = allRoutes.fold(
        0,
        (int s, Trajets r) => s + r.points,
      );
      final double totalCo2 = allRoutes.fold(
        0.0,
        (double s, Trajets r) => s + r.co2,
      );
      final int ecoRoutes = allRoutes.where((Trajets r) => r.isEco).length;
      final double avgSecurity = allRoutes.isEmpty
          ? 0.0
          : allRoutes.fold(0.0, (double s, Trajets r) => s + r.securityScore) /
                allRoutes.length;

      return {
        'totalRoutes': allRoutes.length,
        'totalPoints': totalPoints,
        'totalCo2': totalCo2,
        'ecoRoutes': ecoRoutes,
        'avgSecurity': avgSecurity,
        'weekRoutes': weekRoutes.length,
        'weekPoints': weekRoutes.fold(0, (int s, Trajets r) => s + r.points),
        'weekCo2': weekRoutes.fold(0.0, (double s, Trajets r) => s + r.co2),
        'monthRoutes': monthRoutes.length,
        'monthPoints': monthRoutes.fold(0, (int s, Trajets r) => s + r.points),
        'monthCo2': monthRoutes.fold(0.0, (double s, Trajets r) => s + r.co2),
      };
    });
  }
}
