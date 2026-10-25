import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer loads the bundled official Vazirmatn files', () {
    final source = File('lib/services/task_report_pdf_renderer.dart').readAsStringSync();
    expect(source, contains('assets/fonts/vazirmatn/Vazirmatn-Regular.ttf'));
    expect(File('pubspec.yaml').readAsStringSync(), contains('assets/fonts/vazirmatn/Vazirmatn-Light.ttf'));
    expect(source, contains('assets/fonts/vazirmatn/Vazirmatn-Bold.ttf'));
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_boldFontAsset)'));
    expect(source, isNot(contains('PdfGoogleFonts')));
  });

  test('font registry makes Vazirmatn the only local application font', () {
    final source = File('lib/theme/font_registry.dart').readAsStringSync();
    expect(source, contains("id: 'vazirmatn'"));
    expect(source, contains('fontFamily: AppFonts.vazirmatnFamily'));
    expect(source, isNot(contains("id:'vazirharf'")));
    expect(source, isNot(contains("id:'system'")));
  });

  test('pubspec packages official Vazirmatn weights', () {
    final source = File('pubspec.yaml').readAsStringSync();
    expect(source, contains('family: Vazirmatn'));
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      expect(source, contains('assets/fonts/vazirmatn/Vazirmatn-$weight.ttf'));
    }
  });
}
