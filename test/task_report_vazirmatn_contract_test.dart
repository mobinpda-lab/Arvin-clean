import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer declares local font loading and no Google font loader', () {
    final source = File(
      'lib/services/task_report_pdf_renderer.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('assets/fonts/vazirharf/fonts/ttf/Vazirharf-Regular.ttf'),
    );
    expect(
      source,
      contains('assets/fonts/vazirharf/fonts/ttf/Vazirharf-Bold.ttf'),
    );
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_boldFontAsset)'));
    expect(source, isNot(contains('PdfGoogleFonts')));
    expect(source, isNot(contains("package:printing/printing.dart")));
  });

  test('font registry marks locally bundled Vazirmatn as available', () {
    final source = File('lib/theme/font_registry.dart').readAsStringSync();
    expect(source, contains("id: 'vazirmatn'"));
    expect(source, contains("fontFamily: 'Vazirmatn'"));
    expect(source, contains('isAvailableLocally: true'));
    expect(source, contains('effectiveFontFamily'));
  });

  test('pubspec declares local Vazirmatn and VazirHarf font families', () {
    final source = File('pubspec.yaml').readAsStringSync();

    expect(source, contains('assets/fonts/'));
    expect(source, contains('assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf'));
    expect(source, contains('assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf'));
    expect(source, contains('assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf'));
    expect(source, contains('Vazirharf-Regular.ttf'));
    expect(source, contains('Vazirharf-Bold.ttf'));
  });

  test('Vazirmatn TTF assets exist locally in the repository', () {
    for (final path in [
      'assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf',
      'assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf',
      'assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}
