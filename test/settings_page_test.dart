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

  testWidgets('settings exposes date, swipe and canonical backup controls',
      (tester) async {
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
    expect((await service.load()).usePersianDate, isTrue);
    expect(find.byKey(const ValueKey('swipe-settings-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('swipe-right-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('swipe-left-action')), findsOneWidget);

    await tester.tap(find.text('تیره'));
    await tester.pumpAndSettle();
    expect((await service.load()).themeMode, ThemeMode.dark);
    expect(changed?.themeMode, ThemeMode.dark);

    await tester.tap(find.text('نمایش تاریخ فارسی'));
    await tester.pumpAndSettle();
    expect((await service.load()).usePersianDate, isFalse);
    expect(changed?.usePersianDate, isFalse);

    await tester.scrollUntilVisible(
      find.text('پشتیبان‌گیری و بازیابی'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('وزیرمتن فونت عمومی و پیش‌فرض آروین است'),
        findsOneWidget);
    await tester.tap(find.text('پشتیبان‌گیری و بازیابی'));
    await tester.pumpAndSettle();
    expect(backupOpened, isTrue);
  });
}
