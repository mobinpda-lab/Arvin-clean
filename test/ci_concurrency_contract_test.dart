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
}
