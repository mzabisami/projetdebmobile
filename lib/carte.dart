import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class CartePage extends StatefulWidget {
  const CartePage({super.key});

  @override
  State<CartePage> createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  List<ZoneDanger> zonesDanger = [
    ZoneDanger(LatLng(50.361, 3.465), 200, 1),
    ZoneDanger(LatLng(50.371, 3.5), 200, 2),
  ];

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

            _carte([50.361, 3.465], [50.371, 3.5], zonesDanger),
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

Widget _carte(List depart, List arrivee, List<ZoneDanger> zonesDanger) {
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

        CircleLayer(circles: [
          for (int i = 0; i < zonesDanger.length; i++) 
            CircleMarker(
              point: zonesDanger[i].point,
              radius: zonesDanger[i].radius,
              useRadiusInMeter: true,
              color: 
                zonesDanger[i].niveau == 1 ? Colors.red.withOpacity(0.5) :
                zonesDanger[i].niveau == 2 ? Colors.orange.withOpacity(0.5) :
                Colors.yellow.withOpacity(0.5),
            ),
        ]),

        PolylineLayer(polylines: [
          Polyline(
            points: [LatLng(depart[0], depart[1]), LatLng(arrivee[0], arrivee[1])],
            strokeWidth: 4.0,
            color: Colors.blue,
          ),
        ]),
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

CircleMarker zoneDanger(LatLng point, ) {
  return CircleMarker(
    point: point,
    radius: 200,
    useRadiusInMeter: true,
    color: const Color.fromARGB(255, 244, 114, 54).withOpacity(0.5),
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