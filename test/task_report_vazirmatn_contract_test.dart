import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('official Task PDF renderer uses local Vazirmatn UI FD and no Google font loader', () {
    final source = File(
      'lib/services/task_report_pdf_renderer.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('assets/fonts/vazirmatn/Vazirmatn-UI-FD-Regular.ttf'),
    );
    expect(
      source,
      contains('assets/fonts/vazirmatn/Vazirmatn-UI-FD-Bold.ttf'),
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

  test('pubspec bundles Vazirmatn UI FD PDF assets and preserves UI font registry fallback', () {
    final source = File('pubspec.yaml').readAsStringSync();

    expect(source, contains('assets/fonts/'));
    expect(source, contains('assets/fonts/vazirmatn/'));
    expect(source, contains('Vazirmatn-UI-FD-Regular.ttf'));
    expect(source, contains('Vazirmatn-UI-FD-Bold.ttf'));
  });
}
