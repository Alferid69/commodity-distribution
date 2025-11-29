import 'dart:convert';

import 'api_config.dart';
import 'package:http/http.dart' as http;

class Auth {
  static login({required String username, required String password}) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/users/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  static getMe({required String token}) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/users/me");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Failed to fetch profile: ${response.body}");
    }
  }

  static Future<bool> isLoggedIn({required String token}) async {
    try {
      final user = await getMe(token: token);
      return user.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
