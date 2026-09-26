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
    expect(device, contains('max-parallel: 6'));
    expect(
      build,
      isNot(contains(r'github.event.pull_request.number || github.run_id')),
    );
    expect(
      device,
      isNot(contains(r'github.event.pull_request.number || github.run_id')),
    );
  });

  test('Parallel Wave keeps only the lightweight contract gate', () {
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
        'Arvin Build owns the complete Analyze + sharded Test + Debug/Release APK gate',
      ),
    );
    expect(
      parallel,
      contains(
        'Arvin Device Smoke owns real Android integration evidence for Ready PRs',
      ),
    );
    expect(parallel, contains('Fast Lane: CI automation branches receive the lightweight contract gate.'));
    expect(parallel, isNot(contains('surface:')));
    expect(parallel, isNot(contains('flutter test')));
  });
}
