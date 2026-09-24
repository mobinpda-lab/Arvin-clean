import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('device smoke stays Ready-only and runs real Android integration flows', () {
    final workflow =
        File('.github/workflows/device-smoke.yml').readAsStringSync();

    expect(workflow, contains('name: Arvin Device Smoke'));
    expect(workflow, contains("github.event.pull_request.draft == false"));
    expect(workflow, contains('reactivecircus/android-emulator-runner@v2'));
    expect(workflow, contains('people-device-smoke:'));
    expect(workflow, contains('timeout-minutes: 30'));
    expect(workflow, contains('integration_test/android_home_smoke_test.dart'));
    expect(workflow, contains('integration_test/android_quick_capture_smoke_test.dart'));
    expect(
      'flutter test'.allMatches(workflow.split('people-device-smoke:').first).length,
      3,
      reason: 'Home, Quick Capture, and Backup/Restore must run in separate Flutter/DDS sessions',
    );
    expect(
      workflow,
      contains('flutter test integration_test/android_people_smoke_test.dart -d emulator-'),
    );
  });
}
