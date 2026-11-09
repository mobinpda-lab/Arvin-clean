import 'package:flutter/material.dart';

import 'core/theme/arvin_theme.dart';
import 'models/task.dart';

/// Canonical semantic palette used across Arvin. Owner-approved brand, surface,
/// and text tokens stay aligned with the Home visual style lock.
abstract final class ArvinColors {
  static const primary = ArvinTheme.primaryBlue;
  static const primaryDark = ArvinTheme.headerBlue;
  static const primarySoft = ArvinTheme.primarySoft;

  static const background = ArvinTheme.backgroundLight;
  static const surface = ArvinTheme.cardBackground;
  static const textPrimary = Color(0xFF232433);
  static const textSecondary = Color(0xFF80829C);
  static const border = ArvinTheme.cardBorder;
  static const shadowSoft = ArvinTheme.primaryGlow;
  static const shadowDark = Color(0x403A86EF);

  // Dark theme semantic tokens.
  static const darkPrimary = Color(0xFF3A86EF);
  static const darkOnPrimary = Color(0xFFFFFFFF);
  static const darkSecondary = Color(0xFFA9CCFF);
  static const darkError = Color(0xFFFFB4AB);
  static const darkSurface = Color(0xFF25283A);
  static const darkBorder = Color(0xFF41465B);
  static const darkDivider = Color(0xFF555B70);
  static const darkOutline = Color(0xFF656B80);

  // Brand and grouping accents use the approved blue system.
  static const groupingTomorrow = Color(0xFF3A86EF);
  static const groupingFuture = Color(0xFF3A86EF);
  static const groupingTodaySoft = Color(0xFFEAF2FF);
  static const groupingTomorrowSoft = Color(0xFFEAF2FF);
  static const groupingFutureSoft = Color(0xFFEAF2FF);
  static const groupingNoDateSoft = Color(0xFFF8F8FB);
  static const taskStatusGreen = Color(0xFF409B51);
  static const taskStatusAmber = Color(0xFFDB8B23);

  static const time = ArvinTheme.primaryBlue;
  static const timeDark = ArvinTheme.headerBlue;
  static const timeSoft = ArvinTheme.primarySoft;

  static const reminder = ArvinTheme.primaryBlue;
  static const reminderDark = ArvinTheme.headerBlue;
  static const reminderSoft = ArvinTheme.primarySoft;

  static const project = ArvinTheme.primaryBlue;
  static const projectDark = ArvinTheme.headerBlue;
  static const projectSoft = ArvinTheme.primarySoft;

  static const category = ArvinTheme.primaryBlue;
  static const categoryDark = ArvinTheme.headerBlue;
  static const categorySoft = ArvinTheme.primarySoft;

  static const tag = ArvinTheme.primaryBlue;
  static const tagDark = ArvinTheme.headerBlue;
  static const tagSoft = ArvinTheme.primarySoft;

  static const error = Color(0xFFC62828);
  static const errorDark = Color(0xFF922020);
  static const errorSoft = Color(0xFFFFE0E2);

  static const neutral = Color(0xFF454D63);
  static const neutralDark = Color(0xFF30374B);
  static const neutralSoft = Color(0xFFE7EAF1);

  static const disabledText = Color(0xFF62697C);
  static const disabledBorder = Color(0xFFB9BECD);

  // Calendar status tokens follow the approved pastel reference.
  static const calendarCompleted = Color(0xFF059669);
  static const calendarCompletedSoft = Color(0xFFECFDF5);
  static const calendarWaiting = Color(0xFFCA8A04);
  static const calendarWaitingSoft = Color(0xFFFEFCE8);
  static const calendarPlanned = Color(0xFF2563EB);
  static const calendarPlannedSoft = Color(0xFFEFF6FF);
  static const calendarOverdue = Color(0xFFDC2626);
  static const calendarOverdueSoft = Color(0xFFFEF2F2);
  static const calendarSelectedDay = ArvinTheme.primarySoft;
  static const priorityP1 = Color(0xFFDC2626);
  static const priorityP2 = Color(0xFFD97706);
  static const priorityP3 = Color(0xFF2563EB);
  static const priorityP4 = Color(0xFF80829C);

  static Color priorityColor(TaskPriority priority) => switch (priority) {
        TaskPriority.high => priorityP1,
        TaskPriority.medium => priorityP2,
        TaskPriority.low => priorityP3,
        TaskPriority.none => priorityP4,
      };
}
