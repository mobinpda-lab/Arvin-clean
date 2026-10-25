import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/theme/app_fonts.dart';
import 'package:arvin/theme/font_registry.dart';

void main() {
  test('Vazirmatn is the sole canonical app font and legacy settings resolve to it', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final fontsSource = File('lib/theme/app_fonts.dart').readAsStringSync();
    final settingsSource = File('lib/settings_page.dart').readAsStringSync();

    expect(mainSource, contains("settings.fontFamily ?? 'vazirmatn'"));
    expect(fontsSource, contains("static const String vazirmatnFamily = 'Vazirmatn';"));
    expect(arvinFontById('vazirharf').effectiveFontFamily, AppFonts.vazirmatnFamily);
    expect(arvinFontById('system').effectiveFontFamily, AppFonts.vazirmatnFamily);
    expect(kAvailableArvinFonts, hasLength(1));
    expect(settingsSource, contains("ValueKey('font-settings-entry')"));
  });

  test('pinned official font fetch provides the bundled weights and license', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final script = File('tool/fetch_vazirmatn.sh').readAsStringSync();
    expect(pubspec, contains('family: Vazirmatn'));
    expect(script, contains('83629f877e8f084cc07b47030b5d3a0ff06c76ec'));
    expect(script, contains('Vazirmatn-$weight.ttf'));
    expect(File('assets/fonts/vazirmatn/OFL.txt').existsSync(), isTrue);
  });
}
