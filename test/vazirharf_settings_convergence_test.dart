import 'dart:io';

import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/theme/app_fonts.dart';
import 'package:arvin/theme/font_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Vazirmatn is the canonical bundled app font', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final settingsSource = File('lib/settings_page.dart').readAsStringSync();

    expect(AppFonts.vazirmatnFamily, 'Vazirmatn');
    expect(arvinFontById('vazirmatn').effectiveFontFamily, 'Vazirmatn');
    expect(arvinFontById('VazirHarf').id, 'vazirmatn');
    expect(arvinFontById('unknown-font').id, 'vazirmatn');
    expect(pubspec, contains('family: Vazirmatn'));
    expect(pubspec, contains('assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf'));
    expect(pubspec, contains('assets/fonts/ui/vazirmatn/Vazirmatn-SemiBold.ttf'));
    expect(pubspec, isNot(contains('family: VazirHarf')));
    expect(mainSource, contains("settings.fontFamily ?? 'vazirmatn'"));
    expect(settingsSource, contains("current.fontFamily ?? 'vazirmatn'"));
  });

  test('legacy VazirHarf preferences converge to Vazirmatn', () async {
    final service = AppSettingsService();

    await service.saveFontFamily('  VazirHarf  ');
    expect((await service.load()).fontFamily, 'vazirmatn');

    final restored = service.decodePortableJson({'fontFamily': 'VazirHarf'});
    expect(restored.fontFamily, 'vazirmatn');
  });

  test('all selectable public font ids retain one canonical settings path', () {
    expect(
      kAvailableArvinFonts.map((font) => font.id).toSet(),
      <String>{'vazirmatn', 'system'},
    );
    expect(kAvailableArvinFonts.map((font) => font.id), isNot(contains('vazirharf')));
    expect(arvinFontById('estedad').id, 'vazirmatn');
    expect(arvinFontById('sahel').id, 'vazirmatn');
    expect(arvinFontById('system').effectiveFontFamily, isNull);
  });

  test('active typography contracts do not reintroduce VazirHarf as default', () {
    final styleLock = File('docs/HOME_STYLE_LOCK.md').readAsStringSync();
    final settingsContract =
        File('docs/CANONICAL_APP_SETTINGS_2026-08-26.md').readAsStringSync();
    final reportContract =
        File('docs/arvin-memory/ARVIN_REPORT_FILTER_DECISION.md')
            .readAsStringSync();
    final liveLedger =
        File('docs/ARVIN_LIVE_REMAINING_WORK_2026-09-28.md')
            .readAsStringSync();
    final evaluation =
        File('docs/ai/arvin-project-evaluation.md').readAsStringSync();
    final evidenceMap =
        File('docs/arvin-memory/ARVIN_EVIDENCE_MAP.md').readAsStringSync();

    expect(styleLock, contains('Vazirmatn v33.003 is the canonical'));
    expect(settingsContract, contains('canonical public/default Arvin font'));
    expect(reportContract, contains('Vazirmatn v33.003'));
    expect(liveLedger, isNot(contains('- VazirHarf v34.003 پیش‌فرض.')));
    expect(evaluation, isNot(contains('- VazirHarf remains the legacy/unset default;')));
    expect(evidenceMap, contains('Vazirmatn v33.003 Regular 400'));
    expect(evidenceMap, isNot(contains('VazirHarf declared; Vazirmatn asset not found')));
  });

  test('Build uses tracked fonts and verifies the packaged family', () {
    final build = File('.github/workflows/build.yml').readAsStringSync();
    expect(build, contains('Verify tracked Vazirmatn assets'));
    expect(build, contains('Verify packaged Vazirmatn font identity'));
    expect(build, contains('flutter build apk --'));
    expect(build, isNot(contains('github.com/nadalaba/vazirharf.git')));
    expect(build, isNot(contains('Restore VazirHarf assets')));
  });
}
