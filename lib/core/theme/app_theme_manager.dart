import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArvinThemePaletteColor {
  const ArvinThemePaletteColor({
    required this.number,
    required this.name,
    required this.hex,
  });

  final int number;
  final String name;
  final String hex;

  Color get color => AppThemeManager.colorFromHex(hex);
}

/// Owns the user's primary accent selection and persists it independently of
/// the broader application settings model.
class AppThemeManager extends ChangeNotifier {
  AppThemeManager._();

  static final AppThemeManager instance = AppThemeManager._();
  static const String preferenceKey = 'arvin.settings.primaryColor';
  static const String defaultHex = '#3A86EF';

  static const List<ArvinThemePaletteColor> palette = [
    ArvinThemePaletteColor(number: 1, name: 'فیروزه‌ای آروین', hex: '#078B91'),
    ArvinThemePaletteColor(number: 2, name: 'آبی اقیانوسی', hex: '#1B4965'),
    ArvinThemePaletteColor(number: 3, name: 'سبز مدرن', hex: '#2A9D8F'),
    ArvinThemePaletteColor(number: 4, name: 'آبی سلطنتی', hex: '#4361EE'),
    ArvinThemePaletteColor(number: 5, name: 'بنفش شاهانه', hex: '#7209B7'),
    ArvinThemePaletteColor(number: 6, name: 'نارنجی کهربایی', hex: '#F77F00'),
    ArvinThemePaletteColor(number: 7, name: 'قرمز کارمین', hex: '#D90429'),
    ArvinThemePaletteColor(number: 8, name: 'آبی آسمانی پرانرژی', hex: '#3A86EF'),
    ArvinThemePaletteColor(number: 9, name: 'ذغالی شیک مدرن', hex: '#2B2D42'),
  ];

  String _selectedHex = defaultHex;
  String get selectedHex => _selectedHex;
  Color get selectedColor => colorFromHex(_selectedHex);

  static Color colorFromHex(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  static bool isSupported(String hex) =>
      palette.any((entry) => entry.hex.toUpperCase() == hex.toUpperCase());

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(preferenceKey);
    final next = stored != null && isSupported(stored) ? stored.toUpperCase() : defaultHex;
    if (_selectedHex == next) return;
    _selectedHex = next;
    notifyListeners();
  }

  Future<void> select(String hex) async {
    final match = palette.where((entry) => entry.hex.toUpperCase() == hex.toUpperCase());
    if (match.isEmpty) {
      throw ArgumentError.value(hex, 'hex', 'Unsupported Arvin theme color');
    }
    final next = match.first.hex;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(preferenceKey, next);
    if (_selectedHex == next) return;
    _selectedHex = next;
    notifyListeners();
  }
}
