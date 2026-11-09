import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/arvin_colors.dart';
import 'package:arvin/core/theme/arvin_theme.dart';
import 'package:arvin/core/theme/app_theme_manager.dart';

void main() {
  group('Arvin design tokens', () {
    test('matches the owner-approved light card palette and typography', () {
      expect(ArvinTheme.primaryBlue, const Color(0xFF4169A1));
      expect(ArvinTheme.primaryTeal, ArvinTheme.primaryBlue);
      expect(ArvinTheme.primaryBlue, ArvinTheme.primaryTeal);
      expect(ArvinTheme.primaryPurple, ArvinTheme.primaryBlue);
      expect(ArvinTheme.headerBlue, const Color(0xFF355782));
      expect(ArvinTheme.headerTeal, ArvinTheme.headerBlue);
      expect(ArvinTheme.headerBlue, ArvinTheme.headerTeal);
      expect(ArvinTheme.headerPurple, ArvinTheme.headerBlue);
      expect(ArvinTheme.backgroundLight, const Color(0xFFF4F6F9));
      expect(ArvinTheme.iceBlue, const Color(0xFFF0F5FC));
      expect(ArvinTheme.cardBackground, const Color(0xFFFFFFFF));
  expect(ArvinTheme.primaryGlow, const Color(0x404169A1));
  expect(ArvinTheme.shadowStyle.color, const Color(0x404169A1));
  expect(ArvinColors.shadowSoft, const Color(0x404169A1));
  expect(ArvinColors.shadowDark, const Color(0x40008080));
      expect(ArvinTheme.cardBorderRadius, BorderRadius.circular(16));
      expect(ArvinTheme.shadowStyle.blurRadius, 10);
      expect(ArvinTheme.shadowStyle.offset, const Offset(0, 4));
      expect(ArvinTheme.fontFamily, 'Vazirmatn');
      expect(ArvinColors.primary, ArvinTheme.primaryBlue);
      expect(ArvinColors.primaryDark, ArvinTheme.headerBlue);
      expect(ArvinColors.primarySoft, const Color(0xFFE5EDF8));
    });

    test('retains the nine-color palette as secondary accents, separate from brand identity', () {
      expect(AppThemeManager.palette, hasLength(9));
      expect(AppThemeManager.isSupported('#008080'), isTrue);
      expect(AppThemeManager.instance.selectedAccentColor, const Color(0xFF008080));
      expect(AppThemeManager.instance.selectedAccentColor, isNot(ArvinColors.primary));
    });

    test('keeps semantic priority and taxonomy colors separate from brand tokens', () {
      expect(ArvinColors.priorityP1, const Color(0xFFDC2626));
      expect(ArvinColors.priorityP2, const Color(0xFFD97706));
      expect(ArvinColors.priorityP3, const Color(0xFF2563EB));
      expect(ArvinColors.priorityP4, const Color(0xFF80829C));
      expect(ArvinColors.time, const Color(0xFF008080));
      expect(ArvinColors.primary, const Color(0xFF4169A1));
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
