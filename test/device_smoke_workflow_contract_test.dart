import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('device smoke stays Ready-only and runs real Android integration flows', () {
    final workflow =
        File('.github/workflows/device-smoke.yml').readAsStringSync();

    expect(workflow, contains('name: Arvin Device Smoke'));
    expect(workflow, contains("github.event.pull_request.draft == false"));
    expect(workflow, contains('reactivecircus/android-emulator-runner@v2'));
    expect(workflow, contains('max-parallel: 4'));
    expect(workflow, contains('timeout-minutes: 30'));

    final matrixScenarios = RegExp(
      r'\s+- scenario: ([^\n]+)\n\s+test_file: ([^\n]+)',
    ).allMatches(workflow).toList();

    expect(
      matrixScenarios.length,
      6,
      reason:
          'Home, Quick Capture, SQL persistence, Upgrade Migration, Backup/Restore, and People must run as separate matrix smoke scenarios',
    );

    final testFiles =
        matrixScenarios.map((match) => match.group(2)!).toSet();

    expect(
      testFiles,
      containsAll(<String>[
        'integration_test/android_home_smoke_test.dart',
        'integration_test/android_quick_capture_smoke_test.dart',
        'integration_test/android_sql_persistence_smoke_test.dart',
        'integration_test/android_upgrade_migration_smoke_test.dart',
        'integration_test/android_backup_restore_sql_smoke_test.dart',
        'integration_test/android_people_smoke_test.dart',
      ]),
    );
  });
}
