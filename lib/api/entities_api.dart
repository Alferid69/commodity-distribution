import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:public_commodity_distribution/api/api_config.dart';

class EntitiesApi {
  static const String baseUrl = '${ApiConfig.baseUrl}/entities';
  static getAllEntities({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(res.body);
      debugPrint('enitites..... $data');
      return data;
    } catch (e) {
      debugPrint('Error fetching entities: $e');
    }
  }
}
