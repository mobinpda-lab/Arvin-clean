import 'dart:convert';
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
    expect(workflow, contains(r"arvin-device-smoke-${{ matrix.scenario }}-${{ github.event_name == 'workflow_dispatch' && inputs.target_sha || github.sha }}"));

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

  test('Build and Device Smoke enforce exact-SHA controls per runner job', () async {
    final rubyVersion = await Process.run('ruby', <String>['--version']);
    expect(
      rubyVersion.exitCode,
      0,
      reason: 'Ruby is an explicit CI dependency for YAML contract parsing: ${rubyVersion.stderr}',
    );
    expect(rubyVersion.stdout.toString(), startsWith('ruby 3.3.'));

    Future<Map<String, dynamic>> readWorkflow(String path) async {
      final result = await Process.run('ruby', <String>[
        '-e',
        'require "yaml"; require "json"; data = YAML.load_file(ARGV.fetch(0)); data["on"] = data.delete(true) if data.key?(true); puts JSON.generate(data)',
        path,
      ]);
      expect(result.exitCode, 0, reason: 'YAML/Psych parse failed for $path: ${result.stderr}');
      return jsonDecode(result.stdout as String) as Map<String, dynamic>;
    }

    List<Map<String, dynamic>> stepsOf(Map<String, dynamic> job) =>
        (job['steps'] as List)
            .map((step) => Map<String, dynamic>.from(step as Map))
            .toList();

    int stepIndex(
      List<Map<String, dynamic>> steps,
      bool Function(Map<String, dynamic>) predicate,
    ) =>
        steps.indexWhere(predicate);

    final build = await readWorkflow('.github/workflows/build.yml');
    final device = await readWorkflow('.github/workflows/device-smoke.yml');
    final expectedRef = r"${{ github.event_name == 'workflow_dispatch' && inputs.target_sha || github.sha }}";
    const expectedDispatchGroup = "format('dispatch-{0}', github.run_id)";

    for (final workflow in <Map<String, dynamic>>[build, device]) {
      final triggers = Map<String, dynamic>.from(workflow['on'] as Map);
      final dispatch = Map<String, dynamic>.from(triggers['workflow_dispatch'] as Map);
      final targetInput = Map<String, dynamic>.from(
        (dispatch['inputs'] as Map)['target_sha'] as Map,
      );
      expect(targetInput['required'], isTrue);
      expect(targetInput['type'], 'string');

      final concurrency = Map<String, dynamic>.from(workflow['concurrency'] as Map);
      expect(concurrency['group'], contains(expectedDispatchGroup));
      expect(
        concurrency['group'],
        contains('github.event.pull_request.number || github.ref_name'),
      );
      expect(concurrency['cancel-in-progress'], isTrue);

      final jobs = Map<String, dynamic>.from(workflow['jobs'] as Map);
      final preflight = Map<String, dynamic>.from(jobs['preflight'] as Map);
      final preflightSteps = stepsOf(preflight);
      final validationIndex = stepIndex(
        preflightSteps,
        (step) => step['name'] == 'Validate requested SHA before checkout',
      );
      final preflightCheckoutIndex = stepIndex(
        preflightSteps,
        (step) => step['uses'] == 'actions/checkout@v5',
      );
      final preflightVerifyIndex = stepIndex(
        preflightSteps,
        (step) => step['name'] == 'Verify preflight checkout revision',
      );
      expect(validationIndex, greaterThanOrEqualTo(0));
      expect(validationIndex, lessThan(preflightCheckoutIndex));
      expect(preflightCheckoutIndex, lessThan(preflightVerifyIndex));
      expect(preflightVerifyIndex, preflightCheckoutIndex + 1);
      final validation = preflightSteps[validationIndex];
      expect(validation['env']['TARGET_SHA'], expectedRef);
      expect(validation['run'], contains(r'^[0-9a-fA-F]{40}$'));
      expect(validation['run'], contains('exit 1'));
      expect((preflightSteps[preflightCheckoutIndex]['with'] as Map)['ref'], expectedRef);
      final preflightVerify = preflightSteps[preflightVerifyIndex]['run'] as String;
      expect(preflightVerify, contains('git rev-parse HEAD'));
      expect(preflightVerify, contains(r'test "$actual" = "$TARGET_SHA"'));
      expect(preflightVerify, contains('EXPECTED_CHECKOUT_SHA=$TARGET_SHA'));
      expect(preflightVerify, contains('ACTUAL_CHECKOUT_SHA=$actual'));

      for (final entry in jobs.entries.where((entry) => entry.key != 'preflight')) {
        final job = Map<String, dynamic>.from(entry.value as Map);
        final needs = job['needs'];
        expect(
          needs == 'preflight' || (needs is List && needs.contains('preflight')),
          isTrue,
          reason: '${entry.key} must depend on preflight without losing existing needs',
        );
        final steps = stepsOf(job);
        final checkoutIndex = stepIndex(steps, (step) => step['uses'] == 'actions/checkout@v5');
        final verifyIndex = stepIndex(steps, (step) => step['name'] == 'Verify exact requested revision');
        expect(checkoutIndex, greaterThanOrEqualTo(0), reason: '${entry.key} checkout missing');
        expect(verifyIndex, checkoutIndex + 1, reason: '${entry.key} must verify immediately after checkout');
        expect((steps[checkoutIndex]['with'] as Map)['ref'], expectedRef);
        final verify = steps[verifyIndex];
        expect(verify.containsKey('if'), isFalse, reason: '${entry.key} verification must be unconditional');
        final verifyRun = verify['run'] as String;
        expect(verifyRun, contains('git rev-parse HEAD'));
        expect(verifyRun, contains(r'test "$actual" = "$TARGET_SHA"'));
        expect(verifyRun, contains('EXPECTED_CHECKOUT_SHA=$TARGET_SHA'));
        expect(verifyRun, contains('ACTUAL_CHECKOUT_SHA=$actual'));
        expect(verifyRun, contains(r'EXACT_TARGET_SHA=$actual'));
        expect(verifyRun, contains('EXACT_TARGET_SHA=NOT_APPLICABLE_NON_DISPATCH'));
      }
    }

    final buildJobs = Map<String, dynamic>.from(build['jobs'] as Map);
    final qualityMatrix = Map<String, dynamic>.from((buildJobs['quality'] as Map)['strategy'] as Map);
    final qualityLanes = ((qualityMatrix['matrix'] as Map)['lane'] as List).cast<String>();
    expect(
      qualityLanes,
      <String>['analyze', 'test-0', 'test-1', 'test-2', 'test-3', 'test-4', 'test-5'],
    );
    final apkMatrix = Map<String, dynamic>.from((buildJobs['apk'] as Map)['strategy'] as Map);
    expect(((apkMatrix['matrix'] as Map)['variant'] as List).toSet(), <String>{'release', 'debug'});
    final buildText = File('.github/workflows/build.yml').readAsStringSync();
    expect(buildText, contains('name: Verify repository-owned release inputs'));
    expect(buildText, contains('name: Verify APK'));
    expect(buildText, contains('if-no-files-found: error'));
    expect(buildText, contains('name: Upload APK'));

    final deviceJobs = Map<String, dynamic>.from(device['jobs'] as Map);
    final smokeJob = Map<String, dynamic>.from(deviceJobs['device-smoke'] as Map);
    final smokeMatrix = Map<String, dynamic>.from((smokeJob['strategy'] as Map)['matrix'] as Map);
    final scenarios = (smokeMatrix['include'] as List)
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
    expect(scenarios, hasLength(9));
    final scenarioFiles = <String, String>{
      'home': 'integration_test/android_home_smoke_test.dart',
      'quick-capture': 'integration_test/android_quick_capture_smoke_test.dart',
      'task-lifecycle': 'integration_test/android_task_lifecycle_smoke_test.dart',
      'checklist-evolution': 'integration_test/android_checklist_evolution_smoke_test.dart',
      'sql-persistence': 'integration_test/android_sql_persistence_smoke_test.dart',
      'sql-migration': 'integration_test/android_upgrade_migration_smoke_test.dart',
      'backup-restore': 'integration_test/android_backup_restore_sql_smoke_test.dart',
      'people': 'integration_test/android_people_smoke_test.dart',
      'calendar': 'integration_test/calendar_card_interaction_test.dart',
    };
    expect(scenarios.map((entry) => entry['scenario']).toSet(), scenarioFiles.keys.toSet());
    for (final scenario in scenarios) {
      expect(scenarioFiles[scenario['scenario']], scenario['test_file']);
    }
    final smokeText = File('.github/workflows/device-smoke.yml').readAsStringSync();
    final artifactSteps = stepsOf(smokeJob)
        .where((step) => step['uses'] == 'actions/upload-artifact@v5');
    expect(artifactSteps, isNotEmpty);
    for (final artifact in artifactSteps) {
      final name = ((artifact['with'] as Map)['name'] as String);
      expect(
        name,
        contains(r"${{ github.event_name == 'workflow_dispatch' && inputs.target_sha || github.sha }}"),
        reason: 'Every Device Smoke artifact must identify the tested revision',
      );
    }
    expect(smokeText, contains('script: bash scripts/ci/run-device-smoke.sh'));
    final script = File('scripts/ci/run-device-smoke.sh').readAsStringSync();
    for (final requiredEvidence in <String>[
      'cmd package resolve-activity',
      'am force-stop',
      'pidof',
      'am start -W -n',
      'ARVIN_LIFECYCLE_RESTART_VERIFIED',
      'android_task_lifecycle_restart_verify_test.dart',
      'android_checklist_evolution_restart_verify_test.dart',
    ]) {
      expect(script, contains(requiredEvidence));
    }
  });

}
