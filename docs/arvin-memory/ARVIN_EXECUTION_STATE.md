# Arvin Execution State

Updated: 2026-10-11
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access this run: Read/Write
Source of truth: live GitHub; this file is a resumable checkpoint, not a substitute for rechecking live refs and runs.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.**

## Current GitHub reality
- Main at latest inspection: `72a2f4cc24df7a38eff9856ce403461615db5280` (PCTADP documentation/decision commit).
- Backup/restore PR #2585 is OPEN / NOT MERGED. New head: `05c080e706690dd3eb6a96fc5c070971a43d1354`.
- New code commit: [05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354).
- Exact-head Build run [38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036) was in progress at checkpoint; do not claim it passed.
- Exact-head Android Device Smoke run [38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041) was queued/in progress at checkpoint; do not claim it passed.
- Prior checkpoint `07b571057c4682128d78ab2c1f39e85890041713` had successful Analyze, six test shards, Debug/Release builds and six emulator smoke lanes, but that is historical evidence after the head moved.
- Memory documentation PR #2600 is OPEN / DRAFT: https://github.com/mobinpda-lab/Arvin-clean/pull/2600.

## Completed / evidenced this session
- Inspected live main, PR #2585, current code and existing restore tests.
- Found that both restore entry points could leave newly merged Category/Tag catalog entries behind if a later failure occurred after catalog merge.
- Added pre-restore catalog snapshots, rollback cleanup for newly introduced entries, and failure-injection seams/tests for Home and BackupPage.
- Recorded the finding and validation gate on PR #2585: https://github.com/mobinpda-lab/Arvin-clean/pull/2585#issuecomment-6106998968.
- Added/maintained seven persistent memory files on the draft memory PR.

## In progress
- Exact-head CI for commit `05c080e`.
- Product ontology audit: [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580).
- Backup/restore catalog preservation: [Issue #2584](https://github.com/mobinpda-lab/Arvin-clean/issues/2584).

## Blocked / unproven
- No physical Android device + actual file-picker/provider backup/restore evidence.
- No verified Calendar event identity/no-duplicate test after restore.
- No final Golden Flow acceptance.
- PR #2585 must not merge until fresh exact-head CI passes and all product acceptance gates are reviewed.

## Next action
1. Check completion/results for Build #38123874036 and Device Smoke #38123874041 on exact head `05c080e`.
2. Fix any compile/test failure; do not rely on older checkpoint green runs.
3. If green, proceed to physical-device/file-provider restore and Calendar event identity acceptance.
4. Continue #2580 as a parallel read-only/documentation audit only where it does not alter restore semantics.
5. Recheck and record PR head/main base before any merge decision.

## Risks
Partial restore; loss of unassigned Category/Tag values; Project, settings, recurrence/history or Calendar-link loss; duplicate external Calendar events; treating emulator CI as device acceptance.
