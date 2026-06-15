import 'package:devmobile/points_service.dart';
import 'package:flutter/material.dart';

const Color vertEcoSafe = Color.fromARGB(255, 58, 183, 131);
const Color bleuSecurite = Color.fromARGB(255, 47, 115, 255);
const Color fondEcran = Color.fromARGB(255, 248, 250, 252);

class DonneesTrajet {
  const DonneesTrajet({
    required this.depart,
    required this.arrivee,
    required this.distanceKm,
  });

  final String depart;
  final String arrivee;
  final double distanceKm;
}

class TransportMode {
  const TransportMode({
    required this.nom,
    required this.icone,
    required this.dureeMinutes,
    required this.co2ParKm,
    required this.securite,
    this.co2Total = 0,
    this.pointsEco = 0,
    this.pointsSecurite = 0,
    this.pointsTotal = 0,
  });

  final String nom;
  final IconData icone;
  final int dureeMinutes;
  final double co2ParKm;
  final int securite;
  final double co2Total;
  final int pointsEco;
  final int pointsSecurite;
  final int pointsTotal;

  TransportMode avecCalculs({
    required double co2Total,
    required int pointsEco,
    required int pointsSecurite,
  }) {
    return TransportMode(
      nom: nom,
      icone: icone,
      dureeMinutes: dureeMinutes,
      co2ParKm: co2ParKm,
      securite: securite,
      co2Total: co2Total,
      pointsEco: pointsEco,
      pointsSecurite: pointsSecurite,
      pointsTotal: pointsEco + pointsSecurite,
    );
  }
}

const DonneesTrajet trajetExemple = DonneesTrajet(
  depart: '123 Rue de la Paix',
  arrivee: '45 Avenue des Champs',
  distanceKm: 5,
);

const List<TransportMode> transportsMock = [
  TransportMode(
    nom: 'Vélo',
    icone: Icons.pedal_bike,
    dureeMinutes: 15,
    co2ParKm: 0,
    securite: 92,
  ),
  TransportMode(
    nom: 'Métro',
    icone: Icons.directions_subway,
    dureeMinutes: 18,
    co2ParKm: 0.1,
    securite: 88,
  ),
  TransportMode(
    nom: 'Bus',
    icone: Icons.directions_bus,
    dureeMinutes: 22,
    co2ParKm: 0.16,
    securite: 78,
  ),
  TransportMode(
    nom: 'Voiture',
    icone: Icons.directions_car,
    dureeMinutes: 12,
    co2ParKm: 0.46,
    securite: 65,
  ),
];

List<TransportMode> calculerOptionsTransport({
  required DonneesTrajet trajet,
  required List<TransportMode> transports,
}) {
  final pointsService = PointsService();

  final voiture = transports.firstWhere((transport) {
    return transport.nom == 'Voiture';
  });
  final co2Voiture = voiture.co2ParKm * trajet.distanceKm;

  final options = transports.map((transport) {
    final co2Total = transport.co2ParKm * trajet.distanceKm;

    final points = pointsService.calculatePoints(
      DonneesCalculPoints(
        co2Mode: co2Total,
        co2Voiture: co2Voiture,
        scoreSecurite: transport.securite,
      ),
    );

    return transport.avecCalculs(
      co2Total: co2Total,
      pointsEco: points.pointsEco,
      pointsSecurite: points.pointsSecurite,
    );
  }).toList();

  options.sort((a, b) => b.pointsTotal.compareTo(a.pointsTotal));
  return options;
}

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key, this.trajet = trajetExemple});

  // Plus tard, la page Carte appellera TransportScreen(trajet: vraiesDonnees).
  final DonneesTrajet trajet;

  @override
  Widget build(BuildContext context) {
    final options = calculerOptionsTransport(
      trajet: trajet,
      transports: transportsMock,
    );
    final meilleurChoix = options.first;

    return Scaffold(
      backgroundColor: fondEcran,
      appBar: AppBar(
        title: const Text(
          'Modes de transport',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: vertEcoSafe,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _resumeTrajet(),
          const SizedBox(height: 16),
          _cartePoints(),
          const SizedBox(height: 18),
          _titreOptions(),
          const SizedBox(height: 10),
          for (final transport in options)
            TransportModeCard(
              transport: transport,
              estMeilleur: transport.nom == meilleurChoix.nom,
            ),
          _bannierePoints(meilleurChoix),
        ],
      ),
      bottomNavigationBar: _navigationBas(),
    );
  }

  Widget _resumeTrajet() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 248, 255),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _adresse('De', trajet.depart)),
              const Icon(Icons.arrow_forward, color: vertEcoSafe, size: 18),
              Expanded(child: _adresse('À', trajet.arrivee)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 0.72,
              minHeight: 4,
              color: vertEcoSafe,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${trajet.distanceKm.toStringAsFixed(1)} km récupérés depuis la carte',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _adresse(String titre, String adresse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          adresse,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _cartePoints() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 180, 130),
            Color.fromARGB(255, 47, 115, 255),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Système de points',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Gagnez des points pour l'écologie et la sécurité !",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniPoint(Icons.eco, 'Points Éco', 'Moins de CO₂'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniPoint(
                  Icons.shield_outlined,
                  'Points Sécurité',
                  'Trajet plus sûr',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniPoint(IconData icone, String titre, String texte) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: Colors.white, size: 18),
          const SizedBox(height: 6),
          Text(
            titre,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            texte,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _titreOptions() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Options disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Icon(Icons.eco, color: vertEcoSafe, size: 16),
        SizedBox(width: 4),
        Text(
          'Éco & sûr',
          style: TextStyle(color: vertEcoSafe, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _bannierePoints(TransportMode meilleurChoix) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 232, 251, 245),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromARGB(255, 111, 226, 184)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 0, 177, 190),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${meilleurChoix.nom} maximise vos points !\n'
              'Ce trajet rapporte ${meilleurChoix.pointsTotal} points : '
              '${meilleurChoix.pointsEco} éco + '
              '${meilleurChoix.pointsSecurite} sécurité.',
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationBas() {
    return NavigationBar(
      selectedIndex: 1,
      height: 66,
      backgroundColor: Colors.white,
      indicatorColor: const Color.fromARGB(255, 220, 250, 235),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Carte'),
        NavigationDestination(
          icon: Icon(Icons.directions_bus),
          label: 'Transport',
        ),
        NavigationDestination(
          icon: Icon(Icons.shield_outlined),
          label: 'Sécurité',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Boutique',
        ),
      ],
    );
  }
}

class TransportModeCard extends StatelessWidget {
  const TransportModeCard({
    super.key,
    required this.transport,
    required this.estMeilleur,
  });

  final TransportMode transport;
  final bool estMeilleur;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: estMeilleur
              ? const Color.fromARGB(255, 89, 231, 166)
              : Colors.black12,
          width: estMeilleur ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (estMeilleur)
              const Text(
                'MEILLEUR CHOIX - Le plus sûr et écologique',
                style: TextStyle(
                  color: vertEcoSafe,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (estMeilleur) const SizedBox(height: 10),
            Row(
              children: [
                _iconeTransport(),
                const SizedBox(width: 12),
                Expanded(child: _detailsTransport()),
                _pointsTotal(),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: _bonusPoints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconeTransport() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: estMeilleur
            ? const Color.fromARGB(255, 211, 248, 228)
            : const Color.fromARGB(255, 244, 246, 248),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        transport.icone,
        color: estMeilleur ? vertEcoSafe : Colors.black87,
      ),
    );
  }

  Widget _detailsTransport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              transport.nom,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.eco, color: vertEcoSafe, size: 16),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _info(Icons.access_time, '${transport.dureeMinutes} min'),
            _info(
              Icons.cloud_outlined,
              '${transport.co2Total.toStringAsFixed(1)} kg CO₂',
            ),
            _info(Icons.shield_outlined, '${transport.securite}/100'),
          ],
        ),
      ],
    );
  }

  Widget _info(IconData icone, String texte) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, color: Colors.black54, size: 13),
        const SizedBox(width: 4),
        Text(texte, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _pointsTotal() {
    if (transport.pointsTotal <= 5) {
      return const SizedBox(width: 58);
    }

    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 195, 249, 220),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '+${transport.pointsTotal}',
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 150, 100),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'pts total',
            style: TextStyle(color: Colors.black45, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _bonusPoints() {
    if (transport.pointsEco <= 0 && transport.pointsSecurite <= 5) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 18,
      runSpacing: 4,
      children: [
        if (transport.pointsEco > 0)
          Text(
            '+${transport.pointsEco} pts éco',
            style: const TextStyle(
              color: vertEcoSafe,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (transport.pointsSecurite > 0)
          Text(
            '+${transport.pointsSecurite} pts sécurité',
            style: const TextStyle(
              color: bleuSecurite,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
