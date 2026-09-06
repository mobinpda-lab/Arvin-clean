import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer uses bundled Vazirharf and no Google font loader', () {
    final source = File(
      'lib/services/task_report_pdf_renderer.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('assets/fonts/vazirharf/VazirHarf-Regular.ttf'),
    );
    expect(
      source,
      contains('assets/fonts/vazirharf/VazirHarf-Bold.ttf'),
    );
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_boldFontAsset)'));
    expect(source, isNot(contains('PdfGoogleFonts')));
    expect(source, isNot(contains("package:printing/printing.dart")));
  });

  test('pubspec keeps Vazirharf PDF font assets bundled', () {
    final source = File('pubspec.yaml').readAsStringSync();

    expect(source, contains('assets/fonts/'));
    expect(source, contains('Vazirharf-Regular.ttf'));
    expect(source, contains('Vazirharf-Bold.ttf'));
  });
}
