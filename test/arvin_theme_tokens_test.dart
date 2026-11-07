import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/arvin_colors.dart';
import 'package:arvin/core/theme/arvin_theme.dart';

void main() {
  group('Arvin design tokens', () {
    test('matches the owner-approved light card palette and typography', () {
      expect(ArvinTheme.primaryTurquoise, const Color(0xFF078B91));
      expect(ArvinTheme.primaryPurple, ArvinTheme.primaryTurquoise);
      expect(ArvinTheme.headerTurquoise, const Color(0xFF066F75));
      expect(ArvinTheme.headerPurple, ArvinTheme.headerTurquoise);
      expect(ArvinTheme.backgroundLight, const Color(0xFFF0FAF9));
      expect(ArvinTheme.cardBackground, Colors.white);
      expect(ArvinTheme.cardBorderRadius, BorderRadius.circular(16));
      expect(ArvinTheme.shadowStyle.blurRadius, 10);
      expect(ArvinTheme.shadowStyle.offset, const Offset(0, 4));
      expect(ArvinTheme.fontFamily, 'Vazirmatn');
      expect(ArvinColors.primary, ArvinTheme.primaryTurquoise);
      expect(ArvinColors.primaryDark, ArvinTheme.headerTurquoise);
      expect(ArvinColors.primarySoft, const Color(0xFFDDF7F5));
    });

    test('keeps semantic priority and taxonomy colors separate from brand tokens', () {
      expect(ArvinColors.priorityP1, const Color(0xFFDC2626));
      expect(ArvinColors.priorityP2, const Color(0xFF2563EB));
      expect(ArvinColors.priorityP3, const Color(0xFFD97706));
      expect(ArvinColors.priorityP4, const Color(0xFF80829C));
      expect(ArvinColors.time, ArvinTheme.primaryTurquoise);
      expect(ArvinColors.reminder, ArvinTheme.primaryTurquoise);
      expect(ArvinColors.project, ArvinTheme.primaryTurquoise);
      expect(ArvinColors.category, ArvinTheme.primaryTurquoise);
      expect(ArvinColors.tag, ArvinTheme.primaryTurquoise);
      expect(ArvinColors.projectSoft, ArvinTheme.primarySoft);
      expect(ArvinColors.categorySoft, ArvinTheme.primarySoft);
      expect(ArvinColors.tagSoft, ArvinTheme.primarySoft);
    });
  });
}
