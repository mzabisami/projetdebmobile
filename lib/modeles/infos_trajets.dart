import 'package:latlong2/latlong.dart';


class InfosTrajet {
  LatLng? depart;
  LatLng? arrivee;
  List<LatLng>? trajet;
  String mode; // 'foot', 'bike', 'car'

  double distance;  // km
  int duree;        // minutes
  double co2;       // g

  InfosTrajet({
    this.depart,
    this.arrivee,
    this.trajet,
    this.mode = 'foot',
    this.distance = 0,
    this.duree = 0,
    this.co2 = 0,
  });
}
