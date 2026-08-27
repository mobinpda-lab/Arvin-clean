import 'dart:convert';

import 'package:arvin/backup_service.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('portable settings expose only the approved non-secret fields', () {
    final service = AppSettingsService();
    const settings = AppSettings(
      themeMode: ThemeMode.dark,
      usePersianDate: true,
      fontFamily: 'Vazirmatn',
    );

    final portable = service.toPortableJson(settings);

    expect(
      portable.keys.toSet(),
      {'themeMode', 'usePersianDate', 'fontFamily'},
    );
    expect(
      portable.keys.any((key) => key.toLowerCase().contains('token')),
      isFalse,
    );
    expect(
      portable.keys.any((key) => key.toLowerCase().contains('secret')),
      isFalse,
    );
  });

  test('canonical backup built from portable settings does not serialize credentials', () {
    final settingsService = AppSettingsService();
    const settings = AppSettings(
      themeMode: ThemeMode.system,
      usePersianDate: false,
      fontFamily: null,
    );

    final bytes = ArvinBackupService.encodeBackupDocument({
      'tasks': const <Map<String, dynamic>>[],
      'settings': settingsService.toPortableJson(settings),
    });
    final text = utf8.decode(bytes);
    final document = jsonDecode(text) as Map<String, dynamic>;

    expect(document['settings'], {
      'themeMode': 'system',
      'usePersianDate': false,
    });
    expect(text.toLowerCase(), isNot(contains('accesstoken')));
    expect(text.toLowerCase(), isNot(contains('access_token')));
    expect(text.toLowerCase(), isNot(contains('dropbox')));
    expect(text.toLowerCase(), isNot(contains('secret')));
  });
}
