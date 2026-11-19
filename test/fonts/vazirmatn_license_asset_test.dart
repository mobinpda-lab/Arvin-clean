import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Vazirmatn v33.003 bundles license, authors and all nine static weights', () async {
    final license = await rootBundle.loadString(
      'assets/fonts/ui/vazirmatn/LICENSE.txt',
    );
    final authors = await rootBundle.loadString(
      'assets/fonts/ui/vazirmatn/AUTHORS.txt',
    );

    expect(license, contains('SIL OPEN FONT LICENSE Version 1.1'));
    expect(license, contains('Copyright 2015 The Vazirmatn Project Authors'));
    expect(authors, contains('Saber Rastikerdar'));

    const expectedFonts = <int, String>{
      100: 'assets/fonts/ui/vazirmatn/Vazirmatn-Thin.ttf',
      200: 'assets/fonts/ui/vazirmatn/Vazirmatn-ExtraLight.ttf',
      300: 'assets/fonts/ui/vazirmatn/Vazirmatn-Light.ttf',
      400: 'assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf',
      500: 'assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf',
      600: 'assets/fonts/ui/vazirmatn/Vazirmatn-SemiBold.ttf',
      700: 'assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf',
      800: 'assets/fonts/ui/vazirmatn/Vazirmatn-ExtraBold.ttf',
      900: 'assets/fonts/ui/vazirmatn/Vazirmatn-Black.ttf',
    };

    final manifestJson = await rootBundle.loadString('FontManifest.json');
    final manifest = (jsonDecode(manifestJson) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final family = manifest.singleWhere(
      (entry) => entry['family'] == 'Vazirmatn',
    );
    final fontEntries = (family['fonts'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    expect(fontEntries, hasLength(expectedFonts.length));
    expect(
      fontEntries.map((entry) => entry['weight']).toSet(),
      expectedFonts.keys.toSet(),
    );

    for (final expected in expectedFonts.entries) {
      final entry = fontEntries.singleWhere(
        (font) => font['weight'] == expected.key,
      );
      expect(entry['asset'], expected.value);
      final bytes = await rootBundle.load(expected.value);
      expect(bytes.lengthInBytes, greaterThan(0));
    }
  });
}
