import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('device smoke covers integration-base and Draft PRs with real Android flows', () {
    final workflow =
        File('.github/workflows/device-smoke.yml').readAsStringSync();

    expect(workflow, contains('name: Arvin Device Smoke'));
    expect(workflow, contains('workflow_dispatch:'));
    expect(workflow, contains('target_sha:'));
    expect(workflow, contains('run_calendar:'));
    expect(workflow, contains('run_sql_persistence:'));
    expect(workflow, contains('run_sql_migration:'));
    expect(workflow, contains(r'RUN_SQL_MIGRATION: ${{ inputs.run_sql_migration }}'));
    expect(workflow, contains('"scenario":"sql-migration","test_file":"integration_test/android_upgrade_migration_smoke_test.dart"'));
    expect(
      workflow,
      contains(r"ref: ${{ github.event.pull_request.head.sha || inputs.target_sha || github.sha }}"),
    );
    expect(workflow, contains('name: Record and verify checkout revision'));
    expect(workflow, contains(r'actual="$(git rev-parse HEAD)"'));
    expect(workflow, contains(r'echo "CHECKOUT_SHA=$actual"'));
    expect(workflow, contains(r'echo "EXACT_TARGET_SHA=$actual"'));
    expect(
      workflow,
      contains(r'CHECKOUT SHA mismatch: expected $TARGET_SHA, got $actual'),
    );
    expect(workflow, contains(r'if [ "$actual" != "$TARGET_SHA" ]; then'));

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

    // The workflow builds a JSON matrix in prepare-matrix and exposes it
    // through the job output. Validate that contract instead of expecting a
    // literal YAML list under strategy.matrix.
    expect(
      workflow,
      contains(r'matrix: ${{ fromJSON(needs.prepare-matrix.outputs.matrix) }}'),
    );
    expect(
      workflow,
      contains(r'matrix: ${{ steps.set-matrix.outputs.matrix }}'),
    );
    expect(workflow, contains(r"'{include:$scenarios}'"));
    expect(workflow, contains(r'echo "matrix=$matrix" >> "$GITHUB_OUTPUT"'));

    final matrixScenarios = RegExp(
      r'\{"scenario":"([^"]+)","test_file":"([^"]+)"\}',
    ).allMatches(workflow).toList();

    final scenarioMappings = matrixScenarios
        .map((match) => '${match.group(1)}:${match.group(2)}')
        .toSet();

    expect(
      scenarioMappings,
      equals(<String>{
        'home:integration_test/android_home_smoke_test.dart',
        'quick-capture:integration_test/android_quick_capture_smoke_test.dart',
        'sql-persistence:integration_test/android_sql_persistence_smoke_test.dart',
        'sql-migration:integration_test/android_upgrade_migration_smoke_test.dart',
        'backup-restore:integration_test/android_backup_restore_sql_smoke_test.dart',
        'people:integration_test/android_people_smoke_test.dart',
        'calendar:integration_test/calendar_card_interaction_test.dart',
      }),
      reason:
          'All seven canonical smoke scenarios must map to their corresponding integration test files',
    );
  });
}
