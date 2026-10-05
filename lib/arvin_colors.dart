import 'package:flutter/material.dart';

/// Canonical Arvin semantic color tokens.
///
/// Every product concept has one stable semantic family across Home, Quick
/// Entry, Task Detail, editors, filters and management surfaces.
abstract final class ArvinColors {
  static const primary = Color(0xFF4A4CAB);
  static const primaryDark = Color(0xFF373982);
  static const primarySoft = Color(0xFFE9EAFF);

  static const background = Color(0xFFF7F7FC);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1F2740);
  static const textSecondary = Color(0xFF737A91);
  static const border = Color(0xFFE5E7EF);

  static const time = Color(0xFF16B89A);
  static const timeDark = Color(0xFF087C69);
  static const timeSoft = Color(0xFFE9F9F5);

  static const reminder = Color(0xFFD58A24);
  static const reminderDark = Color(0xFF7A4B00);
  static const reminderSoft = Color(0xFFFFF3DE);

  static const project = Color(0xFF3478E5);
  static const projectDark = Color(0xFF2557B5);
  static const projectSoft = Color(0xFFEEF4FF);

  static const category = Color(0xFFF27638);
  static const categoryDark = Color(0xFFB84E19);
  static const categorySoft = Color(0xFFFFF2EA);

  static const tag = Color(0xFF8B4DE8);
  static const tagDark = Color(0xFF6530B8);
  static const tagSoft = Color(0xFFF5EEFF);

  static const error = Color(0xFFE53935);
  static const errorDark = Color(0xFFA8323A);
  static const errorSoft = Color(0xFFFFF0F1);

  static const neutral = Color(0xFF596174);
  static const neutralDark = Color(0xFF626679);
  static const neutralSoft = Color(0xFFF3F4F7);

  static const disabledText = Color(0xFF85889A);
  static const disabledBorder = Color(0xFFD9DBE5);
}
