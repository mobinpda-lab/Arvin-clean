import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/arvin_colors.dart';
import 'package:arvin/core/theme/arvin_theme.dart';

void main() {
  group('Arvin design tokens', () {
    test('matches the owner-approved light card palette and typography', () {
      expect(ArvinTheme.primaryBlue, const Color(0xFF3A86EF));
      expect(ArvinTheme.primaryPurple, ArvinTheme.primaryBlue);
      expect(ArvinTheme.headerBlue, const Color(0xFF276FC9));
      expect(ArvinTheme.headerPurple, ArvinTheme.headerBlue);
      expect(ArvinTheme.backgroundLight, const Color(0xFFF8F8FB));
      expect(ArvinTheme.cardBackground, const Color(0xFFFDFDFE));
      expect(ArvinTheme.cardBorderRadius, BorderRadius.circular(16));
      expect(ArvinTheme.shadowStyle.blurRadius, 10);
      expect(ArvinTheme.shadowStyle.offset, const Offset(0, 4));
      expect(ArvinTheme.fontFamily, 'Vazirmatn');
      expect(ArvinColors.primary, ArvinTheme.primaryBlue);
      expect(ArvinColors.primaryDark, ArvinTheme.headerBlue);
      expect(ArvinColors.primarySoft, const Color(0xFFEAF2FF));
    });

    test('keeps semantic priority and taxonomy colors separate from brand tokens', () {
      expect(ArvinColors.priorityP1, const Color(0xFFDC2626));
      expect(ArvinColors.priorityP2, const Color(0xFFD97706));
      expect(ArvinColors.priorityP3, const Color(0xFF2563EB));
      expect(ArvinColors.priorityP4, const Color(0xFF80829C));
      expect(ArvinColors.time, ArvinTheme.primaryBlue);
      expect(ArvinColors.reminder, ArvinTheme.primaryBlue);
      expect(ArvinColors.project, ArvinTheme.primaryBlue);
      expect(ArvinColors.category, ArvinTheme.primaryBlue);
      expect(ArvinColors.tag, ArvinTheme.primaryBlue);
      expect(ArvinColors.projectSoft, ArvinTheme.primarySoft);
      expect(ArvinColors.categorySoft, ArvinTheme.primarySoft);
      expect(ArvinColors.tagSoft, ArvinTheme.primarySoft);
    });
  });
}
