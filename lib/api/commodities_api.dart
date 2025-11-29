import 'dart:convert';

import 'package:public_commodity_distribution/api/api_config.dart';
import 'package:http/http.dart' as http;

class CommoditiesApi {
  static final String baseUrl = '${ApiConfig.baseUrl}/commodities';

  static getCommodities({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(res.body);
      return data;

    } catch (e) {
      print('Error fetching commodities: $e');
      return null;
    }
  }

  // Update commodity price
  static Future<Map<String, dynamic>> updateCommodityPrice({
    required String token,
    required String id,
    required num price,
  }) async {
    final url = Uri.parse('$baseUrl/$id');
    final res = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'price': price}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update commodity price (${res.statusCode})');
  }
}
