import 'package:devmobile/fonctionnalites/carte/itineraire_services.dart';
import 'package:devmobile/main.dart';
import 'package:devmobile/modeles/infos_trajets.dart';
import 'package:devmobile/points_service.dart';
import 'package:devmobile/transport_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('Dev 2 calcule les points eco et securite', () {
    final pointsService = PointsService();

    final resultat = pointsService.calculatePoints(
      const DonneesCalculPoints(co2Mode: 0, co2Voiture: 2.3, scoreSecurite: 92),
    );

    expect(resultat.pointsEco, 25);
    expect(resultat.pointsSecurite, 15);
    expect(resultat.total, 40);
  });

  test('Dev 2 gere le solde et les depenses de points', () {
    final pointsService = PointsService(soldeInitial: 50);

    expect(pointsService.getPointsBalance(), 50);
    expect(pointsService.spendPoints('recompense_bus', 20), isTrue);
    expect(pointsService.getPointsBalance(), 30);
    expect(pointsService.spendPoints('recompense_trop_chere', 40), isFalse);
    expect(pointsService.getPointsBalance(), 30);
  });

  testWidgets('affiche la page de carte au démarrage', (tester) async {
    await tester.pumpWidget(const EcoSafe());

    expect(find.text('EcoSafe'), findsOneWidget);
    expect(find.text("D'où partez-vous ?"), findsOneWidget);
    expect(find.text('Où voulez-vous aller ?'), findsOneWidget);
  });

  test('utilise les coordonnées et la distance de l itineraire pour le transport', () {
    ItineraireServices.depart = const LatLng(50.361, 3.465);
    ItineraireServices.arrivee = const LatLng(50.381, 3.475);
    ItineraireServices.departLabel = 'Valenciennes Nord';
    ItineraireServices.arriveeLabel = 'Campus';
    ItineraireServices.trajetsParMode['car'] = InfosTrajet(mode: 'car', distance: 3.4);

    final trajet = trajetDepuisItineraire();

    expect(trajet.depart, 'Valenciennes Nord');
    expect(trajet.arrivee, 'Campus');
    expect(trajet.distanceKm, 3.4);
  });
}
