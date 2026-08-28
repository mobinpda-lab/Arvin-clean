import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical Settings uses bundled Vazirmatn as Arvin default', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final settingsSource = File('lib/settings_page.dart').readAsStringSync();

    expect(mainSource, contains("import 'theme/app_fonts.dart';"));
    expect(
      mainSource,
      contains('fontFamily: settings.fontFamily ?? AppFonts.vazirmatnFamily,'),
    );
    expect(settingsSource, contains('وزیرمتن فونت عمومی و پیش‌فرض آروین است'));
  });

  test('release APK builds the canonical Vazirmatn app entrypoint', () {
    final workflow = File('.github/workflows/build.yml').readAsStringSync();

    expect(workflow, contains('flutter build apk --\${{ matrix.variant }} -t lib/main.dart'));
    expect(workflow, isNot(contains('-t lib/main_iransans.dart')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_REGULAR_B64')));
    expect(workflow, isNot(contains('IRANSANSX_FANUM_BOLD_B64')));
  });
}
