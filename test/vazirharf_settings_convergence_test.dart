import 'dart:io';

import 'package:arvin/theme/app_fonts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical app theme locks typography to bundled Vazirmatn', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final settingsSource = File('lib/settings_page.dart').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(AppFonts.vazirmatnFamily, 'Vazirmatn');
    expect(mainSource, contains("import 'theme/app_fonts.dart';"));
    expect(mainSource, contains('fontFamily: selectedFontFamily'));
    expect(mainSource, isNot(contains('VazirHarf')));
    expect(settingsSource, contains("ValueKey('font-settings-entry')"));
    expect(settingsSource, contains("Text('اندازه متن')"));
    expect(settingsSource, contains('font-preference-selector'));
    expect(settingsSource, contains('system-default'));
    expect(pubspec, contains('family: Vazirmatn'));
    expect(pubspec, contains('Vazirmatn-Regular.ttf'));
  });

  test('portable settings retain one canonical font and ignore legacy selections', () {
    final source = File('lib/services/app_settings_service.dart').readAsStringSync();
    final start = source.indexOf('Map<String, dynamic> toPortableJson');
    final end = source.indexOf('/// Applies only settings keys', start);
    expect(start, isNonNegative);
    expect(end, greaterThan(start));
    final portableMethod = source.substring(start, end);
    expect(portableMethod, isNot(contains('fontFamily')));
    expect(source, contains("merged.remove('fontFamily')"));
    expect(AppFonts.vazirmatnFamily, 'Vazirmatn');
  });

  test('release APK builds the canonical Vazirmatn app entrypoint', () {
    final workflow = File('.github/workflows/build.yml').readAsStringSync();

    expect(workflow, contains(r'flutter build apk --${{ matrix.variant }} -t lib/main.dart'));
    expect(workflow, contains('FONT_GATE=PASS_VAZIRMATN_5_WEIGHTS_BUNDLED'));
    expect(workflow, isNot(contains('-t lib/main_iransans.dart')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_REGULAR_B64')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_BOLD_B64')));
  });
}
