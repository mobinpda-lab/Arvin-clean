import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AI worker keeps OpenAI when configured and has a GitHub-native fallback', () {
    final workflow = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();
    final runtime = File('.github/arvin/agent-runtime.py').readAsStringSync();

    expect(workflow, contains('copilot-requests: write'));
    expect(workflow, contains("if: env.OPENAI_API_KEY == ''"));
    expect(workflow, contains('npm install -g @github/copilot'));
    expect(workflow, contains('uses: subosito/flutter-action@v2'));
    expect(workflow, contains('test -n "\$ARVIN_ISSUE_NUMBER"'));
    expect(workflow, isNot(contains('test -n "\$OPENAI_API_KEY"')));

    expect(runtime, contains('def model_response(prompt, timeout_seconds):'));
    expect(runtime, contains('OPENAI_API_KEY'));
    expect(runtime, contains('GitHub Copilot CLI via GITHUB_TOKEN'));
    expect(runtime, contains('--available-tools=view,grep,glob'));
    expect(runtime, contains('--allow-tool=read'));
    expect(runtime, contains('--deny-tool=write'));
    expect(runtime, contains('--deny-tool=shell'));
    expect(runtime, contains('--deny-tool=url'));
    expect(runtime, contains('--disable-builtin-mcps'));
    expect(runtime, contains('["flutter", "pub", "get"]'));
  });

  test('AI worker rejects malformed model patches and bounds provider work', () {
    final runtime = File('.github/arvin/agent-runtime.py').readAsStringSync();

    expect(runtime, contains('ARVIN_PROVIDER_TIMEOUT_SECONDS'));
    expect(runtime, contains('ARVIN_PROVIDER_BUDGET_SECONDS'));
    expect(runtime, contains('def validate_diff_structure(diff):'));
    expect(runtime, contains('Patch must begin with a complete `diff --git` file section'));
    expect(runtime, contains('Each file section must include both `---` and `+++` headers'));
    expect(runtime, contains('Each file section must include at least one complete `@@` hunk'));
    expect(runtime, contains('def next_provider_timeout(deadline):'));
    expect(runtime, contains('AI provider retry budget exhausted'));
    expect(runtime, contains('timeout=timeout_seconds'));
    expect(runtime, contains('for attempt in range(1, MAX_FIX_ATTEMPTS + 1):'));
    expect(runtime, contains('"--recount"'));
    expect('diff = request_diff('.allMatches(runtime).length, 1);
  });

  test('AI worker has exactly one explicit launch authority', () {
    final worker = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();
    final router = File('.github/workflows/arvin-orchestrator.yml').readAsStringSync();
    final productionLoop = File('.github/workflows/arvin-production-loop.yml').readAsStringSync();

    expect(worker, contains('workflow_dispatch:'));
    expect(worker, isNot(contains('\n  issues:\n')));
    expect(worker, contains(r'group: arvin-agent-${{ inputs.issue_number }}'));
    expect(worker, contains(r'ARVIN_ISSUE_NUMBER: ${{ inputs.issue_number }}'));
    expect(worker, isNot(contains("github.event.label.name == 'arvin-auto'")));

    expect(router, contains("workflow_id: 'arvin-agent-worker.yml'"));
    expect(router, contains('createWorkflowDispatch'));
    expect(router, contains('<!-- arvin-worker-dispatch -->'));

    expect(productionLoop, contains("workflow_id: 'arvin-agent-worker.yml'"));
    expect(productionLoop, contains('createWorkflowDispatch'));
  });

  test('AI worker cannot become a second merge authority', () {
    final workflow = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();

    expect(workflow, isNot(contains('gh pr merge')));
    expect(workflow, isNot(contains('merge_pull_request')));
    expect(workflow, contains('production-orchestrator.yml'));
    expect(workflow, contains('parallel-wave.yml'));
  });
}
