import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:public_commodity_distribution/api/api_config.dart';

class FilesApi {
  
static Future<Map<String, dynamic>?> uploadFile(File file, String token) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/upload/uploadFile');
  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..files.add(await http.MultipartFile.fromPath('files', file.path));

  try {
    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(resBody);
    } else {
      debugPrint('File upload failed with status: ${response.statusCode}');
      debugPrint('Response: $resBody');
      return null;
    }
  } catch (e) {
    debugPrint('Failed to upload file: $e');
    return null;
  }
}
}

