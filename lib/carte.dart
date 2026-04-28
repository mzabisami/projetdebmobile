import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'theme.dart';

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
  LatLng? depart = LatLng(50.361, 3.465);
  LatLng? arrivee;
  List<LatLng>? trajet;
  String modeTransport = 'foot'; // 'car', 'bike', 'foot'

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
  }

  Future<void> rechercherVille(String ville, bool estDepart) async {
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
              depart = LatLng(lat, lon);
            } else {
              arrivee = LatLng(lat, lon);
            }
            _mapController.move(LatLng(lat, lon), 15.0);
          });
          
          calculerTrajet();
        }
      }
    } catch (e) {
      print('Erreur lors de la recherche de la ville : $e');
    }
  }

  Future<void> calculerTrajet() async {
    if (depart == null || arrivee == null) return;
    
    final url = Uri.parse('https://routing.openstreetmap.de/routed-$modeTransport/route/v1/driving/'
        '${depart!.longitude},${depart!.latitude};${arrivee!.longitude},${arrivee!.latitude}?overview=full&geometries=geojson'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coords = data['routes'][0]['geometry']['coordinates'];

          setState(() {
            trajet = coords.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
          });
        }
      }
    } catch (e) {
      print('Erreur lors du calcul du trajet : $e');
    }
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
                    onValider: (valeur) => rechercherVille(valeur, true)
            ),
            TextCard('Où voulez-vous aller ?', 
                    const Icon(Icons.location_pin), 
                    _arriveeController, 
                    onValider: (valeur) => rechercherVille(valeur, false)
            ),

            _carte(depart, arrivee, zonesDanger, trajet, _mapController),
            _barreNavigation(),
          ],
        ),
      ),
    );
  }
}

class ZoneDanger {
  final LatLng point;
  final double radius;
  final int niveau;

  ZoneDanger(this.point, this.radius, this.niveau);
}

Widget _carte(LatLng? depart, LatLng? arrivee, List<ZoneDanger> zonesDanger, List<LatLng>? trajet, MapController mapController) {
  return Expanded(
    child: FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: (depart != null && arrivee != null) 
          ? LatLng((depart.latitude + arrivee.latitude) / 2, (depart.longitude + arrivee.longitude) / 2)
          : LatLng(50.361, 3.465),
        initialZoom: 13.0,
        minZoom: 6.0,
        maxZoom: 30.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        
        onLongPress: (tapPosition, point) {
          mapController.move(mapController.camera.center, mapController.camera.zoom-2); // Permet de réinitialiser le focus sur la carte après un tap
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.projetdevmobile',
        ),

        // Zones de danger
        CircleLayer(circles: [
          for (int i = 0; i < zonesDanger.length; i++) 
            CircleMarker(
              point: zonesDanger[i].point,
              radius: zonesDanger[i].radius,
              useRadiusInMeter: true,
              color: 
                // ignore: deprecated_member_use
                zonesDanger[i].niveau == 1 ? Colors.red.withOpacity(0.5) :
                // ignore: deprecated_member_use
                zonesDanger[i].niveau == 2 ? Colors.orange.withOpacity(0.5) :
                // ignore: deprecated_member_use
                Colors.yellow.withOpacity(0.5),
            ),
        ]),

        // Trajet
        if (trajet != null && trajet.isNotEmpty)
          PolylineLayer(polylines: [
            Polyline(
              points: trajet,
              strokeWidth: 4.0,
              color: Colors.blue,
            ),
          ]),

        // Markers pour le départ et l'arrivée
        MarkerLayer(markers: [
          if (depart != null)
            Marker(
              width: 80.0,
              height: 80.0,
              point: depart,
              child: Icon(Icons.my_location, color: Colors.blue, size: 40.0),
            ),
          if (arrivee != null)
            Marker(
              width: 80.0,
              height: 80.0,
              point: arrivee,
              child: Icon(Icons.location_pin, color: Colors.red, size: 40.0),
            ),
          ]
        ),
      ],
    ),
  );
}

class TextCard extends StatelessWidget {
  final String texte;
  final Icon icon;
  final TextEditingController controller;
  final Function(String) onValider;

  const TextCard(this.texte, this.icon, this.controller, {required this.onValider, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          leading: icon,
          title: TextField(
            controller: controller,
            onSubmitted: onValider,
            decoration: InputDecoration(
              hintText: texte,
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
          ),
        ),
    );
  }
}

Widget _barreNavigation() {
  return Container(
    color: AppColors.primary,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.directions_car, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {},
        ),
      ],
    ),
  );
}