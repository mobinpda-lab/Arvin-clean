import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer uses bundled Vazirmatn and no Google font loader', () {
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

  test('pubspec keeps Vazirmatn PDF font assets bundled', () {
    final source = File('pubspec.yaml').readAsStringSync();

    expect(source, contains('assets/fonts/'));
    expect(source, contains('Vazirmatn-UI-FD-Regular.ttf'));
    expect(source, contains('Vazirmatn-UI-FD-Bold.ttf'));
  });
}
