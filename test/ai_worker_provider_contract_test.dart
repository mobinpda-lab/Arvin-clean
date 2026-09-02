import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AI worker is OpenAI-backed and fail-closed', () {
    final workflow = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();
    final runtime = File('.github/arvin/agent-runtime.py').readAsStringSync();
    expect(workflow, contains('OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}'));
    expect(workflow, contains('OPENAI_MODEL: ${{ vars.OPENAI_MODEL'));
    expect(workflow, isNot(contains('copilot-requests: write')));
    expect(workflow, isNot(contains('@github/copilot')));
    expect(runtime, contains('def openai_response(prompt, timeout_seconds):'));
    expect(runtime, contains('WAITING_AI_PROVIDER'));
    expect(runtime, contains('def validate_diff_structure(diff):'));
    expect(runtime, contains('git", "apply", "--check"'));
  });

  test('AI worker bounds provider work and retries', () {
    final runtime = File('.github/arvin/agent-runtime.py').readAsStringSync();
    expect(runtime, contains('ARVIN_PROVIDER_TIMEOUT_SECONDS'));
    expect(runtime, contains('ARVIN_PROVIDER_BUDGET_SECONDS'));
    expect(runtime, contains('def next_provider_timeout(deadline):'));
    expect(runtime, contains('for attempt in range(1, MAX_FIX_ATTEMPTS + 1):'));
    expect(runtime, contains('"--recount"'));
  });

  test('AI worker has one launch authority', () {
    final worker = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();
    final router = File('.github/workflows/arvin-orchestrator.yml').readAsStringSync();
    expect(worker, contains('workflow_dispatch:'));
    expect(worker, isNot(contains("github.event.label.name == 'arvin-auto'")));
    expect(router, contains("workflow_id: 'arvin-agent-worker.yml'"));
    expect(router, contains('createWorkflowDispatch'));
  });

  test('AI worker cannot become a second merge authority', () {
    final workflow = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();
    expect(workflow, isNot(contains('gh pr merge')));
    expect(workflow, isNot(contains('merge_pull_request')));
    expect(workflow, contains('production-orchestrator.yml'));
  });
}
