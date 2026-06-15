import 'package:cloud_firestore/cloud_firestore.dart';

class SignalementService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('signalements');

  // Score de danger basé sur les signalements communautaires (~500m autour du point)
  Future<double> getDangerScore(double lat, double lon) async {
    try {
      // Firestore n'autorise qu'un seul filtre de plage → on filtre lat côté serveur,
      // puis lon côté client
      final QuerySnapshot snapshot = await _collection
          .where('lat', isGreaterThan: lat - 0.005)
          .where('lat', isLessThan:    lat + 0.005)
          .get();

      final int count = snapshot.docs.where((QueryDocumentSnapshot doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final double docLon = (data['lon'] as num?)?.toDouble() ?? 0.0;
        return docLon >= lon - 0.005 && docLon <= lon + 0.005;
      }).length;

      return (count / 10).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }
}
