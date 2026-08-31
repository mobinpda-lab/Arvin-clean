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

    // One provider request site inside the bounded attempt loop prevents the
    // old nested self-fix path from multiplying MAX_FIX_ATTEMPTS calls.
    expect('diff = request_diff('.allMatches(runtime).length, 1);
  });

  test('AI worker cannot become a second merge authority', () {
    final workflow = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();

    expect(workflow, isNot(contains('gh pr merge')));
    expect(workflow, isNot(contains('merge_pull_request')));
    expect(workflow, contains('production-orchestrator.yml'));
    expect(workflow, contains('parallel-wave.yml'));
  });
}
