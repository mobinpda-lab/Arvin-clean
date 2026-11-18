import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy recovery-wave auto-advance controller is retired', () {
    expect(
      File('.github/workflows/arvin-recovery-wave-controller.yml').existsSync(),
      isFalse,
    );
    expect(
      File('.github/workflows/arvin-agent-worker.yml').existsSync(),
      isFalse,
    );
    expect(
      File('.github/workflows/arvin-autonomous-queue.yml').existsSync(),
      isFalse,
    );
  });

  test('only canonical PR 3495 receives CI recovery dispatch', () {
    final dispatcher = File('.github/workflows/pr-ci-recovery-dispatcher.yml').readAsStringSync();

    expect(dispatcher, contains('pull_number: 3495'));
    expect(dispatcher, contains('const pulls = [canonical];'));
    expect(dispatcher, contains('maxDispatchesPerRun = 1'));
    expect(dispatcher, contains('inputs: { target_sha: sha }'));
    expect(dispatcher, isNot(contains('createPullRequest')));
    expect(dispatcher, isNot(contains('gh issue close')));
    expect(dispatcher, isNot(contains('gh pr merge')));
  });

  test('release and promotion remain explicit owner actions', () {
    final release = File('.github/workflows/release-closure.yml').readAsStringSync();

    expect(release, contains("inputs.owner_approval == 'APPROVE RELEASE'"));
    expect(release, contains("github.actor == 'mobinpda-lab'"));
    expect(release, contains("pr.head.ref !== 'recovery-02/main-based-integration'"));
    expect(release, contains('RELEASE BLOCKED'));
  });
}
