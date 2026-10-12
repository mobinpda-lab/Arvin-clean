# Arvin Repository Cleanup Audit — 2026-10-12

Repository: `mobinpda-lab/Arvin-clean`
Baseline main SHA: `a4dae51e93d9b3dcbc55ded366280e59183f16bc`
Cleanup branch: `chore/arvin-canonical-cleanup-main-20261012`
Related existing coordination issue: [#2026](https://github.com/mobinpda-lab/Arvin-clean/issues/2026)

## Goal

Remove genuinely unused or superseded repository content, consolidate duplicate implementations and documentation, and leave one clear canonical source for each product responsibility. Do not delete merely because a file is old; prove references, ownership and replacement first.

## Completed in this cleanup lane

### Removed: `docs/ARVIN_PROJECT_OPERATING_PACKAGE_v48.1_PATCH.md`

- The file described itself as a patch that must be combined with v48.0; no v48.0 companion exists in the current repository tree.
- Exact-name GitHub code search found no in-repository references to this patch.
- The repository contains a consolidated v48.2 operational source and the current owner execution command v8; this orphan patch is not an active product/runtime contract.
- Removed from the cleanup branch only; no direct write to `main`.
- Git history retains provenance and recovery of the removed content.

## Explicitly retained after inspection

- `docs/ARVIN_PROJECT_OPERATING_PACKAGE_v48.2_FINAL_OPERATIONAL_feshordeh.md`: retained because the v48.2 transfer manifest explicitly identifies this 16,720-line document as the approved consolidated source. It is large, but size alone does not prove it is unused.
- `docs/ARVIN_PROJECT_OPERATING_PACKAGE_v48.2_TRANSFER_MANIFEST.md` and `...SOURCE_VERIFIED.md`: retained as provenance for the approved transfer.
- `docs/ARVIN_UI_CANONICAL.md`: retained as the indexed canonical UI/ontology contract.
- `docs/UI/ARVIN_UI_CANONICAL.md`: not deleted in this pass; it contains owner visual-reference requirements and may hold unique content even though exact-path searches found no inbound references. Merge its unique requirements into the canonical UI document before removing it.
- `docs/AI_CONTINUATION_STATE.md`, `docs/AI_HANDOFF_CURRENT_FA.md`, `docs/PROJECT_STATUS.md`, `docs/ARVIN_STATUS.md`, and `docs/ARVIN_PROJECT_STATE.md`: the document authority index still names these as historical checkpoints. Their stale live status must be removed or clearly marked historical after preserving unique knowledge, not bulk-deleted.

## High-risk duplicate-code candidates — not yet deleted

- `lib/services/backup_service.dart` was removed after exact import-path search found no internal references. It was an alternate SharedPreferences dump/restore implementation and not the canonical SAF-backed `ArvinBackupService`; this removal does not change canonical backup format or restore flow.
- `lib/dropbox_cloud_backup_provider.dart` and `lib/dropbox_cloud_backup_provider_v2.dart` were consolidated into one canonical `DropboxCloudBackupProvider` at `lib/dropbox_cloud_backup_provider.dart`. The injectable V2 HTTP seam and tests are retained; the V2-suffixed duplicate file/class is removed. Exact in-repo search found no other V2 callers.
- The repository contains 21 GitHub workflow files, including several factory/orchestrator/queue/production-loop workflows. No workflow is to be deleted until trigger overlap, `workflow_run`/dispatch callers, branch filters, release gates and active-run dependencies are mapped.
- A pre-existing `chore/whole-codebase-cleanup-20260930` branch is diverged and 290 commits behind current `main`; it is not a safe base for cleanup.

## Required next passes

1. Inventory Dart imports and symbol references for all source files; distinguish dead code from plugin/reflection/entrypoint use.
2. Consolidate duplicate implementations in small, testable changes; retain canonical Task/storage/backup/calendar owners.
3. Audit workflow triggers and callers before removing redundant workflows.
4. Merge unique UI-reference requirements into the canonical UI contract, update the authority index, then delete proven redundant docs.
5. Refresh stale historical status snapshots so they cannot masquerade as live state.
6. Run exact-head Analyze, all test shards, Debug/Release APK, and relevant Device Smoke. No cleanup is complete until evidence is attached.

## Guardrails

- No direct changes to `main`.
- No deletion based on filename/date/size alone.
- No changes to schema, migrations, backup format, restore behavior or Task ownership as incidental cleanup.
- Keep release NO-GO until existing physical-device acceptance gates pass.
