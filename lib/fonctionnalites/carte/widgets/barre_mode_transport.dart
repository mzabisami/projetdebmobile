import 'package:devmobile/theme.dart';
import 'package:flutter/material.dart';

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

Widget _btnTransport(IconData icon, String modeSelected, String modeActuel, Function(String) onModeTransportChange) {
  return FloatingActionButton(
    backgroundColor: modeSelected == modeActuel ? AppColors.secondary : AppColors.secondaryLight,
    onPressed: () => onModeTransportChange(modeSelected),
    child: Icon(icon, color: modeSelected == modeActuel ? AppColors.primaryLight :  AppColors.primary),
  );
}