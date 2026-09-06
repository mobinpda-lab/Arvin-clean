import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSettingsService extends AppSettingsService {
  _FakeSettingsService(this.value);

  AppSettings value;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> saveUsePersianDate(bool value) async {
    this.value = this.value.copyWith(usePersianDate: value);
  }
}

void main() {
  testWidgets('settings exposes date, swipe and canonical backup controls', (
    tester,
  ) async {
    var backupOpened = false;
    AppSettings? changed;
    final service = _FakeSettingsService(const AppSettings());

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
    expect(find.byType(SwitchListTile), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect((await service.load()).usePersianDate, isFalse);
    expect(changed?.usePersianDate, isFalse);

    await tester.scrollUntilVisible(
      find.text('پشتیبان‌گیری و بازیابی'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Vazirharf فونت عمومی و پیش‌فرض آروین است'),
      findsOneWidget,
    );
    await tester.tap(find.text('پشتیبان‌گیری و بازیابی'));
    await tester.pumpAndSettle();
    expect(backupOpened, isTrue);
  });
}
