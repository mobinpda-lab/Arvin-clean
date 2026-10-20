import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release publication enforces product gates and trusted manual authorization', () {
    final workflow = File('.github/workflows/release-closure.yml')
        .readAsStringSync();

    const manualGate = 'name: Require explicit manual product-owner authorization';
    const internalBuild = 'name: Test and build release APK from locked inputs';
    const storeEvidence = 'name: Store release evidence';
    const uploadInternalArtifact = 'name: Upload internal Release APK artifact';
    const productGate = 'name: Require explicit product release approval';
    const createRelease = 'name: Create exact-head tag and prerelease';
    const uploadAssets = 'name: Upload release assets';

    final manualGateIndex = workflow.indexOf(manualGate);
    final internalBuildIndex = workflow.indexOf(internalBuild);
    final evidenceIndex = workflow.indexOf(storeEvidence);
    final internalUploadIndex = workflow.indexOf(uploadInternalArtifact);
    final productGateIndex = workflow.indexOf(productGate);

    expect(manualGateIndex, greaterThanOrEqualTo(0));
    expect(manualGateIndex, lessThan(internalBuildIndex));
    expect(internalBuildIndex, greaterThanOrEqualTo(0));
    expect(evidenceIndex, greaterThan(internalBuildIndex));
    expect(internalUploadIndex, greaterThan(evidenceIndex));
    expect(productGateIndex, greaterThan(internalUploadIndex));

    // Product acceptance gates remain mandatory and fail closed.
    expect(workflow, contains('issue_number: 2102'));
    expect(workflow, contains("gate.data.state !== 'closed'"));
    expect(workflow, contains('pull_number: 1901'));
    expect(workflow, contains("regression.data.state !== 'closed'"));
    expect(workflow, contains('  issues: read'));
    expect(workflow, contains('  cancel-in-progress: false'));
    expect(workflow, contains("workflows: ['Arvin Device Smoke']"));
    expect(workflow, contains("github.event.workflow_run.conclusion == 'success'"));
    expect(workflow, contains("github.event.workflow_run.event == 'push'"));
    expect(workflow, contains("github.event.workflow_run.head_branch == 'main'"));
    expect(workflow, contains("github.event_name == 'workflow_dispatch'"));
    expect(workflow, isNot(contains("workflows: ['Arvin Production Orchestrator']")));

    // Manual dispatch requires the true boolean plus a trusted, configured actor.
    expect(workflow, contains(r'AUTHORIZED_BY_PRODUCT_OWNER: ${{ inputs.authorized_by_product_owner }}'));
    expect(workflow, contains('AUTHORIZED_BY_PRODUCT_OWNER" != "true"'));
    expect(workflow, contains(r'ACTOR: ${{ github.actor }}'));
    expect(workflow, contains(r'PRODUCT_OWNER_GITHUB: ${{ vars.ARVIN_PRODUCT_OWNER_GITHUB }}'));
    expect(workflow, contains(r'REPOSITORY_OWNER: ${{ github.repository_owner }}'));
    expect(workflow, contains(r'"$ACTOR" != "$PRODUCT_OWNER_GITHUB"'));
    expect(workflow, contains(r'"$REPOSITORY_OWNER" != "mobinpda-lab"'));
    expect(workflow, contains('MANUAL_PRODUCT_OWNER_GATE=passed'));

    // Existing releases/tags must never be automatically purged or mutated.
    expect(workflow, isNot(contains('hideUnapprovedPrereleases')));
    expect(workflow, isNot(contains('HIDDEN_UNAPPROVED_PRERELEASE')));
    expect(workflow, isNot(contains('FAILED_TO_HIDE_UNAPPROVED_PRERELEASE')));
    expect(workflow, isNot(contains('github.rest.repos.updateRelease')));
    expect(workflow, isNot(contains('deleteRef')));
    expect(workflow, isNot(contains('deleteRelease')));
    expect(workflow, isNot(contains('Remove stale Arvin prereleases')));

    expect(
      workflow,
      contains(r'const tag = `v${appVersion}-build${buildNumber}-arvin-${sha.slice(0,7)}`;'),
    );
    expect(
      workflow,
      contains("if: steps.release_state.outputs.already_released != 'true'"),
    );

    // Existing tag/asset names must not bypass build, signing, or product gates.
    expect(
      workflow,
      contains(r'existing release ${tag} requires independent provenance'),
    );
    expect(workflow, contains('asset filenames are not proof'));
    expect(workflow, contains('if (error.status !== 404) throw error;'));
    expect(workflow, contains("core.setOutput('already_released', 'false')"));
    expect(
      workflow,
      isNot(contains(r'complete = [`arvin-${appVersion}-build${buildNumber}.apk`')),
    );

    // Evidence is explicit and verifiable.
    expect(workflow, contains('BUILD_RESULT=success'));
    expect(workflow, contains('TEST_RESULT=success'));
    expect(workflow, contains('MAIN_SHA='));
    expect(workflow, contains('RELEASE_ARTIFACT='));
    expect(workflow, contains('ARTIFACT_SHA256='));
    expect(workflow, contains('sha256sum'));
    expect(workflow, contains('artifact.sha256'));

    // Product gate must precede every external release side effect.
    expect(productGateIndex, lessThan(workflow.indexOf(createRelease)));
    expect(productGateIndex, lessThan(workflow.indexOf(uploadAssets)));
  });

  test('legacy release workflow fails closed and cannot publish releases', () {
    final legacy = File('.github/workflows/release.yml').readAsStringSync();

    expect(legacy, contains('name: Arvin Release (disabled legacy path)'));
    expect(legacy, contains('contents: read'));
    expect(legacy, contains('name: Block unsafe legacy release path'));
    expect(legacy, contains('exit 1'));
    expect(legacy, contains('official signing'));
    expect(legacy, isNot(contains('softprops/action-gh-release')));
    expect(legacy, isNot(contains('contents: write')));
    expect(legacy, isNot(contains('tag_name:')));
  });

}
