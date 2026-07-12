import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricKeyService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> authenticate() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();

    if (!canCheck && !isSupported) return false;

    return await _auth.authenticate(
      localizedReason: 'Authenticate to access your encryption key',
    );
  }

  static Future<void> saveKey({
    required int fileId,
    required String key,
  }) async {
    await _storage.write(
      key: 'file_key_$fileId',
      value: key,
    );
  }

  static Future<String?> getKey({
    required int fileId,
  }) async {
    final ok = await authenticate();
    if (!ok) return null;

    return await _storage.read(
      key: 'file_key_$fileId',
    );
  }

  static Future<void> saveKeyByFileName({
    required String fileName,
    required String key,
  }) async {
    await _storage.write(
      key: 'file_key_name_$fileName',
      value: key,
    );
  }

  static Future<String?> getKeyByFileName({
    required String fileName,
  }) async {
    final ok = await authenticate();
    if (!ok) return null;

    return await _storage.read(
      key: 'file_key_name_$fileName',
    );
  }

  static Future<void> deleteKeyByFileName({
    required String fileName,
  }) async {
    await _storage.delete(
      key: 'file_key_name_$fileName',
    );
  }
}