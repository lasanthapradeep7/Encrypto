import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {

  static const String baseUrl = "https://encrypto-backend-sdys.onrender.com";

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "full_name": fullName,
        "email": email,
        "password": password,
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  static Future<Map<String, dynamic>> uploadFile(String filePath) async {
    final uri = Uri.parse("$baseUrl/files/upload");
    final request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  static Future<Map<String, dynamic>> encryptFile(int fileId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/crypto/encrypt/$fileId"),
    );
    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  static Future<Map<String, dynamic>> decryptFile({
    required int fileId,
    required String key,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/crypto/decrypt/$fileId?key=$key"),
    );
    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  static Future<List<int>?> downloadFile(int fileId, String type) async {
    final response = await http.get(
      Uri.parse("$baseUrl/files/download/$fileId?type=$type"),
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }

  static Future<Map<String, dynamic>> analyzeFile(int fileId) async {
  final response = await http.get(
    Uri.parse("$baseUrl/ai/analyze-file/$fileId"),
  );

  return {
    "status": response.statusCode,
    "body": jsonDecode(response.body),
    };
  }

  static Future<Map<String, dynamic>> hideStego({
  required String coverImagePath,
  required String hiddenFilePath,
}) async {
  final uri = Uri.parse("$baseUrl/stego/hide");
  final request = http.MultipartRequest("POST", uri);

  request.files.add(
    await http.MultipartFile.fromPath("cover_image", coverImagePath),
  );

  request.files.add(
    await http.MultipartFile.fromPath("hidden_file", hiddenFilePath),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  return {
    "status": response.statusCode,
    "body": jsonDecode(response.body),
  };
}

static Future<Map<String, dynamic>> extractStego({
  required String stegoImagePath,
}) async {
  final uri = Uri.parse("$baseUrl/stego/extract");
  final request = http.MultipartRequest("POST", uri);

  request.files.add(
    await http.MultipartFile.fromPath("stego_image", stegoImagePath),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  return {
    "status": response.statusCode,
    "body": jsonDecode(response.body),
  };
}

static Future<List<int>?> downloadStegoFile(String filename) async {
  final response = await http.get(
    Uri.parse("$baseUrl/stego/download/$filename"),
  );

  if (response.statusCode == 200) {
    return response.bodyBytes;
  }

  return null;
}

static Future<Map<String, dynamic>> encryptFileWithPassword({
  required int fileId,
  required String password,
  required String mode,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/crypto/encrypt-password/$fileId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'password': password, 'mode':mode}),
  );

  return {
    'status': response.statusCode,
    'body': jsonDecode(response.body),
  };
}

static Future<Map<String, dynamic>> decryptFileWithPassword({
  required int fileId,
  required String password,
  required String mode,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/crypto/decrypt-password/$fileId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'password': password, 'mode':mode}),
  );

  return {
    'status': response.statusCode,
    'body': jsonDecode(response.body),
  };
}

static Future<Map<String, dynamic>> createSecurityIncident({
  required String reason,
  required String incidentType,
  required String deviceInfo,
  int? userId,
  String? attemptedEmail,
  String? imagePath,
}) async {
  final uri = Uri.parse('$baseUrl/security/incidents');
  final request = http.MultipartRequest('POST', uri);

  request.fields['reason'] = reason;
  request.fields['incident_type'] = incidentType;
  request.fields['device_info'] = deviceInfo;

  if (userId != null) {
    request.fields['user_id'] = userId.toString();
  }

  if (attemptedEmail != null &&
    attemptedEmail.trim().isNotEmpty) {
  request.fields['attempted_email'] =
      attemptedEmail.trim();
}

  if (imagePath != null && imagePath.isNotEmpty) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
      ),
    );
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  return {
    'status': response.statusCode,
    'body': jsonDecode(response.body),
  };
}

static Future<Map<String, dynamic>> getSecurityIncidents({
  int? userId,
}) async {
  final uri = userId == null
      ? Uri.parse('$baseUrl/security/incidents')
      : Uri.parse(
          '$baseUrl/security/incidents?user_id=$userId',
        );

  debugPrint('SECURITY REQUEST URL: $uri');

  final response = await http.get(uri);

  debugPrint('SECURITY RESPONSE STATUS: ${response.statusCode}');
  debugPrint('SECURITY RESPONSE BODY: ${response.body}');

  return {
    'status': response.statusCode,
    'body': jsonDecode(response.body),
  };
}

static String securityIncidentImageUrl(int incidentId) {
  return '$baseUrl/security/incidents/$incidentId/image';
}

}