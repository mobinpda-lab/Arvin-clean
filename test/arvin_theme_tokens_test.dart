import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/arvin_colors.dart';
import 'package:arvin/core/theme/arvin_theme.dart';

void main() {
  group('Arvin design tokens', () {
    test('matches the owner-approved light card palette and typography', () {
      expect(ArvinTheme.primaryPurple, const Color(0xFF3F3D56));
      expect(ArvinTheme.headerPurple, const Color(0xFF2D2B42));
      expect(ArvinTheme.backgroundLight, const Color(0xFFF7F8FC));
      expect(ArvinTheme.cardBackground, Colors.white);
      expect(ArvinTheme.cardBorderRadius, BorderRadius.circular(16));
      expect(ArvinTheme.shadowStyle.blurRadius, 10);
      expect(ArvinTheme.shadowStyle.offset, const Offset(0, 4));
      expect(ArvinTheme.fontFamily, 'Vazirmatn');
    });

    test('keeps semantic priority and taxonomy colors separate from brand tokens', () {
      expect(ArvinColors.priorityP1, const Color(0xFFDC2626));
      expect(ArvinColors.priorityP2, const Color(0xFF2563EB));
      expect(ArvinColors.priorityP3, const Color(0xFFD97706));
      expect(ArvinColors.priorityP4, const Color(0xFF80829C));
      expect(ArvinColors.project, const Color(0xFF185CC7));
      expect(ArvinColors.category, const Color(0xFFD84D0C));
      expect(ArvinColors.tag, const Color(0xFF7133C6));
    });
  });
}
