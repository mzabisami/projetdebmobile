import 'package:devmobile/config/theme.dart';
import 'package:flutter/material.dart';

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