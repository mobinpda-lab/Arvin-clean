import 'package:flutter/material.dart';

/// Canonical Arvin semantic color tokens.
///
/// Every product concept has one stable semantic family across Home, Quick
/// Entry, Task Detail, editors, filters and management surfaces.
abstract final class ArvinColors {
  static const primary = Color(0xFF4A4CAB);
  static const primaryDark = Color(0xFF373982);
  static const primarySoft = Color(0xFFE9EAFF);

  static const background = Color(0xFFF8F8FB);
  static const surface = Color(0xFFFDFDFE);
  static const textPrimary = Color(0xFF232433);
  static const textSecondary = Color(0xFF666982);
  static const border = Color(0xFFE2E4EE);

  static const time = Color(0xFFE85D2A);
  static const timeDark = Color(0xFFB9421B);
  static const timeSoft = Color(0xFFFFF0E8);

  static const reminder = Color(0xFFD58A24);
  static const reminderDark = Color(0xFF7A4B00);
  static const reminderSoft = Color(0xFFFFF3DE);

  static const project = Color(0xFF3568D4);
  static const projectDark = Color(0xFF244DA8);
  static const projectSoft = Color(0xFFE8F0FF);

  static const category = Color(0xFF7650C8);
  static const categoryDark = Color(0xFF56369D);
  static const categorySoft = Color(0xFFF0EAFF);

  static const tag = Color(0xFF159A9C);
  static const tagDark = Color(0xFF087376);
  static const tagSoft = Color(0xFFE5F8F7);

  static const error = Color(0xFFD14B53);
  static const errorDark = Color(0xFFA8323A);
  static const errorSoft = Color(0xFFFCE9EB);

  static const neutral = Color(0xFF7D8298);
  static const neutralDark = Color(0xFF626679);
  static const neutralSoft = Color(0xFFF0F1F5);

  static const disabledText = Color(0xFF85889A);
  static const disabledBorder = Color(0xFFD9DBE5);
}
