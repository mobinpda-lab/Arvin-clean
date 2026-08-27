import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'device smoke stays Ready-only and captures real Android screenshot evidence',
      () {
    final workflow =
        File('.github/workflows/device-smoke.yml').readAsStringSync();

    expect(workflow, contains('name: Arvin Device Smoke'));
    expect(
      workflow,
      contains("github.event.pull_request.draft == false"),
    );
    expect(
      workflow,
      contains('reactivecircus/android-emulator-runner@v2'),
    );
    expect(
      workflow,
      contains(
        'flutter drive --driver=test_driver/integration_test.dart '
        '--target=integration_test/android_home_smoke_test.dart -d emulator-',
      ),
    );
    expect(workflow, contains('actions/upload-artifact@v4'));
    expect(workflow, contains(r'arvin-home-screenshot-${{ github.sha }}'));
    expect(workflow, contains('artifacts/screenshots/*.png'));
    expect(workflow, contains('if-no-files-found: error'));
  });
}
