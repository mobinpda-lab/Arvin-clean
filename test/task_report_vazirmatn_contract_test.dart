import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer declares local VazirHarf loading and no Google font loader', () {
    final source = File('lib/services/task_report_pdf_renderer.dart').readAsStringSync();
    expect(source, contains('assets/fonts/vazirharf/fonts/ttf/Vazirharf-Regular.ttf'));
    expect(source, contains('assets/fonts/vazirharf/fonts/ttf/Vazirharf-Bold.ttf'));
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_boldFontAsset)'));
    expect(source, isNot(contains('PdfGoogleFonts')));
    expect(source, isNot(contains("package:printing/printing.dart")));
  });

  test('UI manifest includes all nine official Vazirmatn faces', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final fontDirectory = Directory('assets/fonts/ui/vazirmatn');
    expect(fontDirectory.existsSync(), isTrue);
    for (final file in <String>[
      'Vazirmatn-Thin.ttf',
      'Vazirmatn-ExtraLight.ttf',
      'Vazirmatn-Light.ttf',
      'Vazirmatn-Regular.ttf',
      'Vazirmatn-Medium.ttf',
      'Vazirmatn-SemiBold.ttf',
      'Vazirmatn-Bold.ttf',
      'Vazirmatn-ExtraBold.ttf',
      'Vazirmatn-Black.ttf'
    ]) {
      expect(File('${fontDirectory.path}/$file').existsSync(), isTrue, reason: file);
      expect(pubspec, contains(file));
    }
    for (final weight in <int>[100, 200, 300, 400, 500, 600, 700, 800, 900]) {
      expect(pubspec, contains('weight: $weight'));
    }
  });

  test('UI and PDF typography are intentionally separate', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final fontsSource = File('lib/theme/app_fonts.dart').readAsStringSync();
    expect(mainSource, contains('AppFonts.vazirmatnFamily'));
    expect(fontsSource, contains("static const String vazirmatnFamily = 'Vazirmatn';"));
    expect(fontsSource, contains("static const String vazirharfFamily = 'VazirHarf';"));
  });
}
