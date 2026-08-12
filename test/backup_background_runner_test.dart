import 'package:arvin/backup_background_runner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists background backup configuration', () async {
    await BackupBackgroundRunner.saveConfiguration(
      directoryUri: 'content://arvin/backups',
      payload: <String, dynamic>{
        'tasks': <Map<String, dynamic>>[
          {'title': 'Task 1'},
        ],
      },
    );

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(BackupBackgroundRunner.directoryUriKey),
      'content://arvin/backups',
    );
    expect(
      prefs.getString(BackupBackgroundRunner.payloadKey),
      contains('Task 1'),
    );
  });

  test('returns false when background configuration is missing', () async {
    expect(await const BackupBackgroundRunner().run(), isFalse);
  });

  test('clears background backup configuration', () async {
    await BackupBackgroundRunner.saveConfiguration(
      directoryUri: 'content://arvin/backups',
      payload: <String, dynamic>{'tasks': <dynamic>[]},
    );
    await BackupBackgroundRunner.clearConfiguration();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(BackupBackgroundRunner.directoryUriKey), isFalse);
    expect(prefs.containsKey(BackupBackgroundRunner.payloadKey), isFalse);
  });
}
