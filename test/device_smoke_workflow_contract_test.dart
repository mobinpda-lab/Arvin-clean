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
    expect(workflow, contains('max-parallel: 2'));
    expect(workflow, contains('timeout-minutes: 30'));

    // The emulator action runs each script line in a separate shell, so all
    // stateful capture/wait logic must live inside one bash command.
    expect(workflow, contains("script: |\n            bash -euo pipefail -c '"));
    expect(workflow, isNot(contains('script: |\n            set -eu\n')));

    // Capture evidence only while the real app is foregrounded; never use
    // the launcher shown after the integration test exits as UI evidence.
    expect(
      workflow,
      contains(r'flutter test ${{ matrix.test_file }} -d emulator-${EMULATOR_PORT} &'),
    );
    expect(workflow, contains(r'test_pid=$!'));
    expect(workflow, contains(r'while kill -0 "$test_pid"'));
    expect(workflow, contains('dumpsys activity activities'));
    expect(workflow, contains('topResumedActivity'));
    expect(workflow, contains('com.example.arvin'));
    expect(workflow, contains('PNG image data'));
    expect(workflow, contains(r'stat -c %s "$temp_path"'));
    expect(workflow, contains('-ge 12000'));
    expect(workflow, contains('sleep 1; done) & capture_pid=$!; if wait "$test_pid"'));
    expect(workflow, contains('wait "$capture_pid" 2>/dev/null || true; if adb shell dumpsys activity activities'));
    expect(workflow, contains(r'exit "$test_exit"'));
    expect(workflow, contains('adb exec-out screencap -p'));
    expect(workflow, contains('Upload Android smoke screenshot evidence'));
    expect(
      workflow,
      contains("if: always() && (matrix.scenario == 'home' || matrix.scenario == 'quick-capture' || matrix.scenario == 'people')"),
    );
    expect(workflow, contains('actions/upload-artifact@v4'));
    expect(workflow, contains(r'arvin-device-smoke-${{ matrix.scenario }}-${{ github.sha }}'));

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
