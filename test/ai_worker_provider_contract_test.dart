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

    expect(runtime, contains('def model_response(prompt):'));
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

  test('AI worker cannot become a second merge authority', () {
    final workflow = File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();

    expect(workflow, isNot(contains('gh pr merge')));
    expect(workflow, isNot(contains('merge_pull_request')));
    expect(workflow, contains('production-orchestrator.yml'));
    expect(workflow, contains('parallel-wave.yml'));
  });
}
