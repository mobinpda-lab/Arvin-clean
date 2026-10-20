import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('device smoke covers integration-base and Draft PRs with real Android flows', () {
    final workflow =
        File('.github/workflows/device-smoke.yml').readAsStringSync();

    expect(workflow, contains('name: Arvin Device Smoke'));

    // Pull requests targeting integration branches must receive smoke coverage.
    // Keep the main/master restriction for push events, but not for pull_request.
    final pullRequestTrigger = workflow
        .split('  pull_request:\n')
        .last
        .split('  workflow_dispatch:')
        .first;
    expect(pullRequestTrigger, isNot(contains('branches: [main, master]')));
    expect(
      workflow,
      isNot(contains("if: github.event_name != 'pull_request' || github.event.pull_request.draft == false")),
    );

    expect(workflow, contains('reactivecircus/android-emulator-runner@v2'));
    // Keep the emulator runner script in one process: its input is executed
    // line-by-line by separate shells, so multiline conditionals cannot span lines.
    expect(workflow, contains("script: bash scripts/ci/run-device-smoke.sh"));
    final deviceSmokeScript =
        File('scripts/ci/run-device-smoke.sh').readAsStringSync();
    // Restart must discover the installed launcher and prove process replacement.
    expect(deviceSmokeScript, contains('cmd package resolve-activity'));
    expect(deviceSmokeScript, contains('am force-stop'));
    expect(deviceSmokeScript, contains('pidof'));
    expect(deviceSmokeScript, contains('am start -W -n'));
    expect(deviceSmokeScript, contains('ARVIN_LIFECYCLE_RESTART_VERIFIED'));
    expect(
      deviceSmokeScript,
      contains('integration_test/android_task_lifecycle_restart_verify_test.dart'),
    );
    expect(deviceSmokeScript, isNot(contains('am start -n com.example.arvin/.MainActivity')));
    expect(workflow, contains('max-parallel: 2'));
    expect(workflow, contains('timeout-minutes: 30'));

    // Use Flutter's native integration_test screenshot callback at known UI checkpoints.
    expect(deviceSmokeScript, contains('flutter drive --driver=test_driver/integration_test.dart --target='));
    expect(deviceSmokeScript, contains('--keep-app-running'));
    expect(deviceSmokeScript, isNot(contains('adb exec-out screencap -p')));
    expect(deviceSmokeScript, isNot(contains('uiautomator dump')));

    final driver = File('test_driver/integration_test.dart').readAsStringSync();
    expect(driver, contains('integrationDriver('));
    expect(driver, contains('onScreenshot:'));
    expect(driver, contains(r'artifacts/device-smoke/$screenshotName.png'));
    expect(driver, contains('writeAsBytes(screenshotBytes'));

    final homeTest = File('integration_test/android_home_smoke_test.dart').readAsStringSync();
    final quickCaptureTest = File('integration_test/android_quick_capture_smoke_test.dart').readAsStringSync();
    final peopleTest = File('integration_test/android_people_smoke_test.dart').readAsStringSync();
    expect(homeTest, contains("takeScreenshot('home')"));
    final homeRouteAssertionIndex = homeTest.indexOf(
      "expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);",
      homeTest.indexOf('expect(created.single.description'),
    );
    final homeScreenshotIndex =
        homeTest.indexOf('await binding.convertFlutterSurfaceToImage();');
    expect(homeRouteAssertionIndex, greaterThanOrEqualTo(0));
    expect(homeRouteAssertionIndex, lessThan(homeScreenshotIndex));
    expect(homeTest, contains('quickCaptureCancel'));
    expect(quickCaptureTest, contains("takeScreenshot('quick-capture')"));
    expect(peopleTest, contains("takeScreenshot('people')"));
    expect(workflow, contains('Upload Android smoke screenshot evidence'));
    expect(
      workflow,
      contains("if: always() && (matrix.scenario == 'home' || matrix.scenario == 'quick-capture' || matrix.scenario == 'people')"),
    );
    expect(workflow, contains('actions/upload-artifact@v5'));
    expect(workflow, contains(r'arvin-device-smoke-${{ matrix.scenario }}-${{ github.sha }}'));

    final matrixScenarios = RegExp(
      r'\s+- scenario: ([^\n]+)\n\s+test_file: ([^\n]+)',
    ).allMatches(workflow).toList();

    final scenarioNames =
        matrixScenarios.map((match) => match.group(1)!).toSet();
    final testFiles =
        matrixScenarios.map((match) => match.group(2)!).toSet();

    // Assert both the current lane count and the complete inventory so an
    // accidental duplicate cannot hide a missing product scenario.
    expect(matrixScenarios, hasLength(9));
    expect(
      scenarioNames,
      containsAll(<String>[
        'home',
        'quick-capture',
        'task-lifecycle',
        'checklist-evolution',
        'sql-persistence',
        'sql-migration',
        'backup-restore',
        'people',
        'calendar',
      ]),
    );
    expect(
      testFiles,
      containsAll(<String>[
        'integration_test/android_home_smoke_test.dart',
        'integration_test/android_quick_capture_smoke_test.dart',
        'integration_test/android_task_lifecycle_smoke_test.dart',
        'integration_test/android_checklist_evolution_smoke_test.dart',
        'integration_test/android_sql_persistence_smoke_test.dart',
        'integration_test/android_upgrade_migration_smoke_test.dart',
        'integration_test/android_backup_restore_sql_smoke_test.dart',
        'integration_test/android_people_smoke_test.dart',
        'integration_test/calendar_card_interaction_test.dart',
      ]),
    );
  });
}
