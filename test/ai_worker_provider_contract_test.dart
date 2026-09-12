import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AI worker uses the configured OpenAI workflow contract', () {
    final workflow =
        File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();
    final runtime = File('.github/arvin/agent-runtime.py').readAsStringSync();
    final queue =
        File('.github/workflows/arvin-autonomous-queue.yml').readAsStringSync();

    expect(workflow, contains('OPENAI_API_KEY: \${{ secrets.OPENAI_API_KEY }}'));
    expect(workflow,
        contains("OPENAI_MODEL: \${{ vars.OPENAI_MODEL || 'gpt-5.6' }}"));
    expect(workflow, isNot(contains('copilot-requests: write')));
    expect(workflow, isNot(contains('npm install -g @github/copilot')));
    expect(workflow, isNot(contains('ARVIN_COPILOT_MODEL')));
    expect(workflow,
        isNot(contains('switching to bounded read-only Copilot fallback')));
    expect(workflow, contains('uses: subosito/flutter-action@v2'));
    expect(workflow, contains('test -n "\$ARVIN_ISSUE_NUMBER"'));
    expect(workflow, contains('python3 .github/arvin/agent-runtime.py'));
    expect(workflow, contains('set +e'));
    expect(workflow, contains('rc=\$?'));
    expect(workflow, contains('if [ "\$rc" -eq 75 ]'));
    expect(workflow, contains('--add-label factory:blocked'));
    expect(workflow, contains('canonical retryable factory cooldown'));
    expect(queue, contains("const RETRYABLE_BLOCK_LABEL = 'factory:blocked';"));
    expect(queue, contains('const RETRY_COOLDOWN_MS = 15 * 60 * 1000;'));

    expect(runtime, contains('def model_response(prompt, timeout_seconds):'));
    expect(runtime, contains('OPENAI_API_KEY'));
    expect(runtime, contains('def openai_response(prompt, timeout_seconds):'));
    expect(runtime, contains('ARVIN_PROVIDER_TIMEOUT_SECONDS'));
    expect(runtime, contains('ARVIN_PROVIDER_BUDGET_SECONDS'));
    expect(runtime, contains('ARVIN_PROVIDER_MAX_429_RETRIES'));
    expect(runtime, contains('ARVIN_PROVIDER_429_BASE_DELAY_SECONDS'));
    expect(runtime, contains('def next_provider_timeout(deadline):'));
  });

  test('AI worker rejects malformed model patches and bounds provider work', () {
    final runtime = File('.github/arvin/agent-runtime.py').readAsStringSync();

    expect(runtime, contains('def validate_diff_structure(diff):'));
    expect(runtime,
        contains('Patch must begin with a complete `diff --git` file section'));
    expect(runtime,
        contains('Each file section must include both `---` and `+++` headers'));
    expect(runtime,
        contains('Each file section must include at least one complete `@@` hunk'));
    expect(runtime, contains('timeout=timeout_seconds'));
    expect(runtime, contains('for attempt in range(1, MAX_FIX_ATTEMPTS + 1):'));
    expect(runtime, contains('"--recount"'));
    expect('diff = request_diff('.allMatches(runtime).length, 1);
  });

  test('AI worker has exactly one explicit launch authority', () {
    final worker =
        File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();
    final router =
        File('.github/workflows/arvin-orchestrator.yml').readAsStringSync();
    final productionLoop =
        File('.github/workflows/arvin-production-loop.yml').readAsStringSync();
    final queue =
        File('.github/workflows/arvin-autonomous-queue.yml').readAsStringSync();

    expect(worker, contains('workflow_dispatch:'));
    expect(worker, isNot(contains('\n  issues:\n')));
    expect(worker, contains(r'group: arvin-agent-${{ inputs.issue_number }}'));
    expect(worker, contains(r'ARVIN_ISSUE_NUMBER: ${{ inputs.issue_number }}'));
    expect(worker, isNot(contains("github.event.label.name == 'arvin-auto'")));

    expect(queue, contains("workflow_id: 'arvin-agent-worker.yml'"));
    expect(queue, contains('activeAiLease'));
    expect(queue, contains('candidates.slice(0, 1)'));
    expect(queue, contains('arvin-autonomous-stale-lease-release'));

    expect(router, isNot(contains("workflow_id: 'arvin-agent-worker.yml'")));
    expect(router, contains('arvin-autonomous-queue-handoff'));
    expect(router, contains("labels: ['factory:ready']"));

    expect(productionLoop, isNot(contains("workflow_id: 'arvin-agent-worker.yml'")));
    expect(productionLoop, contains("workflow_id: 'arvin-autonomous-queue.yml'"));
  });

  test('AI worker cannot become a second merge authority', () {
    final workflow =
        File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();

    expect(workflow, isNot(contains('gh pr merge')));
    expect(workflow, isNot(contains('merge_pull_request')));
    expect(workflow, contains('production-orchestrator.yml'));
    expect(workflow, contains('parallel-wave.yml'));
  });
}
