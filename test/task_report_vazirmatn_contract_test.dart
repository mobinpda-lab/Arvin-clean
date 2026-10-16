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

  test('font registry records optional Vazirmatn with a safe fallback', () {
    final source = File('lib/theme/font_registry.dart').readAsStringSync();
    expect(source, contains("id:'vazirmatn'"));
    expect(source, contains('isAvailableLocally = false'));
    expect(source, contains('effectiveFontFamily'));
  });

  test('pubspec declares font asset paths and registry uses safe fallback', () {
    final source = File('pubspec.yaml').readAsStringSync();

    expect(source, contains('assets/fonts/'));
    expect(source, contains('Vazirharf-Regular.ttf'));
    expect(source, contains('Vazirharf-Bold.ttf'));
  });
}
