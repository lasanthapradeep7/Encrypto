import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> extractTextFromImage(
    String imagePath,
  ) async {
    final inputImage = InputImage.fromFilePath(
      imagePath,
    );

    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    try {
      final recognizedText =
          await textRecognizer.processImage(
        inputImage,
      );

      return recognizedText.text.trim();
    } catch (error) {
      throw Exception(
        'Image OCR failed: $error',
      );
    } finally {
      await textRecognizer.close();
    }
  }
}