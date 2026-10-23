import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home backup and restore use the canonical portable Settings path', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('backupManager.backupCanonicalTasks('));
    expect(source, contains('_portableBackupSettings()'));
    expect(source, contains('backupManager.restoreCanonicalBackup('));
    expect(source, contains('requestPassphrase: () async'));
    expect(source, contains('appSettingsService.restorePortableJson(mergedSettings)'));
    expect(source, contains('widget.onSettingsChanged?.call(appliedSettings)'));
  });
}
