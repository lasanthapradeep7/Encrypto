import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:encrypto/services/session_service.dart';

class ApiService {
  static const String baseUrl = "https://encrypto-backend-sdys.onrender.com";

static Future<Map<String, String>> _authHeaders({
    bool includeJson = false,
  }) async {
    final token =
        await SessionService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Login session not found.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      if (includeJson)
        'Content-Type': 'application/json',
    };
  }


  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": fullName,
        "email": email,
        "password": password,
      }),
    );

    return {"status": response.statusCode, "body": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return {"status": response.statusCode, "body": jsonDecode(response.body)};
  }

  static Map<String, dynamic> _responseResult(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = {'detail': 'The server returned an invalid response.'};
    }
    return {'status': response.statusCode, 'body': body};
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _authHeaders(includeJson: true),
      body: jsonEncode({
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
      }),
    );
    return _responseResult(response);
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: await _authHeaders(includeJson: true),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    return _responseResult(response);
  }

  static Future<Map<String, dynamic>> uploadFile(String filePath) async {
    final uri = Uri.parse("$baseUrl/files/upload");
    final request = http.MultipartRequest("POST", uri);
    request.headers.addAll(
  await _authHeaders(),
);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return {"status": response.statusCode, "body": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> encryptFile(
  int fileId,
) async {
  final response = await http.post(
    Uri.parse(
      '$baseUrl/crypto/encrypt/$fileId',
    ),
    headers: await _authHeaders(),
  );

  return {
    'status': response.statusCode,
    'body': jsonDecode(response.body),
  };
}

  static Future<Map<String, dynamic>> decryptFile({
  required int fileId,
  required String key,
}) async {
  final response = await http.post(
    Uri.parse(
      '$baseUrl/crypto/decrypt/$fileId?key=$key',
    ),
    headers: await _authHeaders(),
  );

  return {
    'status': response.statusCode,
    'body': jsonDecode(response.body),
  };
}

  static Future<List<int>?> downloadFile(int fileId, String type) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/files/download/$fileId?type=$type',
      ),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }

  static Future<Map<String, dynamic>> analyzeFile(
  int fileId,
) async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/ai/analyze-file/$fileId',
    ),
    headers: await _authHeaders(),
  );

  dynamic responseBody;

  try {
    responseBody = jsonDecode(
      response.body,
    );
  } catch (_) {
    responseBody = {
      'detail': 'Invalid AI analysis response',
    };
  }

  return {
    'status': response.statusCode,
    'body': responseBody,
  };
}

  static Future<Map<String, dynamic>> hideStego({
  required String coverImagePath,
  required String hiddenFilePath,
}) async {
  final uri = Uri.parse(
    '$baseUrl/stego/hide',
  );

  final request = http.MultipartRequest(
    'POST',
    uri,
  );

  request.headers.addAll(
    await _authHeaders(),
  );

  request.files.add(
    await http.MultipartFile.fromPath(
      'cover_image',
      coverImagePath,
    ),
  );

  request.files.add(
    await http.MultipartFile.fromPath(
      'hidden_file',
      hiddenFilePath,
    ),
  );

  final streamedResponse =
      await request.send();

  final response =
      await http.Response.fromStream(
    streamedResponse,
  );

  return {
    'status': response.statusCode,
    'body': jsonDecode(response.body),
  };
}

  static Future<Map<String, dynamic>> extractStego({
  required String stegoImagePath,
}) async {
  final uri = Uri.parse(
    '$baseUrl/stego/extract',
  );

  final request = http.MultipartRequest(
    'POST',
    uri,
  );

  request.headers.addAll(
    await _authHeaders(),
  );

  request.files.add(
    await http.MultipartFile.fromPath(
      'stego_image',
      stegoImagePath,
    ),
  );

  final streamedResponse =
      await request.send();

  final response =
      await http.Response.fromStream(
    streamedResponse,
  );

  return {
    'status': response.statusCode,
    'body': jsonDecode(response.body),
  };
}

  static Future<List<int>?> downloadStegoFile(
  String filename,
) async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/stego/download/$filename',
    ),
    headers: await _authHeaders(),
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
      headers: await _authHeaders(
  includeJson: true,
),
      body: jsonEncode({'password': password, 'mode': mode}),
    );

    return {'status': response.statusCode, 'body': jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> decryptFileWithPassword({
    required int fileId,
    required String password,
    required String mode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/crypto/decrypt-password/$fileId'),
       headers: await _authHeaders(
    includeJson: true,
  ),
      body: jsonEncode({'password': password, 'mode': mode}),
    );

    return {'status': response.statusCode, 'body': jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>>
    createSecurityIncident({
  required String reason,
  required String incidentType,
  required String deviceInfo,
  String? attemptedEmail,
  String? imagePath,
}) async {
  final uri = Uri.parse(
    '$baseUrl/security/incidents',
  );

  final request = http.MultipartRequest(
    'POST',
    uri,
  );

  request.fields['reason'] = reason;
  request.fields['incident_type'] =
      incidentType;
  request.fields['device_info'] =
      deviceInfo;

  if (attemptedEmail != null &&
      attemptedEmail.trim().isNotEmpty) {
    request.fields['attempted_email'] =
        attemptedEmail.trim().toLowerCase();
  }

  if (imagePath != null &&
      imagePath.isNotEmpty) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
      ),
    );
  }

  final streamedResponse =
      await request.send();

  final response =
      await http.Response.fromStream(
    streamedResponse,
  );

  dynamic responseBody;

  try {
    responseBody = jsonDecode(
      response.body,
    );
  } catch (_) {
    responseBody = {
      'detail':
          'Invalid security incident response',
    };
  }

  return {
    'status': response.statusCode,
    'body': responseBody,
  };
}

  static Future<Map<String, dynamic>>
    getSecurityIncidents() async {
  final uri = Uri.parse(
    '$baseUrl/security/incidents',
  );

  debugPrint(
    'SECURITY REQUEST URL: $uri',
  );

  final response = await http.get(
    uri,
    headers: await _authHeaders(),
  );

  debugPrint(
    'SECURITY RESPONSE STATUS: '
    '${response.statusCode}',
  );

  debugPrint(
    'SECURITY RESPONSE BODY: '
    '${response.body}',
  );

  dynamic responseBody;

  try {
    responseBody = jsonDecode(
      response.body,
    );
  } catch (_) {
    responseBody = {
      'detail':
          'Invalid security response',
    };
  }

  return {
    'status': response.statusCode,
    'body': responseBody,
  };
}

  static String securityIncidentImageUrl(int incidentId) {
    return '$baseUrl/security/incidents/$incidentId/image';
  }

  static Future<Map<String, dynamic>> getVaultDashboard() async {
   final response = await http.get(
  Uri.parse(
    '$baseUrl/files/dashboard',
  ),
  headers: await _authHeaders(),
);

    dynamic responseBody;

    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      responseBody = {'detail': 'Invalid dashboard response'};
    }

    return {'status': response.statusCode, 'body': responseBody};
  }

  

  
}
