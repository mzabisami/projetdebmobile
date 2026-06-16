import 'package:devmobile/config/theme.dart';
import 'package:flutter/material.dart';

Widget btnIcon(IconData icon, Function() onPressed) {
  return FloatingActionButton(
    backgroundColor: AppColors.primaryLight,
    onPressed: onPressed,
    child: Icon(icon, color: AppColors.primary),
  );
}
