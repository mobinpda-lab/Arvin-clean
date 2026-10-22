import 'dart:io';

import 'package:arvin/theme/font_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer loads tracked Vazirmatn and no Google font loader', () {
    final source = File('lib/services/task_report_pdf_renderer.dart').readAsStringSync();

    expect(source, contains('assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf'));
    expect(source, contains('assets/fonts/ui/vazirmatn/Vazirmatn-SemiBold.ttf'));
    expect(source, contains('assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf'));
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_boldFontAsset)'));
    expect(source, isNot(contains('PdfGoogleFonts')));
    expect(source, isNot(contains("package:printing/printing.dart")));
  });

  test('font registry marks Vazirmatn available and distinct from VazirHarf', () {
    final source = File('lib/theme/font_registry.dart').readAsStringSync();
    expect(source, contains("id: 'vazirmatn'"));
    expect(source, contains('isAvailableLocally: true'));
    expect(arvinFontById('vazirmatn').effectiveFontFamily, 'Vazirmatn');
    expect(arvinFontById('VazirHarf').id, 'vazirmatn');
  });

  test('pubspec registers the four tracked Vazirmatn weights', () {
    final source = File('pubspec.yaml').readAsStringSync();
    expect(source, contains('family: Vazirmatn'));
    expect(source, contains('Vazirmatn-Regular.ttf'));
    expect(source, contains('Vazirmatn-Medium.ttf'));
    expect(source, contains('Vazirmatn-SemiBold.ttf'));
    expect(source, contains('Vazirmatn-Bold.ttf'));
    expect(source, isNot(contains('Vazirharf-Regular.ttf')));
  });

  test('CI does not download or inject VazirHarf into the build', () {
    for (final path in <String>[
      '.github/workflows/build.yml',
      '.github/workflows/device-smoke.yml',
      '.github/workflows/release-closure.yml',
      '.github/workflows/final-head-release-validation.yml',
      '.github/workflows/arvin-test-worker.yml',
      '.github/workflows/calendar-provider-acceptance.yml',
    ]) {
      final workflow = File(path).readAsStringSync();
      expect(workflow, isNot(contains('github.com/nadalaba/vazirharf.git')), reason: path);
      expect(workflow, isNot(contains('Restore VazirHarf assets')), reason: path);
    }
  });
}
