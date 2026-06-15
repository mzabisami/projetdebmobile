import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class CrimeoMeterService {
  static const String _endpoint =
      'https://api.crimeometer.com/v1/incidents/simplified-incidents';

  late final String _token;

  CrimeoMeterService() {
    final Random rng = Random.secure();
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    _token = List.generate(64, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<double> getDangerFactor(double lat, double lon) async {
    try {
      final Uri url = Uri.parse(_endpoint).replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'distance': '500m',
          'page': '1',
        },
      );

      final http.Response response = await http
          .get(url, headers: {'x-api-key': _token})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return 0.5;

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final int incidents = (data['total_incidents'] as num?)?.toInt() ?? 0;

      return (incidents / 50).clamp(0.0, 1.0);
    } catch (_) {
      return 0.5;
    }
  }
}
