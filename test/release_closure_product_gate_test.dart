import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release publication is guarded by the existing product acceptance gates', () {
    final workflow = File('.github/workflows/release-closure.yml')
        .readAsStringSync();

    const internalBuild = 'name: Build production-signed Release APK';
    const storeEvidence = 'name: Store release evidence';
    const uploadInternalArtifact = 'name: Upload internal Release APK artifact';
    const gate = 'name: Require explicit product release approval';
    const createRelease = 'name: Create exact-head tag and prerelease';
    const uploadAssets = 'name: Upload release assets';
    const removeStale = 'name: Remove stale Arvin prereleases';

    final internalBuildIndex = workflow.indexOf(internalBuild);
    final evidenceIndex = workflow.indexOf(storeEvidence);
    final internalUploadIndex = workflow.indexOf(uploadInternalArtifact);
    final gateIndex = workflow.indexOf(gate);
    expect(internalBuildIndex, greaterThanOrEqualTo(0));
    expect(evidenceIndex, greaterThan(internalBuildIndex));
    expect(internalUploadIndex, greaterThan(evidenceIndex));
    expect(gateIndex, greaterThan(internalUploadIndex));

    // Internal build evidence may be produced before approval. Publication must
    // remain fail-closed until the existing product acceptance gates are closed.
    expect(workflow, contains('issue_number: 2102'));
    expect(workflow, contains('  issues: read'));
    expect(workflow, contains('  cancel-in-progress: false'));
    expect(workflow, contains("workflows: ['Arvin Device Smoke']"));
    expect(workflow, contains("github.event.workflow_run.conclusion == 'success'"));
    expect(workflow, contains("github.event.workflow_run.event == 'push'"));
    expect(workflow, contains("github.event.workflow_run.head_branch == 'main'"));
    expect(workflow, contains("github.event_name == 'workflow_dispatch'"));
    expect(workflow, isNot(contains("workflows: ['Arvin Production Orchestrator']")));
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

    // Evidence is explicit and verifiable; don't pin the test to file offsets
    // or byte/line counts that change when workflow documentation evolves.
    expect(workflow, contains('BUILD_RESULT=success'));
    expect(workflow, contains('TEST_RESULT=success'));
    expect(workflow, contains('MAIN_SHA='));
    expect(workflow, contains('RELEASE_ARTIFACT='));
    expect(workflow, contains('ARTIFACT_SHA256='));
    expect(workflow, contains('sha256sum'));
    expect(workflow, contains('artifact.sha256'));

    // Fail closed before every external release side effect.
    expect(gateIndex, lessThan(workflow.indexOf(createRelease)));
    expect(gateIndex, lessThan(workflow.indexOf(uploadAssets)));
    expect(gateIndex, lessThan(workflow.indexOf(removeStale)));
  });
}
