import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/pages/encryption_shell.dart';

void main() {
  Widget buildShell() {
    return MaterialApp(theme: AppTheme.light, home: const EncryptionShell());
  }

  testWidgets('bottom bar opens profile screen and returns to vault', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildShell());

    expect(find.text('Secure Vault'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('User Profile'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.byTooltip('Go back'), findsNothing);

    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();

    expect(find.text('Secure Vault'), findsOneWidget);
    expect(find.text('Vault'), findsOneWidget);
  });

  testWidgets('top bar opens notifications and settings screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildShell());

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Mark read'), findsWidgets);

    await tester.tap(find.byTooltip('Go back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
  });
}
