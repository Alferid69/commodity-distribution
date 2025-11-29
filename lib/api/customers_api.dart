import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:public_commodity_distribution/api/api_config.dart';

class CustomersApi {
  static const String baseUrl = '${ApiConfig.baseUrl}/customers';

  // Fetch all customers
  static fetchCustomers({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }

  // Fetch a single customer by ID
  static Future<Map<String, dynamic>> fetchCustomerById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load customer');
    }
  }

  // Fetch a single customer by Fayda
  static Future<Map<String, dynamic>> getCustomerFayda({
    required String token,
    required String fayda,
  }) async {
    final url = Uri.parse('$baseUrl/fayda/$fayda');
    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch customer by Fayda $fayda');
  }

  // Create a new customer
  static Future<Map<String, dynamic>> createCustomer(
    Map<String, dynamic> customerData,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(customerData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create customer');
    }
  }

  // Update an existing customer
  static Future<Map<String, dynamic>> updateCustomer(
    String id,
    Map<String, dynamic> customerData,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(customerData),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update customer');
    }
  }

}
