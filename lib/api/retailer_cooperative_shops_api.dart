import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:public_commodity_distribution/api/api_config.dart';

class RetailerCooperativeShopsApi {
  // GET /retailerCooperativeShops
  static Future<Map<String, dynamic>> getRetailerCooperativeShops({
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/retailerCooperativeShops');
    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Failed to fetch retailer cooperative shops (${res.statusCode})',
      );
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // GET /retailerCooperativeShops/:id
  static Future<Map<String, dynamic>> getRetailerCooperativeShopById({
    required String token,
    required String id,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/retailerCooperativeShops/$id');
    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to fetch shop by id $id');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // GET /retailerCooperativeShops/retailerCooperative/:retailerCooperativeId
  static Future<Map<String, dynamic>> getShopsByRetailerCooperativeId({
    required String token,
    required String retailerCooperativeId,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/retailerCooperativeShops/retailerCooperative/$retailerCooperativeId',
    );
    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Failed to fetch shops by retailer cooperative id $retailerCooperativeId',
      );
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // GET /retailerCooperativeShops/woredaOffice/:woredaOfficeId
  static Future<Map<String, dynamic>> getShopsByWoredaOfficeId({
    required String token,
    required String woredaOfficeId,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/retailerCooperativeShops/woredaOffice/$woredaOfficeId',
    );
    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Failed to fetch shops by woreda office id $woredaOfficeId',
      );
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
