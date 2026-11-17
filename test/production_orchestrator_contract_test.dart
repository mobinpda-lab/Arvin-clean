import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('autonomous PR generation and merge authority are retired', () {
    for (final path in const <String>[
      '.github/workflows/production-orchestrator.yml',
      '.github/workflows/arvin-orchestrator.yml',
      '.github/workflows/arvin-agent-worker.yml',
      '.github/workflows/arvin-autonomous-queue.yml',
      '.github/workflows/arvin-production-loop.yml',
    ]) {
      expect(File(path).existsSync(), isFalse, reason: '$path must not be an active automation path');
    }
  });

  test('recovery dispatcher is constrained to the canonical PR', () {
    final dispatcher = File('.github/workflows/pr-ci-recovery-dispatcher.yml').readAsStringSync();

    expect(dispatcher, contains('pull_number: 3495'));
    expect(dispatcher, contains('const pulls = [canonical];'));
    expect(dispatcher, contains("workflow_id: 'build.yml'"));
    expect(dispatcher, contains('inputs: { target_sha: sha }'));
    expect(dispatcher, isNot(contains('createPullRequest')));
    expect(dispatcher, isNot(contains('gh pr create')));
    expect(dispatcher, isNot(contains('gh pr merge')));
  });

  test('release closure remains manual, owner-gated and canonical', () {
    final release = File('.github/workflows/release-closure.yml').readAsStringSync();

    expect(release, contains('workflow_dispatch:'));
    expect(release, contains('owner_approval:'));
    expect(release, contains("inputs.owner_approval == 'APPROVE RELEASE'"));
    expect(release, contains("github.actor == 'mobinpda-lab'"));
    expect(release, contains('pull_number: 3495'));
    expect(release, contains('issue_number: 2102'));
    expect(release, contains('pull_number: 1901'));
    expect(release, isNot(contains('schedule:')));
    expect(release, isNot(contains('pull_request:')));
    expect(release, isNot(contains('workflow_run:')));
  });
}
