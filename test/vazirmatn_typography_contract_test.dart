import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('application typography uses only the approved Vazirmatn weight range',
      () async {
    final violations = <String>[];
    await for (final entity
        in Directory('lib').list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = await entity.readAsLines();
      for (var index = 0; index < lines.length; index++) {
        if (RegExp(r'FontWeight\.w(?:800|900)').hasMatch(lines[index])) {
          violations.add('${entity.path}:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Unsupported 800/900 weights force synthetic or substituted bolding.',
    );
  });

  test('light and dark TextThemes share the approved semantic weights', () {
    final source = File('lib/main.dart').readAsStringSync();

    for (final token in <String>[
      'bodyLarge: lightBaseTextTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w400',
      'bodyMedium: lightBaseTextTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w400',
      'bodySmall: lightBaseTextTheme.bodySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w400',
      'titleLarge: lightBaseTextTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700',
      'labelLarge: lightBaseTextTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500',
      'bodyLarge: darkBaseTextTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w400',
      'bodyMedium: darkBaseTextTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w400',
      'bodySmall: darkBaseTextTheme.bodySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w400',
      'titleLarge: darkBaseTextTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700',
      'labelLarge: darkBaseTextTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500',
    ]) {
      expect(source, contains(token));
    }
  });

  test('application does not use network font loaders', () async {
    final violations = <String>[];
    await for (final entity
        in Directory('lib').list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = await entity.readAsString();
      if (source.contains('GoogleFonts') ||
          source.contains('package:google_fonts/')) {
        violations.add(entity.path);
      }
    }
    expect(violations, isEmpty);
  });
}
