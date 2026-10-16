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
    expect(workflow, contains('max-parallel: 2'));
    expect(workflow, contains('timeout-minutes: 30'));

    // Use Flutter's native integration_test screenshot callback at known UI checkpoints.
    expect(workflow, contains('Cache Android NDK 28.2.13676358'));
    expect(workflow, contains('bash .github/scripts/ensure-android-ndk.sh'));
    expect(workflow, contains(r'timeout 120s adb -s "emulator-${EMULATOR_PORT}" wait-for-device'));
    expect(workflow, contains('sys.boot_completed'));
    expect(workflow, contains(r'for attempt in $(seq 1 120)'));
    expect(workflow, contains('script: |\n            set -eu'));
    expect(workflow, isNot(contains('script: |\n            set -euo pipefail')));
    expect(workflow, contains('flutter drive --driver=test_driver/integration_test.dart --target='));
    expect(workflow, isNot(contains('adb exec-out screencap -p')));
    expect(workflow, isNot(contains('uiautomator dump')));

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
    final homeScreenshotIndex = homeTest.indexOf("takeScreenshot('home')");
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
    expect(workflow, contains('actions/upload-artifact@v4'));
    final buildWorkflow = File('.github/workflows/build.yml').readAsStringSync();
    expect(buildWorkflow, contains('Cache Android NDK 28.2.13676358'));
    expect(buildWorkflow, contains('bash .github/scripts/ensure-android-ndk.sh'));
    final ndkSetup = File('.github/scripts/ensure-android-ndk.sh').readAsStringSync();
    expect(ndkSetup, contains('for attempt in 1 2 3'));
    expect(ndkSetup, contains('source.properties'));
    expect(ndkSetup, contains('rm -rf'));
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
