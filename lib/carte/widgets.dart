import 'package:devmobile/composants.dart';
import 'package:devmobile/theme.dart';
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
      minZoom: 10.0,
      maxZoom: 50.0,
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

Widget _layerTrajet(List<LatLng>? trajet) {
  if (trajet != null && trajet.isNotEmpty) {
    return PolylineLayer(polylines: [
      Polyline(
        points: trajet,
        strokeWidth: 4.0,
        color: Colors.blue,
      ),
    ]);
  } else {
    return Container();
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

Widget barreModeTransport(String modeActuel, Function(String) onModeTransportChange) {
  return Positioned(
    bottom: 20,
    left: 5,
    child: Row(
      children: [
        _btnTransport(Icons.directions_car, 'car', modeActuel, onModeTransportChange),
        SizedBox(width: 5),
        _btnTransport(Icons.directions_bike, 'bike', modeActuel, onModeTransportChange),
        SizedBox(width: 5),
        _btnTransport(Icons.directions_walk, 'foot', modeActuel, onModeTransportChange),
      ]
    )
  );
}

Widget barreZoom(MapController mapController) {
  return Positioned(
    bottom: 20,
    right: 5,
    child: Column(
      children: [
        FloatingActionButton(
          backgroundColor: AppColors.primaryLight,
          onPressed: () => mapController.move(mapController.camera.center, mapController.camera.zoom+1),
          child: const Icon(Icons.zoom_in, color: AppColors.primary),
        ),
        SizedBox(height: 5),
        FloatingActionButton(
          backgroundColor: AppColors.primaryLight,
          onPressed: () => mapController.move(mapController.camera.center, mapController.camera.zoom-1),
          child: const Icon(Icons.zoom_out, color: AppColors.primary),
        ),
      ]
    )
  );
}

Widget _btnTransport(IconData icon, String modeSelected, String modeActuel, Function(String) onModeTransportChange) {
  return FloatingActionButton(
    backgroundColor: modeSelected == modeActuel ? AppColors.secondary : AppColors.secondaryLight,
    onPressed: () => onModeTransportChange(modeSelected),
    child: Icon(icon, color: modeSelected == modeActuel ? AppColors.primaryLight :  AppColors.primary),
  );
}

Widget btnIcon(IconData icon, Function() onPressed) {
  return FloatingActionButton(
    backgroundColor: AppColors.primaryLight,
    onPressed: onPressed,
    child: Icon(icon, color: AppColors.primary),
  );
}