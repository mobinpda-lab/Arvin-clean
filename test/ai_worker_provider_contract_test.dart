import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retired autonomous worker workflows stay absent', () {
    const retired = <String>[
      '.github/workflows/arvin-agent-worker.yml',
      '.github/workflows/arvin-autonomous-queue.yml',
      '.github/workflows/arvin-orchestrator.yml',
      '.github/workflows/arvin-production-loop.yml',
      '.github/workflows/arvin-recovery-wave-controller.yml',
      '.github/workflows/parallel-wave.yml',
    ];

    for (final path in retired) {
      expect(File(path).existsSync(), isFalse, reason: '$path is retired by REV10 one-path governance');
    }
  });

  test('canonical recovery dispatcher targets only PR 3495', () {
    final dispatcher = File('.github/workflows/pr-ci-recovery-dispatcher.yml').readAsStringSync();

    expect(dispatcher, contains('pull_number: 3495'));
    expect(dispatcher, contains('const pulls = [canonical];'));
    expect(dispatcher, contains("const workflowId = 'build.yml';"));
    expect(dispatcher, contains('workflow_id: workflowId'));
    expect(dispatcher, contains('inputs: { target_sha: sha }'));
    expect(dispatcher, isNot(contains('createPullRequest')));
    expect(dispatcher, isNot(contains('gh pr create')));
    expect(dispatcher, isNot(contains('gh pr merge')));
    expect(dispatcher, isNot(contains('mergePullRequest')));
  });

  test('legacy agent runtime is not invoked by active automation', () {
    final dispatcher = File('.github/workflows/pr-ci-recovery-dispatcher.yml').readAsStringSync();
    final release = File('.github/workflows/release-closure.yml').readAsStringSync();

    expect(dispatcher, isNot(contains('.github/arvin/agent-runtime.py')));
    expect(release, isNot(contains('.github/arvin/agent-runtime.py')));
    expect(release, contains('APPROVE RELEASE'));
  });
}
