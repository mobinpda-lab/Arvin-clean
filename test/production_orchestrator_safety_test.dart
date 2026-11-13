import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
void main() {
  test('production orchestrator preserves triggers but cannot promote or merge', () {
    final workflow = File('.github/workflows/production-orchestrator.yml').readAsStringSync();
    expect(workflow, contains('workflow_run:'));
    expect(workflow, contains('schedule:'));
    expect(workflow, contains('workflow_dispatch:'));
    expect(workflow, contains('actions: write'));
    expect(workflow, contains('pull-requests: read'));
    expect(workflow, contains('contents: read'));
    expect(workflow, isNot(contains('github.rest.pulls.merge')));
    expect(workflow, isNot(contains('pulls.merge(')));
    expect(workflow, isNot(contains('markPullRequestReadyForReview')));
    expect(workflow, isNot(contains('contents: write')));
    expect(workflow, isNot(contains('pull-requests: write')));
  });
}
