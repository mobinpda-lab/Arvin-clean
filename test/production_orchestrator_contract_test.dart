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

    expect(text, contains('createWorkflowDispatch'));
    expect(text, contains('error?.status !== 422'));
    expect(text, contains('reusing existing'));
    expect(text, contains("dispatchOrReuse('build.yml', 'Arvin Build')"));
    expect(text, contains("dispatchOrReuse('device-smoke.yml', 'Arvin Device Smoke')"));
    expect(text, contains('waitForHeavy'));
    expect(text, contains("build?.conclusion === 'success'"));
    expect(text, contains("device?.conclusion === 'success'"));

    expect(text, contains('async function reportFailure(run)'));
    expect(text, contains("!['failure', 'timed_out'].includes(run?.conclusion)"));
    expect(text, contains("workflow_id: 'arvin-production-loop.yml'"));
    expect(text, contains('failure_head_sha: String(run.head_sha)'));
    expect(text, contains('await reportFailure(fast);'));
    expect(text, contains('await reportFailure(build);'));
    expect(text, contains('await reportFailure(device);'));

    expect(text, contains('if (!labels.has(AUTO_LABEL)) continue;'));
    expect(text, contains('preMergeMain.data.commit.sha !== mainSha'));
    expect(text, contains('locked.data.head.sha !== headSha'));
    expect(text, contains('locked.data.mergeable !== true'));
    expect(text, contains("merge_method: 'squash'"));
    expect(text, contains('sha: headSha'));
    expect(text, contains('return;'));
  });

  test('autonomous issue to PR path funnels through canonical queue', () {
    final router = File('.github/workflows/arvin-orchestrator.yml').readAsStringSync();
    final queue = File('.github/workflows/arvin-autonomous-queue.yml').readAsStringSync();
    final worker = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();

    expect(router, contains('arvin-autonomous-queue-handoff'));
    expect(router, contains("labels: ['factory:ready']"));
    expect(router, isNot(contains("workflow_id: 'arvin-agent-worker.yml'")));

    expect(queue, contains("workflow_id: 'arvin-agent-worker.yml'"));
    expect(queue, contains('expected_main_sha: main.data.commit.sha'));
    expect(queue, contains('activeAiLease'));
    expect(queue, contains('candidates.slice(0, 1)'));
    expect(queue, contains('arvin-autonomous-stale-lease-release'));

    expect(
      worker,
      contains(r'gh workflow run parallel-wave.yml --repo "$GITHUB_REPOSITORY" --ref "$BRANCH"'),
    );
    expect(
      worker,
      contains(r'gh workflow run production-orchestrator.yml --repo "$GITHUB_REPOSITORY" --ref main -f pr_number="$PR_NUMBER"'),
    );
  });

  test('production feedback ignores cancellations and hands failures to canonical queue', () {
    final loop = File('.github/workflows/arvin-production-loop.yml').readAsStringSync();

    expect(loop, contains('failure_workflow:'));
    expect(loop, contains('failure_run_url:'));
    expect(loop, contains('failure_head_sha:'));
    expect(loop, contains('failure_conclusion:'));
    expect(loop, contains("if (conclusion === 'cancelled')"));
    expect(loop, contains('no Auto-Fix task is created'));
    expect(loop, contains("!['failure', 'timed_out'].includes(conclusion)"));
    expect(loop, contains('Auto-Fix already exists'));
    expect(loop, contains("labels: ['arvin-auto']"));
    expect(loop, contains("workflow_id: 'arvin-autonomous-queue.yml'"));
    expect(loop, isNot(contains("workflow_id: 'arvin-agent-worker.yml'")));
    expect(loop, contains('const title = issue.data.title.toLowerCase()'));
    expect(loop, isNot(contains("const text = \`${issue.data.title}\\n${issue.data.body || ''}\`.toLowerCase()")));
    expect(loop, contains("error?.status !== 422"));
    expect(loop, contains('Leaving only the test-worker gate unverified'));
    expect(loop, isNot(contains("['failure', 'cancelled', 'timed_out'].includes(conclusion)")));
  });
}
