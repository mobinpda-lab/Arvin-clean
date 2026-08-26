import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home backup and restore use the canonical portable Settings path', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('backupManager.backupCanonicalTasks('));
    expect(source, contains('settings: appSettingsService.toPortableJson(settings)'));
    expect(source, contains('backupManager.restoreCanonicalBackup()'));
    expect(source, contains('appSettingsService.decodePortableJson(candidate.settings!)'));
    expect(source, contains('appSettingsService.saveSettings(restoredSettings)'));
    expect(source, contains('widget.onSettingsChanged?.call(restoredSettings)'));
  });
}
