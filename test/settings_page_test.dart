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
    expect(find.text('نمایش تاریخ فارسی'), findsOneWidget);
    expect((await service.load()).usePersianDate, isTrue);
    expect(find.byKey(const ValueKey('swipe-settings-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('swipe-right-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('swipe-left-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('font-settings-entry')), findsOneWidget);

    await tester.tap(find.text('تیره'));
    await tester.pumpAndSettle();
    expect((await service.load()).themeMode, ThemeMode.dark);
    expect(changed?.themeMode, ThemeMode.dark);

    await tester.tap(find.text('نمایش تاریخ فارسی'));
    await tester.pumpAndSettle();
    expect((await service.load()).usePersianDate, isFalse);
    expect(changed?.usePersianDate, isFalse);

    await tester.tap(find.byKey(const ValueKey('font-settings-entry')));
    await tester.pumpAndSettle();
    expect(find.text('انتخاب فونت'), findsOneWidget);
    expect((await service.load()).fontFamily, isNull);
    expect(find.byKey(const ValueKey('font-option-vazirmatn')), findsOneWidget);
    expect(find.byKey(const ValueKey('font-option-system')), findsOneWidget);
    expect(find.byType(RadioListTile<String>), findsNWidgets(2));
    expect(find.text('وزیر متن'), findsWidgets);
    expect(find.text('فونت پیش‌فرض'), findsOneWidget);
    expect(find.text('فونت اصلی و پیش‌فرض آروین؛ فایل‌های آن همراه برنامه بسته‌بندی می‌شوند'), findsNothing);
    expect(find.text('فونت پیش‌فرض سیستم؛ بدون نیاز به فایل اضافی'), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('font-option-system')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('font-option-system')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('font-option-system')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('font-option-system')));
    await tester.pumpAndSettle();
    expect((await service.load()).fontFamily, 'system');

    await tester.tap(find.byKey(const ValueKey('font-settings-entry')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('font-option-vazirmatn')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('font-option-vazirmatn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('font-option-vazirmatn')));
    await tester.pumpAndSettle();
    expect(find.text('انتخاب فونت'), findsNothing);
    expect((await service.load()).fontFamily, 'vazirmatn');

    // Recreate the Settings page to prove the selected font is reloaded from
    // persistent settings rather than retained only in widget state.
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          service: AppSettingsService(),
          onSettingsChanged: (value) => changed = value,
          onOpenBackup: () => backupOpened = true,
          onOpenBackupSchedule: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('وزیر متن'), findsOneWidget);
    expect((await AppSettingsService().load()).fontFamily, 'vazirmatn');

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

    await tester.ensureVisible(find.byKey(const ValueKey('projects-settings-entry')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('projects-settings-entry')));
    await tester.pumpAndSettle();
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('هنوز پروژه‌ای ساخته نشده است.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await tester.dragFrom(const Offset(400, 400), const Offset(0, -250));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text('پشتیبان‌گیری و بازیابی'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('پشتیبان‌گیری و بازیابی'));
    await tester.pumpAndSettle();
    expect(backupOpened, isTrue);
  });
}
