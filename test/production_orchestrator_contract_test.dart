import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production orchestrator stays opt-in, serialized and current-main safe', () {
    final text = File('.github/workflows/production-orchestrator.yml').readAsStringSync();
    expect(text, contains("cron: '*/5 * * * *'"));
    expect(text, contains('pr_number:'));
    expect(text, contains("const AUTO_LABEL = 'arvin-auto';"));
    expect(text, contains('cancel-in-progress: false'));
    expect(text, contains('actions: write'));
    expect(text, contains('createWorkflowDispatch'));
    expect(text, contains('merge_base_commit?.sha === mainSha'));
    expect(text, contains('markPullRequestReadyForReview'));
    expect(text, contains("merge_method: 'squash'"));
    expect(text, contains('sha: headSha'));
  });

  test('autonomous issue to PR path uses explicit worker dispatch with exact main', () {
    final router = File('.github/workflows/arvin-orchestrator.yml').readAsStringSync();
    final worker = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();
    expect(router, contains('arvin-worker-dispatch'));
    expect(router, contains('createWorkflowDispatch'));
    expect(router, contains("workflow_id: 'arvin-agent-worker.yml'"));
    expect(router, contains('issue_number: String(item.number)'));
    expect(router, contains('expected_main_sha: main.data.commit.sha'));
    expect(worker, contains('production-orchestrator.yml'));
  });

  test('production feedback ignores cancellations and launches worker only for failures', () {
    final loop = File('.github/workflows/arvin-production-loop.yml').readAsStringSync();
    expect(loop, contains('failure_workflow:'));
    expect(loop, contains('failure_run_url:'));
    expect(loop, contains('failure_head_sha:'));
    expect(loop, contains('failure_conclusion:'));
    expect(loop, contains("if (conclusion === 'cancelled')"));
    expect(loop, contains('no Auto-Fix task is created'));
    expect(loop, contains("!['failure', 'timed_out'].includes(conclusion)"));
    expect(loop, contains('Auto-Fix already exists'));
    expect(loop, contains("workflow_id: 'arvin-agent-worker.yml'"));
    expect(loop, contains('created.data.number'));
    expect(loop, isNot(contains("['failure', 'cancelled', 'timed_out'].includes(conclusion)")));
  });
}
