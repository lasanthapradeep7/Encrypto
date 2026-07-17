import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class IntruderCameraService {
  IntruderCameraService._();

  static Future<String?> captureFrontCameraPhoto() async {
    CameraController? controller;

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        return null;
      }

      CameraDescription? frontCamera;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      if (frontCamera == null) {
        return null;
      }

      controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      final capturedImage = await controller.takePicture();
      final tempDirectory = await getTemporaryDirectory();

      final targetPath =
          '${tempDirectory.path}/intruder_'
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      await File(capturedImage.path).copy(targetPath);

      return targetPath;
    } catch (error, stackTrace) {
      print('Intruder photo capture failed: $error');
      print(stackTrace);
      return null;
    } finally {
      await controller?.dispose();
    }
  }
}