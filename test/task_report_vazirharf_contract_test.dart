import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer loads the canonical Vazirmatn fonts', () {
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

  test('application light and dark themes honor the canonical font preference', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains('fontFamily: selectedFontFamily'));
    final tokens = File('lib/core/theme/arvin_theme.dart').readAsStringSync();
    expect(tokens, contains('static const String fontFamily = AppFonts.vazirmatnFamily;'));
  });

  test('font registry exposes only the approved Vazirmatn and System Default options', () {
    final source = File('lib/theme/font_registry.dart').readAsStringSync();
    expect(source, contains("id: 'vazirmatn'"));
    expect(source, contains("id: 'system-default'"));
    expect(source, contains('fontFamily: AppFonts.vazirmatnFamily'));
    expect(source, contains('effectiveFontFamily'));
  });

  test('pubspec declares the official Vazirmatn five-weight family', () {
    final source = File('pubspec.yaml').readAsStringSync();

    expect(source, contains('family: Vazirmatn'));
    expect(source, contains('Vazirmatn-Light.ttf'));
    expect(source, contains('Vazirmatn-Regular.ttf'));
    expect(source, contains('Vazirmatn-Medium.ttf'));
    expect(source, contains('Vazirmatn-SemiBold.ttf'));
    expect(source, contains('Vazirmatn-Bold.ttf'));
    expect(source, contains('weight: 300'));
    expect(source, contains('weight: 400'));
    expect(source, contains('weight: 500'));
    expect(source, contains('weight: 600'));
    expect(source, contains('weight: 700'));
  });
}
