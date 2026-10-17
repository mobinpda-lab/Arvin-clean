import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PDF renderer loads the three approved local Vazirmatn weights', () {
    final source = File('lib/services/task_report_pdf_renderer.dart').readAsStringSync();
    expect(source, contains('assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf'));
    expect(source, contains('assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf'));
    expect(source, contains('assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf'));
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_mediumFontAsset)'));
    expect(source, contains('rootBundle.load(_boldFontAsset)'));
    expect(source, isNot(contains('PdfGoogleFonts')));
    expect(source, isNot(contains("package:printing/printing.dart")));
  });

  test('AppFonts exposes the approved Vazirmatn family and asset paths', () {
    final source = File('lib/theme/app_fonts.dart').readAsStringSync();
    expect(source, contains("vazirmatnFamily = 'Vazirmatn'"));
    expect(source, contains('Vazirmatn-Regular.ttf'));
    expect(source, contains('Vazirmatn-Medium.ttf'));
    expect(source, contains('Vazirmatn-Bold.ttf'));
  });

  test('pubspec declares only the approved three Vazirmatn weights', () {
    final source = File('pubspec.yaml').readAsStringSync();
    final start = source.indexOf('- family: Vazirmatn\n');
    expect(start, isNonNegative);
    final end = source.indexOf('\n    - family:', start + 1);
    final familyBlock = source.substring(start, end < 0 ? source.length : end);
    expect(familyBlock, contains('Vazirmatn-Regular.ttf'));
    expect(familyBlock, contains('Vazirmatn-Medium.ttf'));
    expect(familyBlock, contains('Vazirmatn-Bold.ttf'));
    expect(familyBlock, isNot(contains('Vazirmatn-SemiBold.ttf')));
    expect(
      File('assets/fonts/ui/vazirmatn/OFL.txt').existsSync(),
      isTrue,
      reason: 'The Vazirmatn OFL license must be present beside the bundled font files.',
    );
    expect(source, contains('Vazirharf-Regular.ttf'));
    expect(source, contains('Vazirharf-Bold.ttf'));
  });
}
