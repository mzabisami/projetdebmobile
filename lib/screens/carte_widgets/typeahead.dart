import 'dart:convert';

import 'package:devmobile/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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
          constraints: const BoxConstraints(maxHeight: 280),
          hideOnEmpty: true,
          hideOnError: true,
          suggestionsCallback: _chercherLieux,
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
              leading: const Icon(Icons.place_outlined),
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

            onSelected?.call(LatLng(lat, lon), lieu);
          },
        ),
      ),
    );
  }

  Future<List<dynamic>> _chercherLieux(String search) async {
    final recherche = search.trim();
    if (recherche.length < 2) {
      return [];
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(recherche)}'
      '&format=json'
      '&addressdetails=1'
      '&accept-language=fr'
      '&limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: const {
          'User-Agent': 'EcoSafe/1.0 (com.example.devmobile)',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }

      debugPrint(
        'Recherche lieu refusee (${response.statusCode}) : ${response.body}',
      );
    } catch (e) {
      debugPrint('Erreur lors de la recherche de la ville : $e');
    }

    return [];
  }
}
