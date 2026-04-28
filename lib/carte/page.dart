import 'package:devmobile/composants.dart';
import 'package:devmobile/carte/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  
  InfosTrajet trajetActuel = InfosTrajet(depart: LatLng(0, 0), modeTransport: 'foot');

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
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
              trajetActuel.depart = LatLng(lat, lon);
            } else {
              trajetActuel.arrivee = LatLng(lat, lon);
            }
            _mapController.move(LatLng(lat, lon), 15.0);
          });
          
          _calculerTrajet();
        }
      }
    } catch (e) {
      print('Erreur lors de la recherche de la ville : $e');
    }
  }

  Future<void> _calculerTrajet() async {
    if (trajetActuel.depart == null || trajetActuel.arrivee == null) return;
    
    final url = Uri.parse('https://routing.openstreetmap.de/routed-${trajetActuel.modeTransport}/route/v1/driving/'
        '${trajetActuel.depart!.longitude},${trajetActuel.depart!.latitude};${trajetActuel.arrivee!.longitude},${trajetActuel.arrivee!.latitude}?overview=full&geometries=geojson'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coords = data['routes'][0]['geometry']['coordinates'];

          setState(() {
            trajetActuel.trajet = coords.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
            trajetActuel.distance = data['routes'][0]['distance'] / 1000; // Convertir en km
            trajetActuel.duree = (data['routes'][0]['duration'] / 60).round(); // Convertir en minutes
            _calculerCo2();
          });
        }
      }
    } catch (e) {
      print('Erreur lors du calcul du trajet : $e');
    }
  }

  void _calculerCo2() {
    if (trajetActuel.trajet == null) return;

    setState(() {
      trajetActuel.co2 = trajetActuel.distance * (trajetActuel.modeTransport == 'car' ? 120 : 0); // 120g CO2/km pour la voiture
    });
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
                    const Icon(Icons.my_location), 
                    _departController,
                    onValider: (valeur) => _rechercherVille(valeur, true)
            ),
            TextCard('Où voulez-vous aller ?', 
                    const Icon(Icons.location_pin), 
                    _arriveeController, 
                    onValider: (valeur) => _rechercherVille(valeur, false)
            ),

            carte(trajetActuel.depart, trajetActuel.arrivee, trajetActuel.trajet, zonesDanger, _mapController),
            barreNavigation(),
          ],
        ),
      ),
    );
  }
}

