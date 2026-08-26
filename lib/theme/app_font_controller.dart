import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'font_catalog.dart';

class AppFontController extends ValueNotifier<String> {
  AppFontController._() : super(AppFontCatalog.defaultId);

  static const String _preferenceKey = 'app_font_id';
  static final AppFontController instance = AppFontController._();

  String get family => AppFontCatalog.byId(value).family;
  AppFontOption get selectedOption => AppFontCatalog.byId(value);

  Future<void> initialize() async {
    await AppFontCatalog.loadSelectableFonts();
    final preferences = await SharedPreferences.getInstance();
    final savedId = preferences.getString(_preferenceKey);
    if (savedId != null && AppFontCatalog.isAvailable(savedId)) {
      value = savedId;
    } else {
      value = AppFontCatalog.defaultId;
    }
  }

  Future<void> select(String id) async {
    if (!AppFontCatalog.isAvailable(id)) return;
    if (value != id) value = id;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, id);
  }

  Future<void> resetToDefault() => select(AppFontCatalog.defaultId);
}
