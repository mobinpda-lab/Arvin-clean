import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production orchestrator stays opt-in, serialized and current-main safe', () {
    final text = File('.github/workflows/production-orchestrator.yml').readAsStringSync();

    expect(text, contains("cron: '*/15 * * * *'"));
    expect(text, contains("const AUTO_LABEL = 'arvin-auto';"));
    expect(text, contains('cancel-in-progress: false'));
    expect(text, contains("fast?.conclusion === 'success'"));
    expect(text, contains("build?.conclusion === 'success'"));
    expect(text, contains("device?.conclusion === 'success'"));
    expect(text, contains('buildBase === mainSha && deviceBase === mainSha'));
    expect(text, contains('locked.data.head.sha !== headSha'));
    expect(text, contains('locked.data.mergeable !== true'));
    expect(text, contains("merge_method: 'squash'"));
    expect(text, contains('sha: headSha'));
    expect(text, contains('markPullRequestReadyForReview'));

    // Never auto-process every PR: explicit label is mandatory.
    expect(text, contains('if (!labels.has(AUTO_LABEL)) continue;'));

    // Exactly one production merge per orchestrator invocation; remaining
    // lanes must revalidate against the newly advanced main.
    expect(text, contains('return;'));
  });
}
