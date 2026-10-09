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

  testWidgets('settings exposes date, swipe, projects and canonical backup controls',
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
          onOpenBackupSchedule: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('راهنمای استفاده'), findsNothing);
    expect(find.text('راهنمای تعاملی صفحه اصلی'), findsNothing);

    expect(find.text('تنظیمات'), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-settings-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-permission-status')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-system-settings-entry')), findsOneWidget);
    expect(find.text('نمایش تاریخ فارسی'), findsOneWidget);
    expect((await service.load()).usePersianDate, isTrue);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('swipe-settings-title')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('swipe-settings-title')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('swipe-right-action')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('swipe-right-action')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('swipe-left-action')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('swipe-left-action')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('font-settings-entry')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('font-settings-entry')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تیره'),
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('تیره'));
    await tester.pumpAndSettle();
    expect((await service.load()).themeMode, ThemeMode.dark);
    expect(changed?.themeMode, ThemeMode.dark);

    await tester.scrollUntilVisible(
      find.text('نمایش تاریخ فارسی'),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('نمایش تاریخ فارسی'));
    await tester.pumpAndSettle();
    expect((await service.load()).usePersianDate, isFalse);
    expect(changed?.usePersianDate, isFalse);

    await tester.tap(find.byKey(const ValueKey('font-settings-entry')));
    await tester.pumpAndSettle();
    expect(find.text('انتخاب فونت'), findsOneWidget);
    expect(find.text('VazirHarf'), findsNWidgets(2));
    expect((await service.load()).fontFamily, isNull);

    await tester.tap(find.text('فونت دستگاه'));
    await tester.pumpAndSettle();
    expect((await service.load()).fontFamily, 'system');

    await tester.tap(find.byKey(const ValueKey('font-settings-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('VazirHarf').last);
    await tester.pumpAndSettle();
    expect((await service.load()).fontFamily, 'VazirHarf');

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('projects-settings-entry')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('projects-settings-entry')), findsOneWidget);
    expect(find.byKey(const ValueKey('taxonomy-settings-entry')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('taxonomy-settings-entry')));
    await tester.pumpAndSettle();
    expect(find.text('دسته‌ها و برچسب‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('taxonomy-create-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('taxonomy-create-tag')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('projects-settings-entry')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('projects-settings-entry')));
    await tester.pumpAndSettle();
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('هنوز پروژه‌ای ساخته نشده است.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('پشتیبان‌گیری و بازیابی'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('پشتیبان‌گیری و بازیابی'));
    await tester.pumpAndSettle();
    expect(backupOpened, isTrue);
  });
}
