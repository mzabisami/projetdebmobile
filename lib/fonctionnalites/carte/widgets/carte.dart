import 'package:devmobile/modeles/zone_danger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Widget carte(LatLng? depart, LatLng? arrivee, List<LatLng>? trajet, List<ZoneDanger> zonesDanger, MapController mapController) {
  return FlutterMap(
    mapController: mapController,
    options: MapOptions(
      initialCenter: (depart != null && arrivee != null) 
        ? LatLng((depart.latitude + arrivee.latitude) / 2, (depart.longitude + arrivee.longitude) / 2)
        : LatLng(50.361, 3.465),
      initialZoom: 13.0,
      minZoom: 2.0,
      maxZoom: 17.0,
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

      _layerZonesDanger(zonesDanger), // Zones de danger
      _layerTrajet(trajet), // Trajet
      _layerMarkers(depart, arrivee), // Markers pour le départ et l'arrivée
    ],
  );
}

CircleLayer _layerZonesDanger(List<ZoneDanger> zonesDanger) {
  return CircleLayer(circles: [
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
  ]);
}

PolylineLayer _layerTrajet(List<LatLng>? trajet) {
  if (trajet != null && trajet.isNotEmpty) {
    return PolylineLayer(polylines: [
      Polyline(
        points: trajet,
        strokeWidth: 4.0,
        color: Colors.blue,
      ),
    ]);
  } else {
    return PolylineLayer(polylines: []);
  }
}

MarkerLayer _layerMarkers(LatLng? depart, LatLng? arrivee) {
  return MarkerLayer(markers: [
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
  ]);
}
