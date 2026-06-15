import 'dart:convert';

import 'package:devmobile/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';

class Typeahead extends StatelessWidget {
  final String texte;
  final Icon icon;
  final TextEditingController textController;
  final Function(LatLng coordonnees, String lieu)? onSelected;
  final VoidCallback? onClick;

  const Typeahead(
    this.texte,
    this.icon,
    this.textController, {
    super.key,
    this.onSelected,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: GestureDetector(onTap: onClick, child: icon),
        title: TypeAheadField<dynamic>(
          controller: textController,
          emptyBuilder: (context) => const SizedBox.shrink(),
          suggestionsCallback: (search) async {
            final url = Uri.parse(
              'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(search)}&format=json&limit=5',
            );
            try {
              final response = await http.get(url);
              if (response.statusCode == 200) {
                final List<dynamic> data = json.decode(response.body);
                return data;
              }
            } catch (e) {
              debugPrint('Erreur lors de la recherche de la ville : $e');
            }
            return [];
          },
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: texte,
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
              ),
            );
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(
                suggestion['display_name'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
          onSelected: (suggestion) {
            final lat = double.parse(suggestion['lat']);
            final lon = double.parse(suggestion['lon']);
            final lieu = suggestion['display_name'] ?? '';

            onSelected!(LatLng(lat, lon), lieu);
          },
        ),
      ),
    );
  }
}
