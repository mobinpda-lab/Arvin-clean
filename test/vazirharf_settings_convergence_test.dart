import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/theme/font_registry.dart';

void main() {
  test('canonical Settings uses Vazirmatn as the sole font option', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final settingsSource = File('lib/settings_page.dart').readAsStringSync();

    expect(mainSource, contains("import 'theme/font_registry.dart';"));
    expect(kAvailableArvinFonts.map((font) => font.id).toSet(),
        <String>{'vazirmatn'});
    expect(kAvailableArvinFonts.single.nameFa, 'وزیرمتن');
    expect(kAvailableArvinFonts.single.fontFamily, 'Vazirmatn');
    expect(arvinFontById('vazirmatn').effectiveFontFamily, 'Vazirmatn');
    expect(arvinFontById('vazirharf').id, 'vazirmatn');
    expect(arvinFontById('system').id, 'vazirmatn');
    expect(arvinFontById('unknown-font').id, 'vazirmatn');
    expect(settingsSource, contains("ValueKey('font-settings-entry')"));
    expect(settingsSource, contains("ValueKey('font-option-${option.id}')"));
  });

  test('font catalog contains only the canonical Vazirmatn choice', () {
    expect(kAvailableArvinFonts, hasLength(1));
    expect(kAvailableArvinFonts.single.id, 'vazirmatn');
    expect(kAvailableArvinFonts.single.nameFa, 'وزیرمتن');
    expect(kAvailableArvinFonts.single.fontFamily, 'Vazirmatn');
  });

  test('release APK builds the canonical Vazirmatn app entrypoint', () {
    final workflow = File('.github/workflows/build.yml').readAsStringSync();

    expect(workflow, contains('flutter build apk --${{ matrix.variant }} -t lib/main.dart'));
    expect(workflow, isNot(contains('-t lib/main_iransans.dart')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_REGULAR_B64')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_BOLD_B64')));
  });
}
