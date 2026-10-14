import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Build and Device validate main pushes and PRs without duplicate branch pushes', () {
    final build = File('.github/workflows/build.yml').readAsStringSync();
    final device = File('.github/workflows/device-smoke.yml').readAsStringSync();

    expect(
      build,
      contains(r'github.event.pull_request.number || github.ref_name'),
    );
    expect(
      device,
      contains(r'github.event.pull_request.number || github.ref_name'),
    );
    expect(build, contains('branches: [main, master]'));
    expect(build, contains('types: [opened, synchronize, reopened]'));
    expect(build, isNot(contains('ready_for_review')));
    expect(device, contains('branches: [main, master]'));
    expect(build, contains('cancel-in-progress: true'));
    expect(device, contains('cancel-in-progress: true'));
    expect(device, contains('max-parallel: 2'));
    expect(
      build,
      isNot(contains(r'github.event.pull_request.number || github.run_id')),
    );
    expect(
      device,
      isNot(contains(r'github.event.pull_request.number || github.run_id')),
    );
  });

  test('exact-head recovery dispatch pins and verifies the requested commit', () {
    final dispatcher =
        File('.github/workflows/pr-ci-recovery-dispatcher.yml').readAsStringSync();
    final build = File('.github/workflows/build.yml').readAsStringSync();

    expect(dispatcher, contains('const defaultBranch = repository.data.default_branch;'));
    expect(dispatcher, contains('branch: defaultBranch'));
    expect(dispatcher, contains("event: 'workflow_dispatch'"));
    expect(dispatcher, contains('ref: defaultBranch'));
    expect(dispatcher, contains('inputs: { target_sha: sha }'));
    expect(dispatcher, contains('run.display_title === `Arvin Build (${sha})`'));
    expect(dispatcher, isNot(contains('run.head_sha === sha')));
    expect(build, contains('name: Verify exact requested revision'));
    expect(build, contains('test "$actual" = "$TARGET_SHA"'));
    expect(build, contains('EXACT_TARGET_SHA=$actual'));
    expect(build, contains('inputs.target_sha'));
  });

  test('Parallel Wave keeps one lightweight contract gate', () {
    final parallel =
        File('.github/workflows/parallel-wave.yml').readAsStringSync();
    const draftOnly =
        "github.event_name != 'pull_request' || github.event.pull_request.draft == true";

    expect(parallel.split(draftOnly).length - 1, 1);
    expect(parallel, contains("branches: ['wave/**', 'ci/**']"));
    expect(parallel, contains('cancel-in-progress: true'));
    expect(
      parallel,
      contains(
        'Arvin Build owns Analyze + all sharded tests + Debug/Release APK',
      ),
    );
    expect(
      parallel,
      contains(
        'Arvin Device Smoke owns real Android integration evidence for Ready PRs',
      ),
    );
    expect(parallel, contains('contract:'));
    expect(parallel, isNot(contains('surface:')));
    expect(parallel, isNot(contains('flutter test')));
  });
  test('legacy ARVIN release dispatcher cannot cancel exact-head main validation', () {
    expect(
      File('.github/workflows/arvin-release-dispatcher.yml').existsSync(),
      isFalse,
    );
    final build = File('.github/workflows/build.yml').readAsStringSync();
    expect(build, contains('push:'));
    expect(build, contains('pull_request:'));
    expect(build, contains('workflow_dispatch:'));
  });

}
