import 'dart:convert';

import 'package:public_commodity_distribution/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:public_commodity_distribution/api/files_api.dart';

class RequestsApi {
  static const String baseUrl = '${ApiConfig.baseUrl}/alerts';

  static fetchRequests({required String token}) async {
    // Implementation for fetching requests
    try {
      print('gettting requests.... ${Uri.parse(baseUrl)}');
      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(res.body);
      // print(data);
      return data;
    } catch (e) {
      print('Error fetching requests: $e');
    }
  }

  static Future<dynamic> getSentRequests(
    String token,
    String worksAt, {
    String? start,
    String? end,
  }) async {
    try {
      final Map<String, String> queryParameters = {};
      if (start != null) queryParameters['start'] = start;
      if (end != null) queryParameters['end'] = end;

      final uri = Uri.parse(
        '$baseUrl/from/$worksAt',
      ).replace(queryParameters: queryParameters);
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        print(
          'Failed to load alerts from ID $worksAt. Status: ${res.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print("Error fetching alerts from ID $worksAt: $e");
      return null;
    }
  }

  static Future<dynamic> getReceivedRequests(
    String token,
    String worksAt, {
    String? start,
    String? end,
  }) async {
    try {
      print(
        'getting received requests with worksAt=$worksAt start=$start end=$end',
      );
      final Map<String, String> queryParameters = {};
      if (start != null) queryParameters['start'] = start;
      if (end != null) queryParameters['end'] = end;

      final uri = Uri.parse(
        '$baseUrl/to/$worksAt',
      ).replace(queryParameters: queryParameters);
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      } else {
        print(
          'Failed to load alerts for ID $worksAt. Status: ${res.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print("Error fetching alerts to ID $worksAt: $e");
      return null;
    }
  }

  static Future<bool> approveRequest({
    required String token,
    required String requestId,
  }) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': 'read'}),
      );

      if (res.statusCode != 200) {
        print('Server error: ${res.statusCode}');
        return false;
      }

      final data = json.decode(res.body);
      print('data...... $data');

      return data['status'] == 'success';
    } catch (e) {
      print('Error approving request: $e');
      return false;
    }
  }

  static Future<bool> createRequest({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final fileUrl = await FilesApi.uploadFile(data['file'], token);
      if (fileUrl == null) return false;
      data['file'] = fileUrl['data'][0]['url'];
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      print('res from http.... $res');
      if (res.statusCode != 201) {
        print('Server error: ${res.statusCode}');
        return false;
      }

      final responseData = json.decode(res.body);
      print('Request creation response: $responseData');

      return responseData['status'] == 'success';
    } catch (e) {
      print('Error creating request: $e');
      return false;
    }
  }

  static Future<int> getUnreadReceivedRequestsCount({
    required String token,
    required String worksAt,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/to/$worksAt'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(res.body);
      final List<dynamic> alerts = data['data']['alerts'];
      return alerts.where((item) => item['status'] == 'sent').length;
    } catch (e) {
      print('Error fetching unread received requests count: $e');
      return 0;
    }
  }
}
