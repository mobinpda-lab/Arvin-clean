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

    // Use Flutter's native integration_test screenshot callback at known UI checkpoints.
    expect(workflow, contains('script: flutter drive --driver=test_driver/integration_test.dart --target='));
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
    expect(homeTest, contains("expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);\\n    await binding.convertFlutterSurfaceToImage();"));
    expect(quickCaptureTest, contains("takeScreenshot('quick-capture')"));
    expect(peopleTest, contains("takeScreenshot('people')"));
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
