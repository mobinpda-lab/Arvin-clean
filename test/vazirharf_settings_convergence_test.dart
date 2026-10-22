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
      containsAll(<String>{
        'vazirmatn', 'estedad', 'sahel', 'shabnam', 'samim', 'tanha',
        'gandom', 'parastoo', 'mikhak', 'lalezar', 'vazir-code', 'system',
      }),
    );
    expect(kAvailableArvinFonts.map((font) => font.id), isNot(contains('vazirharf')));
    expect(arvinFontById('system').effectiveFontFamily, isNull);
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
