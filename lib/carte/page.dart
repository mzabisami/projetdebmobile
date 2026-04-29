import 'package:devmobile/composants.dart';
import 'package:devmobile/carte/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../theme.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';


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

  Future<void> _rechercherPositionActuelle() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Les services de localisation sont désactivés.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permission de localisation refusée.');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng positionLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      trajetsParMode[modeTransportActuel]!.depart = positionLatLng;
      _mapController.move(positionLatLng, 15.0);
      _afficherNomVille(positionLatLng, true);
      _calculerTrajets();
    });
  }

  Future<void> _afficherNomVille(LatLng point, bool estDepart) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String nomVille = data['display_name'] ?? 'Ville inconnue';
        
        setState(() {
          if (estDepart) {
            _departController.text = nomVille;
          } else {
            _arriveeController.text = nomVille;
          }
        });
      }
    } catch (e) {
      print('Erreur lors de la recherche du nom de la ville : $e');
    }
  }

  Future<void> _rechercherVille(String ville, bool estDepart) async {
    String villeTrim = ville.trim();
    if (villeTrim.isEmpty) return;

    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$ville&format=json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          
          setState(() {
            if (estDepart) {
              trajetsParMode[modeTransportActuel]!.depart = LatLng(lat, lon);
            } else {
              trajetsParMode[modeTransportActuel]!.arrivee = LatLng(lat, lon);
            }
            _mapController.move(LatLng(lat, lon), 15.0);
          });
          
          _calculerTrajets();
        }
      }
    } catch (e) {
      print('Erreur lors de la recherche de la ville : $e');
    }
  }

  Future<void> _calculerTrajets() async {
    if (trajetsParMode[modeTransportActuel]!.depart == null || trajetsParMode[modeTransportActuel]!.arrivee == null) return;
    
    List<String> modes = ['foot', 'bike', 'car'];

    for (String mode in modes) {
      trajetsParMode[mode]!.depart = trajetsParMode[modeTransportActuel]!.depart;
      trajetsParMode[mode]!.arrivee = trajetsParMode[modeTransportActuel]!.arrivee;
      final url = Uri.parse('https://routing.openstreetmap.de/routed-$mode/route/v1/driving/'
          '${trajetsParMode[mode]!.depart!.longitude},${trajetsParMode[mode]!.depart!.latitude};'
          '${trajetsParMode[mode]!.arrivee!.longitude},${trajetsParMode[mode]!.arrivee!.latitude}?overview=full&geometries=geojson'
      );

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final coords = data['routes'][0]['geometry']['coordinates'];

            setState(() {
              trajetsParMode[mode]!.trajet = coords.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
              trajetsParMode[mode]!.distance = data['routes'][0]['distance'] / 1000; // Convertir en km
              trajetsParMode[mode]!.duree = (data['routes'][0]['duration'] / 60).round(); // Convertir en minutes
              _calculerCo2(mode);
            });

            print('---');
            print(trajetsParMode[mode]!.modeTransport);
            print(trajetsParMode[mode]!.distance);
            print(trajetsParMode[mode]!.duree);
            print(trajetsParMode[mode]!.co2);
            print('---');

          }
        }
      } catch (e) {
        print('Erreur lors du calcul du trajet : $e');
      }    
    }
  }

  void _calculerCo2(String mode) {
    if (trajetsParMode[mode]!.trajet == null) return;

    setState(() {
      trajetsParMode[mode]!.co2 = trajetsParMode[mode]!.distance * (trajetsParMode[mode]!.modeTransport == 'car' ? 120 : 0); // 120g CO2/km pour la voiture
    });
  }

  void onModeTransportChange(String mode) {
    setState(() {
      modeTransportActuel = mode;
    });
    _calculerTrajets();
  }

  void _echangerVilles() {
    setState(() {
      LatLng? posDepart = trajetsParMode[modeTransportActuel]!.depart;
      LatLng? posArrivee = trajetsParMode[modeTransportActuel]!.arrivee;
      String txtDepart = _departController.text;
      String txtArrivee = _arriveeController.text;

      trajetsParMode[modeTransportActuel]!.depart = posArrivee;
      trajetsParMode[modeTransportActuel]!.arrivee = posDepart;
      _departController.text = txtArrivee;
      _arriveeController.text = txtDepart;
    });
    _calculerTrajets();
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
            TextCard("D'où partez-vous ?", 
                    const Icon(Icons.my_location), _departController,
                    onValider: (valeur) => _rechercherVille(valeur, true)
            ),
            TextCard('Où voulez-vous aller ?', 
                    const Icon(Icons.location_pin), _arriveeController, 
                    onValider: (valeur) => _rechercherVille(valeur, false)
            ),

            Expanded(
              child: Stack(
                children: [
                  carte(trajetsParMode[modeTransportActuel]!.depart, trajetsParMode[modeTransportActuel]!.arrivee, trajetsParMode[modeTransportActuel]!.trajet, zonesDanger, _mapController),
                  barreModeTransport(modeTransportActuel, onModeTransportChange),
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
