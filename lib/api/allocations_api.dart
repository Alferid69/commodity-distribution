import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/api_config.dart';
import 'package:http/http.dart' as http;

class AllocationsApi {
  static const String baseUrl = '${ApiConfig.baseUrl}/allocations';

  static getAllocations({required String token}) async {
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
      debugPrint('Error fetching allocations: $e');
      return null;
    }
  }

  static getAllocationsToRetailerCooperative({
    required String token,
    required String id,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/to/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(res.body);
      return data;
    } catch (e) {
      debugPrint('Error fetching allocations: $e');
      return null;
    }
  }

  static getAllocationsByWoreda({
    required String token,
    required String id,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/woredaOffice/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(res.body);
      debugPrint(data);
      return data;
    } catch (e) {
      debugPrint('Error fetching allocations: $e');
      return null;
    }
  }

  static createAllocation({
    required String token,
    required Map<String, dynamic> allocationData,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(allocationData),
      );

      final data = json.decode(res.body);
      return data;
    } catch (e) {
      debugPrint('Error creating allocation: $e');
      return null;
    }
  }

  static Future<int> getPendingAllocationsCount({
    required String token,
    required String id,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/to/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(res.body);
      // Make sure you point to the right list in your response structure!
      // For allocations returned as { data: [...] }:
      final List<dynamic> allocations = data['data'];
      return allocations.where((item) => item['status'] == 'pending').length;
    } catch (e) {
      debugPrint('Error fetching pending allocations count: $e');
      return 0;
    }
  }

  static Future<bool> rejectAllocation({
    required String token,
    required String id,
  }) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': 'rejected'}),
      );
      if (res.statusCode != 200) {
        debugPrint('Server error: ${res.statusCode}');
        return false;
      }
      final data = json.decode(res.body);
      return data['status'] == 'success';
    } catch (e) {
      debugPrint('Error rejecting allocation: $e');
      return false;
    }
  }

  static Future<bool> approveAllocation({
    required String token,
    required String id,
  }) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': 'approved'}),
      );
      if (res.statusCode != 200) {
        debugPrint('Server error: ${res.statusCode}');
        return false;
      }
      final data = json.decode(res.body);
      return data['status'] == 'success';
    } catch (e) {
      debugPrint('Error approving allocation: $e');
      return false;
    }
  }
}
