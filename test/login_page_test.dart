import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:encrypto/features/auth/presentation/pages/login_page.dart';
import 'package:encrypto/core/theme/app_theme.dart';

void main() {
  testWidgets('LoginPage renders without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const LoginPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
