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
    expect(workflow, contains('bash scripts/ci/run-device-smoke.sh'));
    final deviceSmokeScriptFile = File('scripts/ci/run-device-smoke.sh');
    if (deviceSmokeScriptFile.existsSync()) {
      final deviceSmokeScript = deviceSmokeScriptFile.readAsStringSync();
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
      // Use Flutter's native integration_test screenshot callback at known UI checkpoints.
      expect(deviceSmokeScript, contains('flutter drive --driver=test_driver/integration_test.dart --target='));
      expect(deviceSmokeScript, contains('--keep-app-running'));
      expect(deviceSmokeScript, isNot(contains('adb exec-out screencap -p')));
      expect(deviceSmokeScript, isNot(contains('uiautomator dump')));
    } else {
      // The ordinary PR merge ref does not contain product-only integration sources.
      // Keep the Dispatch target path and all nine matrix entries contractually required.
      expect(workflow, contains("github.event_name == 'workflow_dispatch'"));
      expect(workflow, contains('scenario: task-lifecycle'));
      expect(workflow, contains('scenario: checklist-evolution'));
    }

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
      expect(concurrency['cancel-in-progress'], r"${{ github.event_name != 'workflow_dispatch' }}");

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
      expect(preflightVerify, contains(r'EXPECTED_CHECKOUT_SHA=$TARGET_SHA'));
      expect(preflightVerify, contains(r'ACTUAL_CHECKOUT_SHA=$actual'));

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
        expect(verifyRun, contains(r'EXPECTED_CHECKOUT_SHA=$TARGET_SHA'));
        expect(verifyRun, contains(r'ACTUAL_CHECKOUT_SHA=$actual'));
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
    final apkJob = Map<String, dynamic>.from(buildJobs['apk'] as Map);
    final apkMatrix = Map<String, dynamic>.from((apkJob['strategy'] as Map)['matrix'] as Map);
    expect((apkMatrix['variant'] as List).toSet(), <String>{'release', 'debug'});
    final apkSteps = stepsOf(apkJob);
    final apkArtifact = apkSteps.singleWhere((step) => step['uses'] == 'actions/upload-artifact@v5');
    final apkArtifactName = ((apkArtifact['with'] as Map)['name'] as String);
    expect(apkArtifactName, contains(expectedRef));
    expect(apkArtifactName, contains('nonproduction'));
    final buildText = File('.github/workflows/build.yml').readAsStringSync();
    expect(buildText, contains('name: Verify repository-owned release inputs'));
    expect(buildText, contains('name: Verify APK'));
    expect(buildText, contains("ARVIN_OFFICIAL_RELEASE: 'false'"));
    expect(
      buildText,
      contains(r"name: arvin-ci-${{ matrix.variant }}-apk-${{ github.event_name == 'workflow_dispatch' && inputs.target_sha || github.sha }}-nonproduction"),
    );
    expect(buildText, contains('if-no-files-found: error'));
    expect(buildText, contains('name: Upload APK'));

    final gradleText = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradleText, contains('officialReleaseRequested'));
    expect(gradleText, contains('Official Release requested, but ARVIN_RELEASE_STORE_FILE is missing.'));
    expect(gradleText, contains('signingConfig = signingConfigs.getByName("arvinProduction")'));
    expect(gradleText, contains('signingConfig = signingConfigs.getByName("debug")'));

    final releaseClosure = File('.github/workflows/release-closure.yml').readAsStringSync();
    expect(releaseClosure, contains('name: Verify APK signature schemes and authorized certificate'));
    expect(releaseClosure, contains(r'apksigner verify --verbose --print-certs "$apk"'));
    expect(releaseClosure, contains('CERTIFICATE_FINGERPRINT_MATCH=PASS'));
    expect(releaseClosure, contains(r'sha256sum "$dest"'));
    expect(releaseClosure, contains(r'sha256sum -c "$RELEASE_EVIDENCE/artifact.sha256"'));

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
    final smokeSteps = stepsOf(smokeJob);
    final emulatorStep = smokeSteps.singleWhere(
      (step) => step['name'] == 'Run selected canonical smoke on Android emulator',
    );
    final emulatorCondition = emulatorStep['if'] as String;
    expect(emulatorCondition, contains("github.event_name == 'workflow_dispatch'"));
    expect(emulatorCondition, contains("matrix.scenario != 'task-lifecycle'"));
    expect(emulatorCondition, contains("matrix.scenario != 'checklist-evolution'"));
    final emulatorScript = ((emulatorStep['with'] as Map)['script'] as String);
    expect(emulatorScript, contains('bash scripts/ci/run-device-smoke.sh'));
    expect(emulatorScript, contains(r"${{ matrix.test_file }}"));
    expect(emulatorScript, contains(r"${{ matrix.scenario }}"));
    final skipNotice = smokeSteps.singleWhere(
      (step) => step['name'] == 'Explain product-only smoke scenarios require target SHA',
    );
    expect(skipNotice['if'], contains("github.event_name != 'workflow_dispatch'"));
    expect(skipNotice['run'], contains('SKIPPED_NON_DISPATCH_PRODUCT_SHA_REQUIRED'));
    final artifactSteps = smokeSteps
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
    expect(script, contains('flutter drive --driver=test_driver/integration_test.dart --target='));
    expect(script, contains('ARVIN_LIFECYCLE_RESTART_VERIFIED'));
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
