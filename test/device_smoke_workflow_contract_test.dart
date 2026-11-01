import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('device smoke defines exactly seven canonical lanes on one exact target SHA', () {
    final workflow =
        File('.github/workflows/device-smoke.yml').readAsStringSync();

    expect(workflow, contains('name: Arvin Device Smoke'));
    expect(workflow, contains('workflow_dispatch:'));
    expect(workflow, contains('target_sha:'));
    expect(
      workflow,
      contains(r'TARGET_SHA: ${{ github.event_name == \'workflow_dispatch\' && inputs.target_sha || github.event_name == \'pull_request\' && github.event.pull_request.head.sha || github.sha }}'),
    );

    // One shared TARGET_SHA is used by every matrix lane, and checkout is
    // explicitly fenced to that exact revision before tests can run.
    expect(workflow, contains(r'ref: ${{ env.TARGET_SHA }}'));
    expect(workflow, contains('name: Record and verify checkout revision'));
    expect(workflow, contains(r'actual="$(git rev-parse HEAD)"'));
    expect(workflow, contains(r'echo "EXPECTED_TARGET_SHA=$TARGET_SHA"'));
    expect(workflow, contains(r'echo "CHECKED_OUT_SHA=$actual"'));
    expect(workflow, contains(r'echo "EXACT_TARGET_SHA=$actual"'));
    expect(workflow, contains(r'if [ "$actual" != "$TARGET_SHA" ]; then'));
    expect(
      workflow,
      contains(r'CHECKOUT SHA mismatch: expected $TARGET_SHA, got $actual'),
    );

    final matrixScenarios = RegExp(
      r'\{"scenario":"([^"]+)","test_file":"([^"]+)"\}',
    ).allMatches(workflow).toList();
    final scenarioMappings = matrixScenarios
        .map((match) => '${match.group(1)}:${match.group(2)}')
        .toSet();

    expect(matrixScenarios, hasLength(7));
    expect(
      scenarioMappings,
      equals(<String>{
        'smoke-boot:integration_test/android_home_smoke_test.dart',
        'smoke-navigation:integration_test/android_people_smoke_test.dart',
        'smoke-calendar-segmented-view:integration_test/calendar_card_interaction_test.dart',
        'smoke-quick-capture:integration_test/android_quick_capture_smoke_test.dart',
        'smoke-task-lifecycle:integration_test/android_backup_restore_sql_smoke_test.dart',
        'smoke-reminder-vazirmatn:integration_test/calendar_card_interaction_test.dart',
        'smoke-follow-up-persistence:integration_test/android_sql_persistence_smoke_test.dart',
      }),
      reason: 'The seven canonical lanes must map to their real integration tests.',
    );

    // The Reminder-specific compatibility suite belongs to the Reminder lane;
    // no retired scenario identifiers may silently suppress it.
    expect(
      workflow,
      contains("if: matrix.scenario == 'smoke-reminder-vazirmatn'"),
    );
    expect(workflow, isNot(contains("matrix.scenario == 'calendar'")));

    // Screenshot upload conditions must use the actual matrix identifiers.
    expect(
      workflow,
      contains("matrix.scenario == 'smoke-boot'"),
    );
    expect(
      workflow,
      contains("matrix.scenario == 'smoke-quick-capture'"),
    );
    expect(
      workflow,
      contains("matrix.scenario == 'smoke-navigation'"),
    );
    expect(
      workflow,
      contains("matrix.scenario == 'smoke-calendar-segmented-view'"),
    );
    expect(
      workflow,
      contains("matrix.scenario == 'smoke-reminder-vazirmatn'"),
    );
    expect(workflow, isNot(contains("matrix.scenario == 'home'")));
    expect(workflow, isNot(contains("matrix.scenario == 'people'")));

    expect(workflow, contains('reactivecircus/android-emulator-runner@v2'));
    expect(workflow, contains('max-parallel: 2'));
    expect(workflow, contains('timeout-minutes: 30'));
    expect(
      workflow,
      contains('flutter drive --driver=test_driver/integration_test.dart --target='),
    );
    expect(workflow, contains('actions/upload-artifact@v5'));
    expect(
      workflow,
      contains(r'matrix: ${{ fromJSON(needs.prepare-matrix.outputs.matrix) }}'),
    );
    expect(
      workflow,
      contains(r'matrix: ${{ steps.set-matrix.outputs.matrix }}'),
    );
  });
}
