import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('application source uses only approved Vazirmatn weight values', () async {
    final violations = <String>[];
    await for (final entity in Directory('lib').list(recursive: true, followLinks: false)) {
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
      reason: 'Only Vazirmatn weights 300, 400, 500, 600 and 700 are approved.',
    );
  });

  test('application does not load fonts from the network', () async {
    final violations = <String>[];
    await for (final entity in Directory('lib').list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = await entity.readAsString();
      if (source.contains('GoogleFonts') || source.contains('package:google_fonts/')) {
        violations.add(entity.path);
      }
    }
    expect(violations, isEmpty);
  });
}
