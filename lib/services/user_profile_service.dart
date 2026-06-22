import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeles/profil_utilisateur.dart';

class UserProfileService {
  CollectionReference get _collection =>
      FirebaseFirestore.instance.collection('users');

  // Crée ou écrase le document profil dans Firestore
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _collection.doc(profile.id).set(profile.toMap());
    } catch (e) {
      // erreur silencieuse
    }
  }

  // Stream temps réel du profil utilisateur
  Stream<UserProfile> watchUserProfile(String userId) {
    return _collection.doc(userId).snapshots().map((DocumentSnapshot doc) {
      final Object? data = doc.data();
      if (data == null) {
        return UserProfile(
          id: userId,
          name: '',
          email: '',
          totalPoints: 0,
          totalRoutes: 0,
          ecoRoutes: 0,
        );
      }
      return UserProfile.fromMap(data as Map<String, dynamic>);
    });
  }

  // Incrémente les compteurs après chaque trajet sauvegardé
  Future<void> incrementStats(String userId, int points, bool isEco) async {
    try {
      await _collection.doc(userId).update({
        'totalPoints': FieldValue.increment(points),
        'totalRoutes': FieldValue.increment(1),
        'ecoRoutes': FieldValue.increment(isEco ? 1 : 0),
      });
    } catch (e) {
      // erreur silencieuse
    }
  }
}
