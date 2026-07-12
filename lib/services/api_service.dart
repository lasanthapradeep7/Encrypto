import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "http://10.0.2.2:8000";

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

}

