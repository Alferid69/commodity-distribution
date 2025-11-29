import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:public_commodity_distribution/api/api_config.dart';

class TransactionsApi {
  static Future<List<dynamic>> fetchTransactions(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/transactions');
      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return (body['data'] as List?) ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> fetchTransactionsByShopId({
    required String token,
    required String shopId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, String>{};
      if (startDate != null) params['start'] = startDate.toIso8601String();
      if (endDate != null) params['end'] = endDate.toIso8601String();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/transactions/shop/$shopId',
      ).replace(queryParameters: params);
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        // print(body['data']);
        return (body['data'] as List?) ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> fetchTransactionsByDateRange(
    String token, {
    String? start,
    String? end,
    String? shopId,
  }) async {
    try {
      final params = <String, String>{};
      if (start != null) params['start'] = start;
      if (end != null) params['end'] = end;
      if (shopId != null) params['shopId'] = shopId;

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/transactions/date',
      ).replace(queryParameters: params);
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return (body['data'] as List?) ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, List<dynamic>>> fetchMeta(
    String token,
    String? userRole,
  ) async {
    try {
      final Map<String, List<dynamic>> meta = {
        'cooperatives': [],
        'shops': [],
        'woredas': [],
      };

      final coopUrl = Uri.parse('${ApiConfig.baseUrl}/retailerCooperatives');
      final coopRes = await http.get(
        coopUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (coopRes.statusCode == 200) {
        final body = jsonDecode(coopRes.body) as Map<String, dynamic>;
        meta['cooperatives'] = (body['data'] as List?) ?? [];
      }

      final shopsUrl = Uri.parse(
        '${ApiConfig.baseUrl}/retailerCooperativeShops',
      );
      final shopsRes = await http.get(
        shopsUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (shopsRes.statusCode == 200) {
        final body = jsonDecode(shopsRes.body) as Map<String, dynamic>;
        meta['shops'] = (body['data'] as List?) ?? [];
      }

      if (userRole == 'TradeBureau' || userRole == 'SubCityOffice') {
        final wUrl = Uri.parse('${ApiConfig.baseUrl}/woredas');
        final wRes = await http.get(
          wUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (wRes.statusCode == 200) {
          final body = jsonDecode(wRes.body) as Map<String, dynamic>;
          meta['woredas'] = (body['data'] as List?) ?? [];
        }
      }
      return meta;
    } catch (e) {
      return {'cooperatives': [], 'shops': [], 'woredas': []};
    }
  }
}
