import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer embeds the bundled Vazirmatn fonts and uses no Google font loader', () {
    final source = File(
      'lib/services/task_report_pdf_renderer.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf'),
    );
    expect(
      source,
      contains('assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf'),
    );
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_boldFontAsset)'));
    expect(source, isNot(contains('PdfGoogleFonts')));
    expect(source, isNot(contains("package:printing/printing.dart")));
  });

  test('application light and dark themes enforce Vazirmatn', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains('lightBaseTextTheme = ThemeData.light().textTheme.apply(\n      fontFamily: AppFonts.vazirmatnFamily'));
    expect(source, contains('darkBaseTextTheme = ThemeData.dark().textTheme.apply(\n      fontFamily: AppFonts.vazirmatnFamily'));
    expect(source, contains('fontFamily: AppFonts.vazirmatnFamily'));
  });

  test('font registry exposes only the required Vazirmatn option', () {
    final source = File('lib/theme/font_registry.dart').readAsStringSync();
    expect(source, contains("id: 'vazirmatn'"));
    expect(source, contains("fontFamily: 'Vazirmatn'"));
    expect(source, contains('effectiveFontFamily'));
  });

  test('pubspec declares bundled Vazirmatn font asset paths', () {
    final source = File('pubspec.yaml').readAsStringSync();

    expect(source, contains('assets/fonts/'));
    expect(source, contains('Vazirmatn-Regular.ttf'));
    expect(source, contains('Vazirmatn-Bold.ttf'));
  });
}
