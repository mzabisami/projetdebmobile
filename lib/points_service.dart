class DonneesCalculPoints {
  const DonneesCalculPoints({
    required this.co2Mode,
    required this.co2Voiture,
    required this.scoreSecurite,
  });

  final double co2Mode;
  final double co2Voiture;
  final int scoreSecurite;
}

class ResultatPoints {
  const ResultatPoints({required this.pointsEco, required this.pointsSecurite});

  final int pointsEco;
  final int pointsSecurite;

  int get total => pointsEco + pointsSecurite;
}

class PointsService {
  PointsService({int soldeInitial = 0}) : _solde = soldeInitial;

  int _solde;

  ResultatPoints calculatePoints(DonneesCalculPoints route) {
    return ResultatPoints(
      pointsEco: calculerPointsEco(
        co2Mode: route.co2Mode,
        co2Voiture: route.co2Voiture,
      ),
      pointsSecurite: calculerPointsSecurite(route.scoreSecurite),
    );
  }

  int calculerPointsEco({required double co2Mode, required double co2Voiture}) {
    if (co2Voiture <= 0) return 0;

    final co2Evite = co2Voiture - co2Mode;
    final ratioEco = (co2Evite / co2Voiture).clamp(0, 1);

    return (ratioEco * 25).round();
  }

  int calculerPointsSecurite(int score) {
    if (score >= 90) return 15;
    if (score >= 75) return 8;
    if (score >= 60) return 5;
    return 0;
  }

  int getPointsBalance() {
    return _solde;
  }

  void ajouterPoints(int points) {
    if (points <= 0) return;
    _solde += points;
  }

  bool spendPoints(String id, int cost) {
    if (cost <= 0) return true;
    if (_solde < cost) return false;

    _solde -= cost;
    return true;
  }
}
