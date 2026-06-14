import 'dart:convert';
import 'package:http/http.dart' as http;

class OverpassService {
  static const String _endpoint = 'https://overpass-api.de/api/interpreter';

  // Retourne les facteurs urbains autour d'un point GPS (rayon 300m)
  Future<Map<String, double>> getUrbanFactors(double lat, double lon) async {
    try {
      final String query = '''
[out:json];
(
  way["highway"="cycleway"](around:300,$lat,$lon);
  node["highway"="street_lamp"](around:300,$lat,$lon);
  way["highway"="pedestrian"](around:300,$lat,$lon);
  way["highway"="footway"](around:300,$lat,$lon);
);
out tags;
''';

      final http.Response response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=${Uri.encodeComponent(query)}',
      );

      if (response.statusCode != 200) {
        return _fallback();
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> elements = data['elements'] as List<dynamic>? ?? [];

      int cyclewaysCount = 0;
      int lampsCount = 0;
      int footwaysCount = 0;

      for (final dynamic element in elements) {
        final Map<String, dynamic> el = element as Map<String, dynamic>;
        final String type = el['type'] as String? ?? '';
        final Map<String, dynamic> tags =
            el['tags'] as Map<String, dynamic>? ?? {};
        final String highway = tags['highway'] as String? ?? '';

        if (type == 'way' && highway == 'cycleway') {
          cyclewaysCount++;
        } else if (type == 'node' && highway == 'street_lamp') {
          lampsCount++;
        } else if (type == 'way' &&
            (highway == 'pedestrian' || highway == 'footway')) {
          footwaysCount++;
        }
      }

      final Map<String, double> result = {
        'pisteCyclable': (cyclewaysCount / 5).clamp(0.0, 1.0),
        'eclairage': (lampsCount / 20).clamp(0.0, 1.0),
        'frequentation': (footwaysCount / 10).clamp(0.0, 1.0),
      };

      return result;
    } catch (e) {
      return _fallback();
    }
  }

  Map<String, double> _fallback() =>
      {'pisteCyclable': 0.5, 'eclairage': 0.5, 'frequentation': 0.5};
}
