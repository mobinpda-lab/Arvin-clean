import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer declares the canonical Vazirmatn UI FD weights and no Google font loader', () {
    final source = File(
      'lib/services/task_report_pdf_renderer.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-Regular.ttf'),
    );
    expect(
      source,
      contains('assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-Bold.ttf'),
    );
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_mediumFontAsset)'));
    expect(source, contains('rootBundle.load(_semiBoldFontAsset)'));
    expect(source, contains('rootBundle.load(_boldFontAsset)'));
    expect(source, isNot(contains('PdfGoogleFonts')));
    expect(source, isNot(contains("package:printing/printing.dart")));
  });

  test('font registry enables the bundled Vazirmatn UI family', () {
    final source = File('lib/theme/font_registry.dart').readAsStringSync();
    expect(source, contains("id:'vazirmatn'"));
    expect(source, contains("fontFamily:'Vazirmatn', isAvailableLocally:true"));
    expect(source, contains('effectiveFontFamily'));
  });

  test('pubspec declares font asset paths and registry uses safe fallback', () {
    final source = File('pubspec.yaml').readAsStringSync();

    expect(source, contains('assets/fonts/'));
    expect(source, contains('Vazirharf-Regular.ttf'));
    expect(source, contains('Vazirharf-Bold.ttf'));
  });
}
