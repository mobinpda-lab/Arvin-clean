import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release publication is guarded by the existing product acceptance gates', () {
    final workflow = File('.github/workflows/release-closure.yml')
        .readAsStringSync();

    const gate = 'name: Require explicit product release approval';
    const setup = 'name: Setup exact Flutter';
    const createRelease = 'name: Create exact-head tag and prerelease';
    const uploadAssets = 'name: Upload release assets';
    const removeStale = 'name: Remove stale Arvin prereleases';

    final gateIndex = workflow.indexOf(gate);
    expect(gateIndex, greaterThanOrEqualTo(0));
    expect(workflow, contains('issue_number: 2102'));
    expect(workflow, contains('  issues: read'));
    expect(workflow, contains('  cancel-in-progress: true'));
    expect(
      workflow,
      contains('const tag = `v\${appVersion}-build\${buildNumber}-arvin-\${sha.slice(0,7)}`;'),
    );
    expect(workflow, contains('pull_number: 1901'));
    expect(workflow, contains('await hideUnapprovedPrereleases();'));
    expect(workflow, contains('draft: true'));
    expect(workflow, contains('HIDDEN_UNAPPROVED_PRERELEASE='));
    expect(
      workflow,
      contains("if: steps.release_state.outputs.already_released != 'true'"),
    );

    // Fail closed before setup/build and before every release side effect.
    expect(gateIndex, lessThan(workflow.indexOf(setup)));
    expect(gateIndex, lessThan(workflow.indexOf(createRelease)));
    expect(gateIndex, lessThan(workflow.indexOf(uploadAssets)));
    expect(gateIndex, lessThan(workflow.indexOf(removeStale)));
  });
}
