import 'package:devmobile/services/itineraire_service.dart';
import 'package:devmobile/screens/carte_widgets/barre_mode_transport.dart';
import 'package:devmobile/screens/carte_widgets/barre_zoom.dart';
import 'package:devmobile/screens/carte_widgets/carte.dart';
import 'package:devmobile/screens/carte_widgets/typeahead.dart';
import 'package:devmobile/screens/carte_widgets/bandeau_infos_trajet.dart';
import 'package:devmobile/screens/carte_widgets/btn_icon_action.dart';
import 'package:devmobile/modeles/zone_danger.dart';
import 'package:devmobile/services/security_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:devmobile/config/theme.dart';


class CartePage extends StatefulWidget {
  const CartePage({super.key});

  @override
  State<CartePage> createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  final MapController _mapController = MapController();
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _arriveeController = TextEditingController();

  List<ZoneDanger> zonesDanger = [];

  @override
  void initState() {
    super.initState();
    _chargerZonesDanger();
  }

  Future<void> _chargerZonesDanger() async {
    final service = SecurityService();
    await service.loadZones();
    final List<Future<ZoneDanger>> futures = service.getZones().map((zoneSecu) async{
      double score = await service.getScoreForPosition(zoneSecu.latitude, zoneSecu.longitude);
      int niv;
      if (score < 40) {
        niv = 1;
      } else if (score < 80) {
        niv = 2;
      } else {
        niv = 3;
      }
      return ZoneDanger(LatLng(zoneSecu.latitude, zoneSecu.longitude), 20000, niv);
    }).toList();

    final List<ZoneDanger> zones = await Future.wait(futures);

    if (mounted) {
      setState(() {
        zonesDanger = zones;
      });
    }
  }

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
  }

  Future<void> _appliquerSelectionLieu(LatLng coordonnes, String lieu, bool estDepart) async {
    if (estDepart) {
      _departController.text = lieu;
      ItineraireServices.depart = coordonnes;
    } else {
      _arriveeController.text = lieu;
      ItineraireServices.arrivee = coordonnes;
    }
    if (ItineraireServices.depart != null && ItineraireServices.arrivee != null) {
      await ItineraireServices.calculerTousTrajets();
      _recadrerCarte();
    } else {
      _mapController.move(coordonnes, 15.0);
    }
    setState(() {});
  }

  Future<void> _rechercherPositionActuelle() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    LatLng positionLatLng = LatLng(position.latitude, position.longitude);
    
    final nomLieu = await ItineraireServices.getNomLieu(positionLatLng);
    await _appliquerSelectionLieu(positionLatLng, nomLieu, true);
  }

  Future<void> _echangerVilles() async {
    LatLng? tempPos = ItineraireServices.depart;
    ItineraireServices.depart = ItineraireServices.arrivee;
    ItineraireServices.arrivee = tempPos;

    String tempTxt = _departController.text;
    _departController.text = _arriveeController.text;
    _arriveeController.text = tempTxt;

    await ItineraireServices.calculerTousTrajets();
    _recadrerCarte();
    setState(() {});
  }

  void _onModeTransportChange(String mode) {
    setState(() {
      ItineraireServices.modeActuel = mode;
    });
  }

  void _recadrerCarte() {
    if (ItineraireServices.depart != null && ItineraireServices.arrivee != null) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(ItineraireServices.depart!, ItineraireServices.arrivee!),
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  void _recentrerSurLieu(bool estDepart) {
    final coords = estDepart ? ItineraireServices.depart : ItineraireServices.arrivee;
    if (coords != null) {
      _mapController.move(coords, 15.0);
    }
  }

  Widget _buildZoneCarte() {
    return Expanded(
      child: Stack(
        children: [
          carte(ItineraireServices.depart, 
            ItineraireServices.arrivee, 
            ItineraireServices.trajetsParMode[ItineraireServices.modeActuel]?.trajet ?? [], 
            zonesDanger, _mapController
          ),
          barreModeTransport(ItineraireServices.modeActuel, _onModeTransportChange),
          barreZoom(_mapController),
          Positioned(
            top: 5,
            left: 5,
            child: btnIcon(Icons.my_location, () => _rechercherPositionActuelle())
          ),
          Positioned(
            top: 5,
            right: 5,
            child: btnIcon(Icons.swap_horiz, () => _echangerVilles())
          ),
          bandeauInfosTrajet(),
        ],
      ),
    );
  }

  Widget _buildBarreRecherche() {
    return Column(
      children: [
        Typeahead("D'où partez-vous ?", const Icon(Icons.my_location), _departController,
          onSelected: (coordonnees, lieu) => _appliquerSelectionLieu(coordonnees, lieu, true),
          onClick: () => _recentrerSurLieu(true)
        ),
        Typeahead('Où voulez-vous aller ?', const Icon(Icons.location_pin), _arriveeController,
          onSelected: (coordonnees, lieu) => _appliquerSelectionLieu(coordonnees, lieu, false),
          onClick: () => _recentrerSurLieu(false)
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoSafe', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Column(
          children: [
            _buildBarreRecherche(),
            _buildZoneCarte(),
          ],
        ),
      ),
    );
  }
}
