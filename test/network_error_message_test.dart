import 'dart:async';
import 'dart:io';

import 'package:encrypto/core/network/network_error_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('NetworkErrorMessage', () {
    test('returns actionable offline copy for socket failures', () {
      expect(
        NetworkErrorMessage.forError(const SocketException('offline')),
        NetworkErrorMessage.offline,
      );
    });

    test('recognizes HTTP client network failures', () {
      expect(
        NetworkErrorMessage.forError(http.ClientException('network failed')),
        NetworkErrorMessage.offline,
      );
    });

    test('distinguishes timeouts from offline failures', () {
      expect(
        NetworkErrorMessage.forError(TimeoutException('slow')),
        'The connection is taking too long. Please try again.',
      );
    });

    test('uses contextual fallback for unrelated failures', () {
      expect(
        NetworkErrorMessage.forError(
          StateError('bad response'),
          fallback: 'Unable to load data.',
        ),
        'Unable to load data.',
      );
    });
  });
}
