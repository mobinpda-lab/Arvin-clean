import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('settings persists theme/date and reuses backup entry', (tester) async {
    final service = AppSettingsService();
    AppSettings? changed;
    var backupOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          service: service,
          onSettingsChanged: (value) => changed = value,
          onOpenBackup: () => backupOpened = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تنظیمات'), findsOneWidget);
    expect(find.text('نمایش تاریخ فارسی'), findsOneWidget);
    expect(find.textContaining('فونت پیش‌فرض'), findsOneWidget);

    await tester.tap(find.text('تیره'));
    await tester.pumpAndSettle();
    expect((await service.load()).themeMode, ThemeMode.dark);
    expect(changed?.themeMode, ThemeMode.dark);

    await tester.tap(find.text('نمایش تاریخ فارسی'));
    await tester.pumpAndSettle();
    expect((await service.load()).usePersianDate, isTrue);
    expect(changed?.usePersianDate, isTrue);

    await tester.tap(find.text('پشتیبان‌گیری و بازیابی'));
    await tester.pumpAndSettle();
    expect(backupOpened, isTrue);
  });
}
