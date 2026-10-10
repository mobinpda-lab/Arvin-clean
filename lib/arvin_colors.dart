import 'package:flutter/material.dart';

/// Canonical semantic palette used across Arvin. Owner-approved brand, surface,
/// and text tokens stay aligned with the Home visual style lock.
abstract final class ArvinColors {
  static const primary = Color(0xFF4A4CAB);
  static const primaryDark = Color(0xFF25286F);
  static const primarySoft = Color(0xFFE9EAFF);

  static const background = Color(0xFFF8F8FB);
  static const surface = Color(0xFFFDFDFE);
  static const textPrimary = Color(0xFF232433);
  static const textSecondary = Color(0xFF80829C);
  static const border = Color(0xFFE5E7ED);

  static const time = Color(0xFF008C74);
  static const timeDark = Color(0xFF006653);
  static const timeSoft = Color(0xFFD8F5EC);

  static const reminder = Color(0xFFB96A00);
  static const reminderDark = Color(0xFF794400);
  static const reminderSoft = Color(0xFFFFE9C2);

  static const project = Color(0xFF185CC7);
  static const projectDark = Color(0xFF154596);
  static const projectSoft = Color(0xFFDDEAFF);

  static const category = Color(0xFFD84D0C);
  static const categoryDark = Color(0xFF9E3505);
  static const categorySoft = Color(0xFFFFE5D8);

  static const tag = Color(0xFF7133C6);
  static const tagDark = Color(0xFF542296);
  static const tagSoft = Color(0xFFEBDDFF);

  static const error = Color(0xFFC62828);
  static const errorDark = Color(0xFF922020);
  static const errorSoft = Color(0xFFFFE0E2);

  static const neutral = Color(0xFF454D63);
  static const neutralDark = Color(0xFF30374B);
  static const neutralSoft = Color(0xFFE7EAF1);

  static const disabledText = Color(0xFF62697C);
  static const disabledBorder = Color(0xFFB9BECD);
}
