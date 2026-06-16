import 'package:devmobile/modeles/historique_trajets.dart';
import 'package:devmobile/modeles/infos_trajets.dart';
import 'package:devmobile/services/itineraire_service.dart';
import 'package:devmobile/services/points_service.dart';
import 'package:devmobile/services/route_history_service.dart';
import 'package:devmobile/services/session_points_service.dart';
import 'package:flutter/material.dart';

const Color vertEcoSafe = Color.fromARGB(255, 58, 183, 131);
const Color bleuSecurite = Color.fromARGB(255, 47, 115, 255);
const Color fondEcran = Color.fromARGB(255, 248, 250, 252);

DonneesTrajet trajetDepuisItineraire() {
  final trajet =
      ItineraireServices.trajetsParMode[ItineraireServices.modeActuel] ??
      InfosTrajet(mode: ItineraireServices.modeActuel);
  final distance = trajet.distance > 0
      ? trajet.distance
      : (ItineraireServices.trajetsParMode['car']?.distance ?? 0.0);
  return DonneesTrajet(
    depart: ItineraireServices.departLabel,
    arrivee: ItineraireServices.arriveeLabel,
    distanceKm: distance,
  );
}

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
    required this.routeMode,
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
  final String routeMode;
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
      routeMode: routeMode,
      co2Total: co2Total,
      pointsEco: pointsEco,
      pointsSecurite: pointsSecurite,
      pointsTotal: pointsEco + pointsSecurite,
    );
  }
}

const List<TransportMode> transportsMock = [
  TransportMode(
    nom: 'Velo',
    icone: Icons.pedal_bike,
    dureeMinutes: 15,
    co2ParKm: 0,
    securite: 92,
    routeMode: 'bike',
  ),
  TransportMode(
    nom: 'Metro',
    icone: Icons.directions_subway,
    dureeMinutes: 18,
    co2ParKm: 0.1,
    securite: 88,
    routeMode: 'foot',
  ),
  TransportMode(
    nom: 'Bus',
    icone: Icons.directions_bus,
    dureeMinutes: 22,
    co2ParKm: 0.16,
    securite: 78,
    routeMode: 'car',
  ),
  TransportMode(
    nom: 'Voiture',
    icone: Icons.directions_car,
    dureeMinutes: 12,
    co2ParKm: 0.46,
    securite: 65,
    routeMode: 'car',
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

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key, this.trajet, this.onStartTrip});

  final DonneesTrajet? trajet;
  final VoidCallback? onStartTrip;

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  static const String _demoUserId = 'demo-user';

  String? _transportSelectionne;

  @override
  Widget build(BuildContext context) {
    final trajetActuel = widget.trajet ?? trajetDepuisItineraire();
    final options = calculerOptionsTransport(
      trajet: trajetActuel,
      transports: transportsMock,
    );
    final meilleurChoix = options.first;
    final aDepartEtArrivee =
        ItineraireServices.depart != null && ItineraireServices.arrivee != null;

    final TransportMode? transportActif = _transportSelectionne == null
        ? null
        : options.firstWhere(
            (transport) => transport.nom == _transportSelectionne,
            orElse: () => meilleurChoix,
          );

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
          _resumeTrajet(trajetActuel),
          const SizedBox(height: 16),
          _cartePoints(),
          const SizedBox(height: 18),
          _titreOptions(),
          const SizedBox(height: 10),
          for (final transport in options)
            TransportModeCard(
              transport: transport,
              estMeilleur: transport.nom == meilleurChoix.nom,
              estSelectionne: transport.nom == _transportSelectionne,
              onTap: () {
                setState(() {
                  _transportSelectionne = transport.nom;
                });
              },
            ),
          _etatDemarrage(
            aDepartEtArrivee: aDepartEtArrivee,
            transportActif: transportActif,
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _resumeTrajet(DonneesTrajet trajetActuel) {
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
              Expanded(child: _adresse('De', trajetActuel.depart)),
              const Icon(Icons.arrow_forward, color: vertEcoSafe, size: 18),
              Expanded(child: _adresse('A', trajetActuel.arrivee)),
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
            '${trajetActuel.distanceKm.toStringAsFixed(1)} km recuperes depuis la carte',
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
                'Systeme de points',
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
            "Gagnez des points pour l'ecologie et la securite !",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniPoint(Icons.eco, 'Points Eco', 'Moins de CO2'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniPoint(
                  Icons.shield_outlined,
                  'Points Securite',
                  'Trajet plus sur',
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
          'Eco & sur',
          style: TextStyle(color: vertEcoSafe, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _bannierePoints(TransportMode transportActif) {
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
              '${transportActif.nom} selectionne pour le depart.\n'
              'Ce trajet rapporte ${transportActif.pointsTotal} points : '
              '${transportActif.pointsEco} eco + '
              '${transportActif.pointsSecurite} securite.',
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etatDemarrage({
    required bool aDepartEtArrivee,
    required TransportMode? transportActif,
  }) {
    if (!aDepartEtArrivee) {
      return _messageDemarrage(
        icone: Icons.place_outlined,
        titre: 'Ajoutez votre depart et votre arrivee',
        description:
            'Le bouton demarrer apparait des que les deux points sont choisis sur la carte.',
        couleur: const Color.fromARGB(255, 255, 243, 227),
        bordure: const Color.fromARGB(255, 255, 205, 133),
        accent: const Color.fromARGB(255, 226, 125, 34),
      );
    }

    if (transportActif == null) {
      return _messageDemarrage(
        icone: Icons.directions_bus_outlined,
        titre: 'Choisissez un mode de transport',
        description:
            'Selectionnez une carte ci-dessus pour faire apparaitre le bouton demarrer.',
        couleur: const Color.fromARGB(255, 236, 248, 255),
        bordure: const Color.fromARGB(255, 175, 213, 255),
        accent: bleuSecurite,
      );
    }

    return Column(
      children: [
        _bannierePoints(transportActif),
        const SizedBox(height: 8),
        _boutonDemarrerTrajet(transportActif),
      ],
    );
  }

  Widget _messageDemarrage({
    required IconData icone,
    required String titre,
    required String description,
    required Color couleur,
    required Color bordure,
    required Color accent,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bordure),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(icone, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _boutonDemarrerTrajet(TransportMode transportActif) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _demarrerTrajet(transportActif),
        icon: const Icon(Icons.navigation),
        style: FilledButton.styleFrom(
          backgroundColor: vertEcoSafe,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        label: Text(
          'Demarrer le trajet en ${transportActif.nom}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  void _demarrerTrajet(TransportMode transportActif) {
    SessionPointsService.instance.ajouterPoints(transportActif.pointsTotal);
    RouteHistoryService().saveRoute(
      Trajets(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: _demoUserId,
        startPoint: ItineraireServices.departLabel,
        endPoint: ItineraireServices.arriveeLabel,
        mode: _nomModeHistorique(transportActif.nom),
        co2: transportActif.co2Total * 1000,
        points: transportActif.pointsTotal,
        securityScore: transportActif.securite.toDouble(),
        date: DateTime.now(),
        isEco: transportActif.nom != 'Voiture',
      ),
    );
    ItineraireServices.modeActuel = transportActif.routeMode;
    widget.onStartTrip?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Trajet lance en ${transportActif.nom} : +${transportActif.pointsTotal} points.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _nomModeHistorique(String nom) {
    switch (nom) {
      case 'Velo':
        return 'velo';
      case 'Metro':
        return 'metro';
      case 'Bus':
        return 'bus';
      case 'Voiture':
      default:
        return 'voiture';
    }
  }
}

class TransportModeCard extends StatelessWidget {
  const TransportModeCard({
    super.key,
    required this.transport,
    required this.estMeilleur,
    required this.estSelectionne,
    required this.onTap,
  });

  final TransportMode transport;
  final bool estMeilleur;
  final bool estSelectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        elevation: estSelectionne ? 3 : 1.5,
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: estSelectionne
                ? bleuSecurite
                : estMeilleur
                ? const Color.fromARGB(255, 89, 231, 166)
                : Colors.black12,
            width: estSelectionne || estMeilleur ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (estSelectionne || estMeilleur)
                Text(
                  estSelectionne
                      ? 'MODE SELECTIONNE - Pret a demarrer'
                      : 'MEILLEUR CHOIX - Le plus sur et ecologique',
                  style: TextStyle(
                    color: estSelectionne ? bleuSecurite : vertEcoSafe,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (estSelectionne || estMeilleur) const SizedBox(height: 10),
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
      ),
    );
  }

  Widget _iconeTransport() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: estSelectionne
            ? const Color.fromARGB(255, 225, 235, 255)
            : estMeilleur
            ? const Color.fromARGB(255, 211, 248, 228)
            : const Color.fromARGB(255, 244, 246, 248),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        transport.icone,
        color: estSelectionne
            ? bleuSecurite
            : estMeilleur
            ? vertEcoSafe
            : Colors.black87,
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
              '${transport.co2Total.toStringAsFixed(1)} kg CO2',
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
            '+${transport.pointsEco} pts eco',
            style: const TextStyle(
              color: vertEcoSafe,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (transport.pointsSecurite > 0)
          Text(
            '+${transport.pointsSecurite} pts securite',
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
