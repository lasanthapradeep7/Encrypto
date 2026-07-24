import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const String _emailKey = 'user_email';

  static Future<void> saveLoginSession({
    required String accessToken,
    required String email,
  }) async {
    await _storage.write(
      key: _tokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: _emailKey,
      value: email.trim().toLowerCase(),
    );
  }

  static Future<String?> getAccessToken() {
    return _storage.read(key: _tokenKey);
  }

  static Future<String?> getUserEmail() {
    return _storage.read(key: _emailKey);
  }

  static Future<bool> hasActiveSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static DateTime? _securityWindowStartedAt;

static void startSecurityWindow() {
  _securityWindowStartedAt = DateTime.now();
}

static DateTime? getSecurityWindowStartedAt() {
  return _securityWindowStartedAt;
}

  static const String _lastSeenIncidentKey =
    'last_seen_security_incident_id';

static Future<int?> getLastSeenSecurityIncidentId() async {
  final value = await _storage.read(
    key: _lastSeenIncidentKey,
  );

  return int.tryParse(value ?? '');
}

static Future<void> saveLastSeenSecurityIncidentId(
  int incidentId,
) async {
  await _storage.write(
    key: _lastSeenIncidentKey,
    value: incidentId.toString(),
  );
}

  static Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
  }
}