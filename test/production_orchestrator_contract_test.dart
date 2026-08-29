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
    expect(text, contains("['pull_request', 'workflow_dispatch'].includes(r.event)"));
    expect(text, contains('merge_base_commit?.sha === mainSha'));
    expect(text, contains('locked.data.head.sha !== headSha'));
    expect(text, contains('locked.data.mergeable !== true'));
    expect(text, contains("merge_method: 'squash'"));
    expect(text, contains('sha: headSha'));

    expect(text, contains('if (!labels.has(AUTO_LABEL)) continue;'));
    expect(text, contains('return;'));
  });
}
