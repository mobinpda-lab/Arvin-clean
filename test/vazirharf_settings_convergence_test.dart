import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/theme/app_fonts.dart';

void main() {
  test('canonical app theme locks typography to bundled Vazirmatn', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final settingsSource = File('lib/settings_page.dart').readAsStringSync();

    expect(AppFonts.vazirmatnFamily, 'Vazirmatn');
    expect(mainSource, contains("import 'theme/app_fonts.dart';"));
    expect(mainSource, contains('fontFamily: AppFonts.vazirmatnFamily'));
    expect(settingsSource, contains("ValueKey('font-settings-entry')"));
    expect(settingsSource, contains("Text('اندازه متن')"));
    expect(settingsSource, isNot(contains('font-option-')));
    expect(settingsSource, isNot(contains('انتخاب فونت')));
  });

  test('portable settings do not export a user-selectable font', () {
    final source = File('lib/services/app_settings_service.dart').readAsStringSync();
    final start = source.indexOf('Map<String, dynamic> toPortableJson');
    final end = source.indexOf('/// Applies only settings keys', start);
    expect(start, isNonNegative);
    expect(end, greaterThan(start));
    final portableMethod = source.substring(start, end);
    expect(portableMethod, isNot(contains('fontFamily')));
    expect(AppFonts.vazirmatnFamily, 'Vazirmatn');
  });

  test('release APK builds the canonical Vazirmatn app entrypoint', () {
    final workflow = File('.github/workflows/build.yml').readAsStringSync();

    expect(workflow, contains('flutter build apk --${{ matrix.variant }} -t lib/main.dart'));
    expect(workflow, isNot(contains('-t lib/main_iransans.dart')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_REGULAR_B64')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_BOLD_B64')));
  });
}
