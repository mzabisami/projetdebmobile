import 'package:devmobile/fonctionnalites/carte/itineraire_services.dart';
import 'package:devmobile/modeles/infos_trajets.dart';
import 'package:devmobile/theme.dart';
import 'package:flutter/material.dart';

Widget bandeauInfosTrajet() {
  if (ItineraireServices.depart == null || ItineraireServices.arrivee == null) {
    return const SizedBox.shrink();
  }
  InfosTrajet? trajet = ItineraireServices.trajetsParMode[ItineraireServices.modeActuel];
  return Positioned(
    bottom: 75,
    left: 5,
    child: Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${trajet!.distance.toStringAsFixed(1)} km - '
        '${ItineraireServices.formaterDuree(trajet.duree)} - '
        '${trajet.co2.toStringAsFixed(0)} g CO2',
        style: TextStyle(fontSize: 14)
      )
    )          
  );
}
