import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/theme/font_registry.dart';

void main() {
  test('canonical Settings keeps legacy VazirHarf as a safe fallback option', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final fontsSource = File('lib/theme/app_fonts.dart').readAsStringSync();
    final settingsSource = File('lib/settings_page.dart').readAsStringSync();

    expect(mainSource, contains("import 'theme/app_fonts.dart';"));
    expect(fontsSource, contains("static const String vazirharfFamily = 'VazirHarf';"));
    expect(arvinFontById('vazirharf').effectiveFontFamily, isNull);
    expect(settingsSource, contains("ValueKey('font-settings-entry')"));
  });

  test('font catalog contains supported choices and safe fallback behavior', () {
    expect(kAvailableArvinFonts.map((font) => font.id).toSet(), containsAll(<String>{'vazirmatn','estedad','sahel','shabnam','samim','tanha','gandom','parastoo','mikhak','lalezar','vazir-code','system','vazirharf'}));
    expect(arvinFontById('system').effectiveFontFamily, isNull);
    expect(arvinFontById('vazirmatn').effectiveFontFamily, isNull);
    expect(arvinFontById('unknown-font').id, 'vazirharf');
  });

  test('release APK builds the canonical VazirHarf app entrypoint', () {
    final workflow = File('.github/workflows/build.yml').readAsStringSync();

    expect(workflow, contains('flutter build apk --\${{ matrix.variant }} -t lib/main.dart'));
    expect(workflow, isNot(contains('-t lib/main_iransans.dart')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_REGULAR_B64')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_BOLD_B64')));
  });
}
