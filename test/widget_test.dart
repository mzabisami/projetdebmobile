import 'package:devmobile/config/theme.dart';
import 'package:devmobile/main.dart';
import 'package:devmobile/mocks/mock_data.dart';
import 'package:devmobile/modeles/infos_trajets.dart';
import 'package:devmobile/screens/shop_screen.dart';
import 'package:devmobile/services/itineraire_service.dart';
import 'package:devmobile/transport_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

const _testRewards = [
  Reward(
    id: 'bus_special',
    name: 'Ticket bus journée',
    description: 'Un ticket valable une journée.',
    cost: 120,
    available: true,
    category: 'Transport',
    icon: 'directions_bus',
    isSpecial: true,
    discountLabel: '-20%',
  ),
  Reward(
    id: 'coffee',
    name: 'Café offert',
    description: 'Une boisson chaude chez un partenaire.',
    cost: 80,
    available: true,
    category: 'Partenaire',
    icon: 'local_cafe',
    isSpecial: false,
    discountLabel: '',
  ),
  Reward(
    id: 'lunch',
    name: 'Réduction déjeuner',
    description: 'Une remise dans une cantine partenaire.',
    cost: 220,
    available: true,
    category: 'Food',
    icon: 'restaurant',
    isSpecial: false,
    discountLabel: '',
  ),
  Reward(
    id: 'voucher',
    name: "Bon d'achat",
    description: "Un bon d'achat utilisable dans la boutique.",
    cost: 450,
    available: true,
    category: 'Shopping',
    icon: 'shopping_bag',
    isSpecial: false,
    discountLabel: '',
  ),
  Reward(
    id: 'bike_kit',
    name: 'Kit vélo sécurité',
    description: 'Lumière, brassard réfléchissant et sonnette.',
    cost: 600,
    available: false,
    category: 'Sécurité',
    icon: 'pedal_bike',
    isSpecial: false,
    discountLabel: '',
  ),
];

void main() {
  Future<void> pumpEcoSafe(WidgetTester tester) async {
    await tester.pumpWidget(const EcoSafe());
    await tester.pump();
  }

  Future<void> pumpShop(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: ShopScreen(initialRewards: _testRewards)),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('EcoSafe affiche la navigation et la boutique', (tester) async {
    await pumpEcoSafe(tester);

    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('Carte'), findsWidgets);
    expect(find.text('Transport'), findsWidgets);
    expect(find.text('Sécurité'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
    expect(find.text('Boutique'), findsWidgets);
  });

  testWidgets('Boutique affiche les récompenses mockées', (tester) async {
    await pumpShop(tester);

    expect(find.text('Mes points'), findsOneWidget);
    expect(find.text('320 pts'), findsOneWidget);
    expect(find.text('Offre spéciale'), findsOneWidget);
    expect(find.text('Ticket bus journée'), findsOneWidget);
    expect(find.text('Café offert'), findsOneWidget);
    expect(find.text('Réduction déjeuner'), findsOneWidget);

    await tester.scrollUntilVisible(find.text("Bon d'achat"), 300);
    await tester.pump();

    expect(find.text("Bon d'achat"), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Kit vélo sécurité'), 300);
    await tester.pump();

    expect(find.text('Kit vélo sécurité'), findsOneWidget);
  });

  testWidgets('Échanger une récompense déduit les points', (tester) async {
    await pumpShop(tester);

    await tester.tap(find.text('Échanger').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('200 pts'), findsOneWidget);
    expect(find.textContaining('Récompense échangée'), findsOneWidget);
  });

  testWidgets('Une récompense trop chère ou indisponible affiche Bientôt', (
    tester,
  ) async {
    await pumpShop(tester);

    await tester.scrollUntilVisible(find.text("Bon d'achat"), 300);
    await tester.pump();

    expect(find.text('Bientôt'), findsWidgets);
  });

  testWidgets('ShopScreen est réutilisable hors navigation', (tester) async {
    await pumpShop(tester);

    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('Mes points'), findsOneWidget);
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
