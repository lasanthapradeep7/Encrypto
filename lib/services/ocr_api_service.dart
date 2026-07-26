import 'dart:convert';

import 'package:http/http.dart' as http;

class OcrApiService {
  static const String baseUrl =
      'https://encrypto-backend-sdys.onrender.com';

  static Future<Map<String, dynamic>> analyzeExtractedText({
    required int fileId,
    required String extractedText,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/analyze-ocr-text'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'file_id': fileId,
        'extracted_text': extractedText,
      }),
    );

    dynamic responseBody;

    try {
      responseBody = jsonDecode(response.body);
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
}
