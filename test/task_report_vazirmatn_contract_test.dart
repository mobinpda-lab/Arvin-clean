import 'dart:io';

import 'package:flutter/services.dart';
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
      contains('assets/fonts/vazirmatn/Vazirmatn-UI-FD-Medium.ttf'),
    );
    expect(
      source,
      contains('assets/fonts/vazirmatn/Vazirmatn-UI-FD-SemiBold.ttf'),
    );
    expect(
      source,
      contains('assets/fonts/vazirmatn/Vazirmatn-UI-FD-Bold.ttf'),
    );
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_mediumFontAsset)'));
    expect(source, contains('rootBundle.load(_semiBoldFontAsset)'));
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

  test('Vazirmatn UI FD font files are bundled locally', () async {
    final regular = await rootBundle.load(
      'assets/fonts/vazirmatn/Vazirmatn-UI-FD-Regular.ttf',
    );
    final medium = await rootBundle.load(
      'assets/fonts/vazirmatn/Vazirmatn-UI-FD-Medium.ttf',
    );
    final semiBold = await rootBundle.load(
      'assets/fonts/vazirmatn/Vazirmatn-UI-FD-SemiBold.ttf',
    );
    final bold = await rootBundle.load(
      'assets/fonts/vazirmatn/Vazirmatn-UI-FD-Bold.ttf',
    );

    expect(regular.lengthInBytes, greaterThan(1000));
    expect(medium.lengthInBytes, greaterThan(1000));
    expect(semiBold.lengthInBytes, greaterThan(1000));
    expect(bold.lengthInBytes, greaterThan(1000));
  });
}
