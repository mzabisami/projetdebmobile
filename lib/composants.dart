import 'package:flutter/material.dart';
import 'package:devmobile/theme.dart';
import 'package:latlong2/latlong.dart';


class InfosTrajet {
  LatLng? depart;
  LatLng? arrivee;
  List<LatLng>? trajet;
  String modeTransport; // 'foot', 'bike', 'car'

  double distance;  // km
  int duree;        // minutes
  double co2;       // g

  InfosTrajet({
    this.depart,
    this.arrivee,
    this.trajet,
    this.modeTransport = 'foot',
    this.distance = 0,
    this.duree = 0,
    this.co2 = 0,
  });
}

class ZoneDanger {
  final LatLng point;
  final double radius;
  final int niveau;

  ZoneDanger(this.point, this.radius, this.niveau);
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

Widget barreNavigation() {
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