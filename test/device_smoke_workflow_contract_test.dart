import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('device smoke stays Ready-only and runs real Android integration flows', () {
    final workflow =
        File('.github/workflows/device-smoke.yml').readAsStringSync();

    expect(workflow, contains('name: Arvin Device Smoke'));
    expect(
      workflow,
      contains("if: github.event_name != 'pull_request' || github.event.pull_request.draft == false"),
    );

    expect(workflow, contains('reactivecircus/android-emulator-runner@v2'));
    expect(workflow, contains('max-parallel: 7'));
    expect(workflow, contains('timeout-minutes: 30'));
    expect(
      workflow,
      contains('emulator-options: -no-window -gpu off -no-snapshot -noaudio -no-boot-anim -camera-back none -camera-front none'),
    );

    final matrixScenarios = RegExp(
      r'\s+- scenario: ([^\n]+)\n\s+test_file: ([^\n]+)',
    ).allMatches(workflow).toList();

    expect(
      matrixScenarios.length,
      7,
      reason:
          'Home, Quick Capture, SQL persistence, Upgrade Migration, Backup/Restore, People, and Calendar must run as separate matrix smoke scenarios',
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
        'integration_test/android_calendar_provider_acceptance_test.dart',
      ]),
    );
  });
}
