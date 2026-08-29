import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production orchestrator stays opt-in, serialized and current-main safe', () {
    final text = File('.github/workflows/production-orchestrator.yml').readAsStringSync();

    expect(text, contains("cron: '*/5 * * * *'"));
    expect(text, contains("const AUTO_LABEL = 'arvin-auto';"));
    expect(text, contains('cancel-in-progress: false'));
    expect(text, contains('actions: write'));
    expect(text, contains("fast?.conclusion === 'success'"));
    expect(text, contains("build?.conclusion === 'success'"));
    expect(text, contains("device?.conclusion === 'success'"));
    expect(text, contains('markPullRequestReadyForReview'));
    expect(text, contains('createWorkflowDispatch'));
    expect(text, contains("workflow_id: 'build.yml'"));
    expect(text, contains("workflow_id: 'device-smoke.yml'"));
    expect(text, contains('runBelongsToPr'));
    expect(text, contains("r.event === 'workflow_dispatch'"));
    expect(text, contains("r.event === 'pull_request' && runBelongsToPr(r, prNumber)"));
    expect(text, contains("latestHeavyRun('Arvin Build', headSha, item.number)"));
    expect(text, contains("latestHeavyRun('Arvin Device Smoke', headSha, item.number)"));
    expect(text, contains('merge_base_commit?.sha === mainSha'));
    expect(text, contains('locked.data.head.sha !== headSha'));
    expect(text, contains('locked.data.mergeable !== true'));
    expect(text, contains("merge_method: 'squash'"));
    expect(text, contains('sha: headSha'));

    expect(text, contains('if (!labels.has(AUTO_LABEL)) continue;'));
    expect(text, contains('return;'));
  });

  test('orphan pull-request workflow runs cannot satisfy heavy gates', () {
    final text = File('.github/workflows/production-orchestrator.yml').readAsStringSync();

    expect(text, contains('function runBelongsToPr(run, prNumber)'));
    expect(text, contains('(run?.pull_requests || []).some(p => p.number === prNumber)'));
    expect(text, isNot(contains("['pull_request', 'workflow_dispatch'].includes(r.event)")));
  });
}
