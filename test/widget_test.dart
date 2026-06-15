import 'package:devmobile/main.dart';
import 'package:devmobile/points_service.dart';
import 'package:devmobile/transport_screen.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('affiche les options de transport en francais', (tester) async {
    await tester.pumpWidget(const EcoSafe());

    expect(find.text('Modes de transport'), findsOneWidget);
    expect(find.text('123 Rue de la Paix'), findsOneWidget);
    expect(find.text('45 Avenue des Champs'), findsOneWidget);
    expect(find.text('Système de points'), findsOneWidget);
    expect(find.text('Options disponibles'), findsOneWidget);

    final premiereCarte = tester.widget<TransportModeCard>(
      find.byType(TransportModeCard).first,
    );

    expect(premiereCarte.transport.nom, 'Vélo');
    expect(premiereCarte.transport.pointsTotal, 40);
    expect(premiereCarte.estMeilleur, isTrue);
  });
}
