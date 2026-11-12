import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Task PDF renderer embeds pinned VazirHarf v34.003 UI-FD fonts', () {
    final source = File(
      'lib/services/task_report_pdf_renderer.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('assets/fonts/ui/vazirharf/Vazirharf-UI-FD-Regular.ttf'),
    );
    expect(
      source,
      contains('assets/fonts/ui/vazirharf/Vazirharf-UI-FD-Bold.ttf'),
    );
    expect(source, contains('rootBundle.load(_regularFontAsset)'));
    expect(source, contains('rootBundle.load(_boldFontAsset)'));
    expect(source, isNot(contains('PdfGoogleFonts')));
    expect(source, isNot(contains("package:printing/printing.dart")));
  });

  test('application light and dark themes enforce the canonical VazirHarf family', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains('lightBaseTextTheme = ThemeData.light().textTheme.apply(\\n      fontFamily: ArvinTheme.fontFamily'));
    expect(source, contains('darkBaseTextTheme = ThemeData.dark().textTheme.apply(\\n      fontFamily: ArvinTheme.fontFamily'));
    expect(source, contains('fontFamily: ArvinTheme.fontFamily'));
    final tokens = File('lib/core/theme/arvin_theme.dart').readAsStringSync();
    expect(tokens, contains("static const String fontFamily = 'VazirHarf';"));
  });

  test('font registry exposes only the canonical VazirHarf option', () {
    final source = File('lib/theme/font_registry.dart').readAsStringSync();
    expect(source, contains("id: 'vazirharf'"));
    expect(source, contains("fontFamily: 'VazirHarf'"));
    expect(source, contains('effectiveFontFamily'));
  });

  test('pubspec declares the pinned VazirHarf UI Persian-digit weights', () {
    final source = File('pubspec.yaml').readAsStringSync();

    expect(source, contains('family: VazirHarf'));
    expect(source, contains('Vazirharf-UI-FD-Light.ttf'));
    expect(source, contains('Vazirharf-UI-FD-Regular.ttf'));
    expect(source, contains('Vazirharf-UI-FD-Medium.ttf'));
    expect(source, contains('Vazirharf-UI-FD-SemiBold.ttf'));
    expect(source, contains('Vazirharf-UI-FD-Bold.ttf'));
    expect(source, contains('weight: 300'));
    expect(source, contains('weight: 400'));
    expect(source, contains('weight: 500'));
    expect(source, contains('weight: 600'));
    expect(source, contains('weight: 700'));
  });
}
