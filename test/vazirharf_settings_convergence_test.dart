import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/theme/font_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('canonical Settings keeps legacy VazirHarf as a safe fallback option', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final fontsSource = File('lib/theme/app_fonts.dart').readAsStringSync();
    final settingsSource = File('lib/settings_page.dart').readAsStringSync();

    expect(mainSource, contains("import 'theme/font_registry.dart';"));
    expect(fontsSource, contains("static const String vazirharfFamily = 'VazirHarf';"));
    expect(arvinFontById('vazirharf').effectiveFontFamily, 'VazirHarf');
    expect(settingsSource, contains("ValueKey('font-settings-entry')"));
  });

  test('font catalog contains supported choices with bundled font families and system fallback', () {
    expect(kAvailableArvinFonts.map((font) => font.id).toSet(), containsAll(<String>{'vazirmatn','estedad','sahel','shabnam','samim','tanha','gandom','parastoo','mikhak','lalezar','vazir-code','system','vazirharf'}));
    expect(arvinFontById('system').effectiveFontFamily, isNull);
    expect(arvinFontById('vazirmatn').effectiveFontFamily, 'Vazirmatn');
    expect(arvinFontById('unknown-font').id, 'vazirharf');
  });

  test('release APK builds the canonical VazirHarf app entrypoint', () {
    final workflow = File('.github/workflows/build.yml').readAsStringSync();

    expect(workflow, contains('flutter build apk --\${{ matrix.variant }} -t lib/main.dart'));
    expect(workflow, isNot(contains('-t lib/main_iransans.dart')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_REGULAR_B64')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_BOLD_B64')));
  });

  test('UI font selection persists through the existing canonical settings key', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const key = 'arvin.settings.fontFamily';
    final service = AppSettingsService();

    for (final family in <String>['Vazirmatn', 'Shabnam', 'VazirHarf']) {
      await service.saveFontFamily(family);
      final loaded = await service.load();
      final preferences = await SharedPreferences.getInstance();
      expect(loaded.fontFamily, family);
      expect(preferences.getString(key), family);
    }
  });

}
