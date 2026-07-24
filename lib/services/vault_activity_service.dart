import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class VaultActivityService {
  static const String _activitiesKey = 'vault_activity_history';

  static Future<List<Map<String, dynamic>>> getActivities() async {
    final preferences = await SharedPreferences.getInstance();
    final savedValue = preferences.getString(_activitiesKey);

    if (savedValue == null || savedValue.isEmpty) {
      return [];
    }

    try {
      final decodedValue = jsonDecode(savedValue);

      if (decodedValue is! List) {
        return [];
      }

      return decodedValue
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addActivity({
    required String fileName,
    required String status,
    required int sizeBytes,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final activities = await getActivities();

    activities.insert(
      0,
      {
        'name': fileName,
        'status': status,
        'size_bytes': sizeBytes,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    final recentActivities = activities.take(20).toList();

    await preferences.setString(
      _activitiesKey,
      jsonEncode(recentActivities),
    );
  }

  static Future<void> clearActivities() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_activitiesKey);
  }
}