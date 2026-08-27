import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Daily Content settings entry is optional and calls its route hook',
      (tester) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          service: AppSettingsService(),
          onSettingsChanged: (_) {},
          onOpenBackup: () {},
          onOpenDailyContent: () => opened = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('پیام روز'), findsOneWidget);
    await tester.tap(find.text('پیام روز'));
    expect(opened, isTrue);
  });

  testWidgets('existing SettingsPage callers stay compatible without entry',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          service: AppSettingsService(),
          onSettingsChanged: (_) {},
          onOpenBackup: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('پیام روز'), findsNothing);
    expect(find.text('پشتیبان‌گیری و بازیابی'), findsOneWidget);
  });
}
