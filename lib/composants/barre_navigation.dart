import 'package:devmobile/theme.dart';
import 'package:flutter/material.dart';

Widget barreNavigation() {
  return Container(
    color: AppColors.primary,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.home, color: AppColors.primaryLight),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.directions_car, color: AppColors.primaryLight),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.primaryLight),
          onPressed: () {},
        ),
      ],
    ),
  );
}
