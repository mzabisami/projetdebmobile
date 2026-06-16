import 'package:flutter/foundation.dart';

import '../mocks/mock_data.dart';

class SessionPointsService {
  SessionPointsService._();

  static final SessionPointsService instance = SessionPointsService._();

  final ValueNotifier<int> points = ValueNotifier<int>(mockInitialPoints);

  void ajouterPoints(int valeur) {
    if (valeur <= 0) return;
    points.value += valeur;
  }

  bool depenserPoints(int valeur) {
    if (valeur <= 0) return true;
    if (points.value < valeur) return false;

    points.value -= valeur;
    return true;
  }
}
