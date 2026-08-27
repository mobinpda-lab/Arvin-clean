import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stale gate guard is main-only, minimal, and targeted', () {
    final workflow =
        File('.github/workflows/cancel-stale-pr-gates.yml').readAsStringSync();
    final script = File('tool/cancel_stale_pr_gates.py').readAsStringSync();

    expect(workflow, contains('name: Arvin Stale Gate Guard'));
    expect(workflow, contains('branches: [main, master]'));
    expect(workflow, contains('contents: read'));
    expect(workflow, contains('actions: write'));
    expect(workflow, contains('pull-requests: read'));
    expect(workflow, contains('python3 tool/cancel_stale_pr_gates.py --self-test'));
    expect(workflow, contains('python3 tool/cancel_stale_pr_gates.py'));

    expect(script, contains('HEAVY_WORKFLOWS = {"Arvin Build", "Arvin Device Smoke"}'));
    expect(script, contains('ACTIVE_STATUSES = ("queued", "in_progress")'));
    expect(script, contains('event != "pull_request"'));
    expect(script, contains('/compare/{current_main}...{head_sha}'));
    expect(script, contains('merge_base_commit'));
    expect(script, contains('/actions/runs/{run_id}/cancel'));
    expect(script, contains('uncertain API evidence'));

    expect(workflow, isNot(contains('pull_request:')));
    expect(workflow, isNot(contains('workflow_run:')));
    expect(script, isNot(contains('merge_pull_request')));
    expect(script, isNot(contains('update_ref')));
  });

  test('stale gate guard Python classifier self-test passes on Linux CI', () {
    if (!Platform.isLinux) return;
    final result = Process.runSync(
      'python3',
      const ['tool/cancel_stale_pr_gates.py', '--self-test'],
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout, contains('self-test: OK'));
  });
}
