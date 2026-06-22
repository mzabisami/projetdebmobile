import 'package:devmobile/config/theme.dart';
import 'package:devmobile/main.dart';
import 'package:devmobile/mocks/mock_data.dart';
import 'package:devmobile/modeles/infos_trajets.dart';
import 'package:devmobile/navigation/tab_nav.dart';
import 'package:devmobile/screens/carte_screen.dart';
import 'package:devmobile/screens/shop_screen.dart';
import 'package:devmobile/screens/transport_screen.dart';
import 'package:devmobile/services/itineraire_service.dart';
import 'package:devmobile/services/points_service.dart';
import 'package:devmobile/services/session_points_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

const _testRewards = [
  Reward(
    id: 'bus_special',
    name: 'Ticket bus journee',
    description: 'Un ticket valable une journee.',
    cost: 120,
    available: true,
    category: 'Transport',
    icon: 'directions_bus',
    isSpecial: true,
    discountLabel: '-20%',
  ),
  Reward(
    id: 'coffee',
    name: 'Cafe offert',
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
    name: 'Reduction dejeuner',
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
    name: 'Kit velo securite',
    description: 'Lumiere, brassard reflechissant et sonnette.',
    cost: 600,
    available: false,
    category: 'Securite',
    icon: 'pedal_bike',
    isSpecial: false,
    discountLabel: '',
  ),
];

void main() {
  void resetItineraireState() {
    ItineraireServices.depart = null;
    ItineraireServices.arrivee = null;
    ItineraireServices.departLabel = 'Depart';
    ItineraireServices.arriveeLabel = 'Arrivee';
    ItineraireServices.modeActuel = 'foot';
    ItineraireServices.trajetsParMode = {
      'foot': InfosTrajet(mode: 'foot'),
      'bike': InfosTrajet(mode: 'bike'),
      'car': InfosTrajet(mode: 'car'),
    };
  }

  setUp(() {
    SessionPointsService.instance.points.value = mockInitialPoints;
    resetItineraireState();
  });

  Future<void> pumpEcoSafe(WidgetTester tester) async {
    await tester.pumpWidget(const EcoSafe());
    await tester.pump();
  }

  Future<void> pumpShop(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: ShopScreen(
            initialRewards: _testRewards,
            initialPoints: mockInitialPoints,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

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

  testWidgets('EcoSafe affiche la navigation et ouvre la carte', (
    tester,
  ) async {
    await pumpEcoSafe(tester);

    expect(find.byType(CartePage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Carte'), findsWidgets);
    expect(find.text('Transport'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
    expect(find.text('Boutique'), findsWidgets);
  });

  testWidgets('Transport utilise uniquement la navigation globale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const TabNav(initialIndex: 1),
      ),
    );
    await tester.pump();

    expect(find.byType(TransportScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Modes de transport'), findsOneWidget);
  });

  testWidgets(
    'Le bouton demarrer apparait quand depart arrivee et mode sont choisis',
    (tester) async {
      ItineraireServices.depart = const LatLng(50.361, 3.465);
      ItineraireServices.arrivee = const LatLng(50.381, 3.475);
      ItineraireServices.departLabel = 'Valenciennes Nord';
      ItineraireServices.arriveeLabel = 'Campus';
      ItineraireServices.trajetsParMode['car'] = InfosTrajet(
        mode: 'car',
        distance: 3.4,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: TransportScreen()),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Demarrer le trajet en'), findsNothing);

      await tester.tap(find.byType(TransportModeCard).first);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('Demarrer le trajet en'),
        240,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Demarrer le trajet en Velo'), findsOneWidget);
      expect(find.textContaining('Ce trajet rapporte'), findsOneWidget);
    },
  );

  testWidgets('Le bouton demarrer lance le trajet et credite les points', (
    tester,
  ) async {
    ItineraireServices.depart = const LatLng(50.361, 3.465);
    ItineraireServices.arrivee = const LatLng(50.381, 3.475);
    ItineraireServices.departLabel = 'Valenciennes Nord';
    ItineraireServices.arriveeLabel = 'Campus';
    ItineraireServices.trajetsParMode['car'] = InfosTrajet(
      mode: 'car',
      distance: 3.4,
    );

    var trajetLance = false;
    final soldeInitial = SessionPointsService.instance.points.value;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: TransportScreen(
            onStartTrip: () {
              trajetLance = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(TransportModeCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Demarrer le trajet en Velo'),
      240,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demarrer le trajet en Velo'));
    await tester.pump();

    expect(trajetLance, isTrue);
    expect(SessionPointsService.instance.points.value, soldeInitial + 40);
    expect(ItineraireServices.modeActuel, 'bike');
    expect(find.textContaining('Trajet lance en Velo'), findsOneWidget);
  });

  testWidgets('Boutique affiche les recompenses mockees', (tester) async {
    await pumpShop(tester);

    expect(find.text('Mes points'), findsOneWidget);
    expect(find.text('320 pts'), findsOneWidget);
    expect(find.text('Ticket bus journee'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus), findsWidgets);
    expect(find.byIcon(Icons.local_cafe), findsWidgets);

    await tester.scrollUntilVisible(find.text('Kit velo securite'), 300);
    await tester.pump();

    expect(find.text('Kit velo securite'), findsOneWidget);
  });

  testWidgets('Echanger une recompense deduit les points', (tester) async {
    await pumpShop(tester);

    await tester.tap(find.byIcon(Icons.redeem).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('200 pts'), findsOneWidget);
  });

  testWidgets('ShopScreen est reutilisable hors navigation', (tester) async {
    await pumpShop(tester);

    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('Mes points'), findsOneWidget);
  });

  test(
    'utilise les coordonnees et la distance de l itineraire pour le transport',
    () {
      ItineraireServices.depart = const LatLng(50.361, 3.465);
      ItineraireServices.arrivee = const LatLng(50.381, 3.475);
      ItineraireServices.departLabel = 'Valenciennes Nord';
      ItineraireServices.arriveeLabel = 'Campus';
      ItineraireServices.modeActuel = 'car';
      ItineraireServices.trajetsParMode['car'] = InfosTrajet(
        mode: 'car',
        distance: 3.4,
      );

      final trajet = trajetDepuisItineraire();

      expect(trajet.depart, 'Valenciennes Nord');
      expect(trajet.arrivee, 'Campus');
      expect(trajet.distanceKm, 3.4);
    },
  );
}
