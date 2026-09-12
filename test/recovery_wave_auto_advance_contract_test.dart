import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guarded AI worker merge closes its canonical source issue', () {
    final worker =
        File('.github/workflows/arvin-agent-worker.yml').readAsStringSync();

    expect(worker, contains('PR_BODY="Automated bounded Code Worker implementation'));
    expect(worker, contains('Closes #\$ARVIN_ISSUE_NUMBER'));
    expect(
      worker,
      contains('gh pr edit "\$PR_NUMBER" --repo "\$GITHUB_REPOSITORY" --body "\$PR_BODY" --add-label arvin-auto'),
    );
    expect(worker, contains('Production Orchestrator is the single promotion/merge authority'));
    expect(worker, isNot(contains('gh issue close')));
    expect(worker, isNot(contains('gh pr merge')));
  });

  test('recovery controller remains ordered and five-minute scheduled', () {
    final controller = File(
      '.github/workflows/arvin-recovery-wave-controller.yml',
    ).readAsStringSync();

    expect(controller, contains("cron: '*/5 * * * *'"));
    expect(controller, contains('const waves = [846, 847, 848, 849, 850, 851, 852, 853]'));
    expect(controller, contains("const firstOpenIndex = state.findIndex(x => x.issue.state === 'open')"));
    expect(controller, contains("labels: ['factory:ready']"));
    expect(controller, contains("workflow_id: 'arvin-autonomous-queue.yml'"));
  });

  test('bootstrap hold releases only after auto-close contract reaches main', () {
    final controller = File(
      '.github/workflows/arvin-recovery-wave-controller.yml',
    ).readAsStringSync();

    expect(controller, contains('arvin-auto-advance-bootstrap-hold'));
    expect(controller, contains("workerAutoCloseToken = 'Closes #\$ARVIN_ISSUE_NUMBER'"));
    expect(controller, contains("path: '.github/workflows/arvin-agent-worker.yml'"));
    expect(controller, contains("name: 'orchestrator:hold'"));
    expect(controller, contains('arvin-auto-advance-bootstrap-released'));
    expect(controller, contains('Manual owner'));
  });
}
