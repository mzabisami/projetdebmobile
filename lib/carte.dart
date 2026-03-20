import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';


class CartePage extends StatefulWidget {
  const CartePage({super.key});

  @override
  State<CartePage> createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoSafe - Valenciennes', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 58, 183, 131),
      ),
      body: Center(
        child: Column(
          children: [

            _trajetCard("D'où partez-vous ?"),
            _trajetCard('Où voulez-vous aller ?'),

            _carte([50.361, 3.465], [60, 10]),
            _barreNavigation(),
          ],
        ),
      ),
    );
  }
}

Widget _carte(List depart, List arrivee) {
  return Expanded(
    child: FlutterMap(
      mapController: MapController(),
      options: MapOptions(
        initialCenter: LatLng((depart[0]+arrivee[0])/2, (depart[1]+arrivee[1])/2),
        initialZoom: 13.0,
        minZoom: 5.0,
        maxZoom: 20.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.projetdevmobile',
        ),
        
        MarkerLayer(markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(depart[0], depart[1]),
              child: Icon(Icons.my_location, color: Colors.blue, size: 40.0),
            ),

            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(arrivee[0], arrivee[1]),
              child: Icon(Icons.location_pin, color: Colors.red, size: 40.0),
            ),
          ]
        ),
      ],
    ),
  );
}

Widget _trajetCard(String texte) {
  return Card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.map),
          title: Text(texte, style: const TextStyle(color: Color.fromARGB(255, 105, 105, 105))),
        ),
      ],
    ),
  );
}

Widget _barreNavigation() {
  return Container(
    color: const Color.fromARGB(255, 58, 183, 131),
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