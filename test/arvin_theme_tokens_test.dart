import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/arvin_colors.dart';
import 'package:arvin/core/theme/arvin_theme.dart';

void main() {
  group('Arvin design tokens', () {
    test('matches the owner-approved light card palette and typography', () {
      expect(ArvinTheme.primaryTeal, const Color(0xFF008080));
      expect(ArvinTheme.primaryBlue, ArvinTheme.primaryTeal);
      expect(ArvinTheme.primaryPurple, ArvinTheme.primaryBlue);
      expect(ArvinTheme.headerTeal, const Color(0xFF008B8B));
      expect(ArvinTheme.headerBlue, ArvinTheme.headerTeal);
      expect(ArvinTheme.headerPurple, ArvinTheme.headerBlue);
      expect(ArvinTheme.backgroundLight, const Color(0xFFF8F8FB));
      expect(ArvinTheme.cardBackground, const Color(0xFFFDFDFE));
  expect(ArvinTheme.primaryGlow, const Color(0x40008080));
  expect(ArvinTheme.shadowStyle.color, const Color(0x40008080));
  expect(ArvinColors.shadowSoft, const Color(0x40008080));
  expect(ArvinColors.shadowDark, const Color(0x40008080));
      expect(ArvinTheme.cardBorderRadius, BorderRadius.circular(16));
      expect(ArvinTheme.shadowStyle.blurRadius, 10);
      expect(ArvinTheme.shadowStyle.offset, const Offset(0, 4));
      expect(ArvinTheme.fontFamily, 'Vazirmatn');
      expect(ArvinColors.primary, ArvinTheme.primaryBlue);
      expect(ArvinColors.primaryDark, ArvinTheme.headerBlue);
      expect(ArvinColors.primarySoft, const Color(0xFFD9F0EE));
    });

    test('keeps semantic priority and taxonomy colors separate from brand tokens', () {
      expect(ArvinColors.priorityP1, const Color(0xFFDC2626));
      expect(ArvinColors.priorityP2, const Color(0xFFD97706));
      expect(ArvinColors.priorityP3, const Color(0xFF2563EB));
      expect(ArvinColors.priorityP4, const Color(0xFF80829C));
      expect(ArvinColors.time, const Color(0xFF008080));
      expect(ArvinColors.reminder, const Color(0xFFD97706));
      expect(ArvinColors.project, const Color(0xFF7C3AED));
      expect(ArvinColors.category, const Color(0xFF2563EB));
      expect(ArvinColors.tag, const Color(0xFF16A34A));
      expect({
        ArvinColors.time,
        ArvinColors.reminder,
        ArvinColors.project,
        ArvinColors.category,
        ArvinColors.tag,
      }.length, 5);
      expect(ArvinColors.projectSoft, const Color(0xFFEDE9FE));
      expect(ArvinColors.categorySoft, const Color(0xFFDBEAFE));
      expect(ArvinColors.tagSoft, const Color(0xFFDCFCE7));
    });
  });
}
