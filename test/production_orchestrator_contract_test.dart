import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production orchestrator stays opt-in, serialized and current-main safe', () {
    final text = File('.github/workflows/production-orchestrator.yml').readAsStringSync();

    expect(text, contains("cron: '*/5 * * * *'"));
    expect(text, contains('pr_number:'));
    expect(text, contains("const AUTO_LABEL = 'arvin-auto';"));
    expect(text, contains("const directWake = context.eventName === 'workflow_dispatch';"));
    expect(text, contains('cancel-in-progress: false'));
    expect(text, contains('actions: write'));

    // Fast can be started either by the normal PR event or by the explicit
    // token-safe worker dispatch. It must still be completed and successful.
    expect(
      text,
      contains("fast?.status !== 'completed' || fast?.conclusion !== 'success'"),
    );
    expect(
      text,
      contains("['pull_request', 'workflow_dispatch'].includes(r.event)"),
    );
    expect(text, contains('waitForFast'));
    expect(text, contains('merge_base_commit?.sha === mainSha'));
    expect(text, contains('markPullRequestReadyForReview'));

    // Heavy gates are explicitly dispatched on the exact worker head and the
    // direct wake polls them instead of depending on recursive workflow_run.
    expect(text, contains('createWorkflowDispatch'));
    expect(text, contains("workflow_id: 'build.yml'"));
    expect(text, contains("workflow_id: 'device-smoke.yml'"));
    expect(text, contains('waitForHeavy'));
    expect(text, contains("build?.conclusion === 'success'"));
    expect(text, contains("device?.conclusion === 'success'"));

    // Merge stays opt-in, current-main locked, exact-head locked and serial.
    expect(text, contains('if (!labels.has(AUTO_LABEL)) continue;'));
    expect(text, contains('preMergeMain.data.commit.sha !== mainSha'));
    expect(text, contains('locked.data.head.sha !== headSha'));
    expect(text, contains('locked.data.mergeable !== true'));
    expect(text, contains("merge_method: 'squash'"));
    expect(text, contains('sha: headSha'));
    expect(text, contains('return;'));
  });

  test('autonomous issue to PR path uses explicit workflow dispatches', () {
    final router = File('.github/workflows/arvin-orchestrator.yml').readAsStringSync();
    final worker = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();

    // A label added with GITHUB_TOKEN must not be the only way to start the
    // code worker. The router explicitly starts it once and leaves a marker.
    expect(router, contains('arvin-worker-dispatch'));
    expect(router, contains('createWorkflowDispatch'));
    expect(router, contains("workflow_id: 'arvin-agent-worker.yml'"));
    expect(router, contains("inputs: { issue_number: String(issue.number) }"));

    // Likewise, a PR created by the worker explicitly starts exact-head Fast
    // and wakes the one canonical production merge authority for that PR.
    expect(worker, contains('actions: write'));
    expect(
      worker,
      contains('gh workflow run parallel-wave.yml --repo "$GITHUB_REPOSITORY" --ref "$BRANCH"'),
    );
    expect(
      worker,
      contains('gh workflow run production-orchestrator.yml --repo "$GITHUB_REPOSITORY" --ref main -f pr_number="$PR_NUMBER"'),
    );
  });
}
