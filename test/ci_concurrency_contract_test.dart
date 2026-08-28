import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Build and Device cancel superseded non-PR runs by ref', () {
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
    expect(build, contains('cancel-in-progress: true'));
    expect(device, contains('cancel-in-progress: true'));
    expect(
      build,
      isNot(contains(r'github.event.pull_request.number || github.run_id')),
    );
    expect(
      device,
      isNot(contains(r'github.event.pull_request.number || github.run_id')),
    );
  });

  test('Parallel Wave runs Fast for Draft PRs and skips duplicate Ready work', () {
    final parallel =
        File('.github/workflows/parallel-wave.yml').readAsStringSync();
    const draftOnly =
        "github.event_name != 'pull_request' || github.event.pull_request.draft == true";

    expect(parallel.split(draftOnly).length - 1, 2);
    expect(parallel, contains("branches: ['wave/**', 'ci/**']"));
    expect(parallel, contains('cancel-in-progress: true'));
    expect(parallel, contains('Arvin Build + Device Smoke'));
  });
}
