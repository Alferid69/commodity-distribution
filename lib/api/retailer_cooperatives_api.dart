import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/api_config.dart';
import 'package:http/http.dart' as http;

class RetailerCooperativesApi {
  static final baseUrl = '${ApiConfig.baseUrl}/retailerCooperatives';

  static Future getRetailerCooperatives({required String token}) async {
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
      debugPrint('Error fetching retailer cooperatives: $e');
      return null;
    }
  }

  static Future getRetailerCooperative({
    required String token,
    required String id,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(res.body);
      // debugPrint(data['data']['availableCommodity']);
      return data;
    } catch (e) {
      debugPrint('Error fetchin retailer cooperative: $e');
    }
  }
}
