import 'package:devmobile/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

Widget barreZoom(MapController mapController) {
  return Positioned(
    bottom: 20,
    right: 5,
    child: Column(
      children: [
        FloatingActionButton(
          backgroundColor: AppColors.primaryLight,
          onPressed: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom + 1,
          ),
          child: const Icon(Icons.zoom_in, color: AppColors.primary),
        ),
        SizedBox(height: 5),
        FloatingActionButton(
          backgroundColor: AppColors.primaryLight,
          onPressed: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom - 1,
          ),
          child: const Icon(Icons.zoom_out, color: AppColors.primary),
        ),
      ],
    ),
  );
}
