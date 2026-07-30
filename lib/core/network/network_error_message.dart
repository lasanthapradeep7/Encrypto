import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Converts low-level networking failures into safe, actionable user copy.
abstract final class NetworkErrorMessage {
  static const offline =
      'No internet connection. Check Wi-Fi or mobile data, then try again.';

  static bool isOffline(Object error) {
    if (error is SocketException || error is http.ClientException) {
      return true;
    }

    final text = error.toString().toLowerCase();
    return text.contains('failed host lookup') ||
        text.contains('network is unreachable') ||
        text.contains('connection refused') ||
        text.contains('connection reset') ||
        text.contains('software caused connection abort');
  }

  static String forError(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (isOffline(error)) return offline;
    if (error is TimeoutException) {
      return 'The connection is taking too long. Please try again.';
    }
    return fallback;
  }
}
