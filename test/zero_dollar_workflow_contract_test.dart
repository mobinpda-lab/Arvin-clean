import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zero-dollar diagnostic is branch-scoped, label-gated and read-only', () {
    final workflow = File('.github/workflows/zero-dollar-environment-smoke.yml')
        .readAsStringSync();
    expect(workflow, contains('branches: [recovery-02/main-based-integration]'));
    expect(workflow, contains('pull-requests: read'));
    expect(
      workflow,
      contains(r'[[ "$GITHUB_EVENT_NAME" == "push" ]]'),
    );
    expect(workflow, contains('EXPECTED_MAIN_SHA: 45e4202b03a434459e4c021a04efa7e8396359db'));
    expect(workflow, contains('PR_HEAD_SHA'));
    expect(workflow, contains('label_present'));
    expect(workflow, contains('zero-dollar-environment-smoke'));
    expect(workflow, contains('merge_base'));
    expect(workflow, contains('timeout 900 adb wait-for-device'));
    expect(workflow.contains(r'\${{'), isFalse);
    expect(workflow, isNot(contains('chmod 0666')));
  });
}
