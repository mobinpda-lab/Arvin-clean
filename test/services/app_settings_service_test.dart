import 'package:arvin/services/app_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads safe defaults from existing SharedPreferences foundation', () async {
    final settings = await AppSettingsService().load();

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.usePersianDate, isFalse);
    expect(settings.fontFamily, isNull);
  });

  test('persists theme and Persian-date preferences without a second store', () async {
    final service = AppSettingsService();

    await service.saveThemeMode(ThemeMode.dark);
    await service.saveUsePersianDate(true);

    final settings = await service.load();
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.usePersianDate, isTrue);
  });

  test('normalizes empty font selection back to app default', () async {
    final service = AppSettingsService();

    await service.saveFontFamily('  Vazirmatn  ');
    expect((await service.load()).fontFamily, 'Vazirmatn');

    await service.saveFontFamily('   ');
    expect((await service.load()).fontFamily, isNull);
  });
}
