import 'package:devmobile/fonctionnalites/carte/itineraire_services.dart';
import 'package:devmobile/fonctionnalites/carte/widgets/barre_mode_transport.dart';
import 'package:devmobile/fonctionnalites/carte/widgets/barre_zoom.dart';
import 'package:devmobile/fonctionnalites/carte/widgets/carte.dart';
import 'package:devmobile/fonctionnalites/carte/widgets/typeahead.dart';
import 'package:devmobile/composants/btn_icon_action.dart';
import 'package:devmobile/composants/barre_navigation.dart';
import 'package:devmobile/modeles/infos_trajets.dart';
import 'package:devmobile/modeles/zone_danger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme.dart';


class CartePage extends StatefulWidget {
  const CartePage({super.key});

  @override
  State<CartePage> createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  final MapController _mapController = MapController();
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _arriveeController = TextEditingController();

  List<ZoneDanger> zonesDanger = [
    ZoneDanger(LatLng(50.381, 3.475), 200, 1),
    ZoneDanger(LatLng(50.361, 3.485), 200, 2),
    ZoneDanger(LatLng(50.374, 3.465), 300, 3),
  ];
  
  Map<String, InfosTrajet> trajetsParMode = {
    'foot': InfosTrajet(modeTransport: 'foot'),
    'bike': InfosTrajet(modeTransport: 'bike'),
    'car': InfosTrajet(modeTransport: 'car'),
  };
  String modeTransportActuel = 'foot';

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
  }

  Future<void> _mettreAJourTrajet() async {
    if (trajetsParMode[modeTransportActuel]!.depart != null && trajetsParMode[modeTransportActuel]!.arrivee != null) {
      final newTrajets = await ItineraireServices.calculerTousTrajets(
        depart: trajetsParMode[modeTransportActuel]!.depart!,
        arrivee: trajetsParMode[modeTransportActuel]!.arrivee!,
        trajetsParMode: trajetsParMode,
      );
      setState(() {
        trajetsParMode = newTrajets;
      });
    }
  }

  void _appliquerSelectionLieu(LatLng coordonnes, String lieu, bool estDepart) {
    setState(() {
      trajetsParMode.forEach((mode, infos) {
        if (estDepart) {
          infos.depart = coordonnes;
        } else {
          infos.arrivee = coordonnes;
        }
      });
      if (estDepart) {
        _departController.text = lieu;
      } else {
        _arriveeController.text = lieu;
      }
    });
    _mapController.move(coordonnes, 15.0);
    _mettreAJourTrajet();
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
    _appliquerSelectionLieu(positionLatLng, nomLieu, true);
  }

  void _onModeTransportChange(String mode) {
    setState(() {
      modeTransportActuel = mode;
    });
    _mettreAJourTrajet();
  }

  void _echangerVilles() {
    LatLng? posDepart = trajetsParMode[modeTransportActuel]!.depart;
    LatLng? posArrivee = trajetsParMode[modeTransportActuel]!.arrivee;
    String txtDepart = _departController.text;
    String txtArrivee = _arriveeController.text;
    setState(() {
      trajetsParMode.forEach((mode, infos) {
        infos.depart = posArrivee;
        infos.arrivee = posDepart;
      });
      _departController.text = txtArrivee;
      _arriveeController.text = txtDepart;
    });
    _mettreAJourTrajet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoSafe', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Column(
          children: [
            Typeahead("D'où partez-vous ?", 
                    const Icon(Icons.my_location), _departController,
                    (coordonnees, lieu) => _appliquerSelectionLieu(coordonnees, lieu, true)
            ),
            Typeahead('Où voulez-vous aller ?', 
                    const Icon(Icons.location_pin), _arriveeController,
                    (coordonnees, lieu) => _appliquerSelectionLieu(coordonnees, lieu, false)
            ),

            Expanded(
              child: Stack(
                children: [
                  carte(trajetsParMode[modeTransportActuel]!.depart, trajetsParMode[modeTransportActuel]!.arrivee, trajetsParMode[modeTransportActuel]!.trajet, zonesDanger, _mapController),
                  barreModeTransport(modeTransportActuel, _onModeTransportChange),
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
                ],
              ),
            ),

            barreNavigation(),
          ],
        ),
      ),
    );
  }
}
