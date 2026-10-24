import 'dart:io';

import 'package:arvin/theme/app_fonts.dart';
import 'package:arvin/theme/font_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical UI font registry exposes only Vazirmatn', () {
    expect(kAvailableArvinFonts, hasLength(1));
    expect(kCanonicalArvinFont.id, 'vazirmatn');
    expect(kCanonicalArvinFont.effectiveFontFamily, AppFonts.vazirmatnFamily);
    expect(arvinFontById('VazirHarf').effectiveFontFamily, AppFonts.vazirmatnFamily);
    expect(arvinFontById('system').effectiveFontFamily, AppFonts.vazirmatnFamily);
    expect(arvinFontById('unknown-font').effectiveFontFamily, AppFonts.vazirmatnFamily);
  });

  test('canonical manifest registers all five Vazirmatn role weights', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final declaration in <String>[
      'family: Vazirmatn',
      'Vazirmatn-Light.ttf',
      'Vazirmatn-Regular.ttf',
      'Vazirmatn-Medium.ttf',
      'Vazirmatn-SemiBold.ttf',
      'Vazirmatn-Bold.ttf',
      'weight: 300',
      'weight: 400',
      'weight: 500',
      'weight: 600',
      'weight: 700',
    ]) {
      expect(pubspec, contains(declaration));
    }
  });

  test('Settings no longer exposes an alternate font picker', () {
    final settingsSource = File('lib/settings_page.dart').readAsStringSync();
    expect(settingsSource, contains('وزیرمتن (Vazirmatn)'));
    expect(settingsSource, isNot(contains('_showFontPicker')));
    expect(settingsSource, isNot(contains('انتخاب فونت')));
  });

  test('PDF remains explicitly separate from the canonical UI family', () {
    final renderer = File('lib/services/task_report_pdf_renderer.dart').readAsStringSync();
    expect(renderer, contains('assets/fonts/vazirharf/fonts/ttf/Vazirharf-Regular.ttf'));
    expect(renderer, contains('assets/fonts/vazirharf/fonts/ttf/Vazirharf-Bold.ttf'));
  });
}
