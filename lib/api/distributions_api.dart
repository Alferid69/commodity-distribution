import 'dart:convert';

import 'package:public_commodity_distribution/api/api_config.dart';
import 'package:http/http.dart' as http;

class DistributionsApi {
  static final String baseUrl = '${ApiConfig.baseUrl}/distributions';

  static Future getDistributions({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(res.body);
      final sampleData = data['data'][0];
      print('distribution data... $sampleData');
      return data;
    } catch (e) {
      print('Error fetching distributions... $e');
    }
  }

  static Future getReceivedDistributions({
    required String token,
    required String id,
  }) async {
    try {
      print('fetching........');
      final res = await http.get(
        Uri.parse('$baseUrl/to/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(res.body);
      print(data);
      return data;
    } catch (e) {
      print('Error fetching distributions... $e');
    }
  }
}
