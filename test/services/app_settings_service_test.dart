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

  test('portable settings round-trip theme date and font', () async {
    final service = AppSettingsService();
    const source = AppSettings(
      themeMode: ThemeMode.dark,
      usePersianDate: true,
      fontFamily: 'Vazirmatn',
    );

    final json = service.toPortableJson(source);
    expect(json, {
      'themeMode': 'dark',
      'usePersianDate': true,
      'fontFamily': 'Vazirmatn',
    });

    final decoded = service.decodePortableJson(json);
    expect(decoded.themeMode, ThemeMode.dark);
    expect(decoded.usePersianDate, isTrue);
    expect(decoded.fontFamily, 'Vazirmatn');
  });

  test('portable restore saves settings through existing preference keys', () async {
    final service = AppSettingsService();

    final restored = await service.restorePortableJson({
      'themeMode': 'light',
      'usePersianDate': true,
      'fontFamily': '  Vazirmatn  ',
    });

    expect(restored.themeMode, ThemeMode.light);
    expect(restored.usePersianDate, isTrue);
    expect(restored.fontFamily, 'Vazirmatn');

    final loaded = await service.load();
    expect(loaded.themeMode, ThemeMode.light);
    expect(loaded.usePersianDate, isTrue);
    expect(loaded.fontFamily, 'Vazirmatn');
  });

  test('portable decoder rejects malformed or unsupported settings', () {
    final service = AppSettingsService();

    expect(
      () => service.decodePortableJson({'themeMode': 7}),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => service.decodePortableJson({'themeMode': 'sepia'}),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => service.decodePortableJson({'usePersianDate': 'yes'}),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => service.decodePortableJson({'fontFamily': <String>[]}),
      throwsA(isA<FormatException>()),
    );
  });

  test('portable decoder keeps missing optional keys backward compatible', () {
    final settings = AppSettingsService().decodePortableJson({});

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.usePersianDate, isFalse);
    expect(settings.fontFamily, isNull);
  });
}
