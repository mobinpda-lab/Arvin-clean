# Arvin Execution State

Updated: 2026-10-11
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write
Authority: live GitHub refs, code, tests and exact-head workflow evidence. This file is a continuation checkpoint.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.**

## Current GitHub reality
- `main`: `72a2f4cc24df7a38eff9856ce403461615db5280`.
- Backup/restore PR [#2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) is OPEN / NOT MERGED; head `05c080e706690dd3eb6a96fc5c070971a43d1354`; base `34a6cee9ae05ad1cf632960b96e98f2a5448e128`. The PR base is behind current main and must be reconciled/rechecked before merge.
- Memory PR [#2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600) is OPEN / DRAFT; head `c767560f2f86f28c26764d1afbee4a5d39049c1e`; base is current main `72a2f4cc24df7a38eff9856ce403461615db5280`.
- Exact-head Build [#38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036): still IN_PROGRESS at latest check. Analyze passed; test shards 1, 3, 4, 5 passed; shards 0 and 2 were still running; Debug and Release APK jobs were still running.
- Exact-head Device Smoke [#38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041): still IN_PROGRESS/QUEUED at latest check. Home and Quick Capture were running; backup/restore, people, SQL migration and SQL persistence were queued.
- Exact-head Production Loop [#38123874039], Orchestrator [#38123874049], Orchestrator PR Wakeup [#38123874082] and G1 lock sync [#38123874063] completed successfully. These do not substitute for Build/test/device acceptance.
- Previous green checkpoint `07b571057c4682128d78ab2c1f39e85890041713` is historical and does not prove current head.

## Completed
- Rechecked execution state, current main, PR #2585, PR #2600, Issues #2580/#2584, current patch and exact-head workflows.
- Found restore rollback omitted cleanup for newly merged Category/Tag catalog values if a later stage failed.
- Committed fix and failure-injection coverage in [05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354): pre-restore catalog snapshots, rollback cleanup of only newly introduced values, and injected failure tests in Home and BackupPage.
- Posted evidence and validation gates to [PR #2585 discussion](https://github.com/mobinpda-lab/Arvin-clean/pull/2585#issuecomment-6106998968).
- Updated the durable memory PR to include all six required v8 memory documents plus user experience log; added the missing Project Knowledge and Evidence Map files in this checkpoint.

## In Progress
- Exact-head Build and Android emulator smoke for `05c080e`.
- Product taxonomy consistency audit [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580).
- Backup/restore catalog preservation [Issue #2584](https://github.com/mobinpda-lab/Arvin-clean/issues/2584).

## Blocked / unproven
- No physical Android device + actual system file picker/provider backup/restore evidence.
- No verified Calendar external-event identity/no-duplicate test after restore.
- No full Golden Flow evidence.
- PR #2585 base is behind current main; do not merge before understanding/reconciling that difference.
- Current code fix is not yet fully validated until exact-head tests/builds/smoke finish successfully.

## Next Action
1. Recheck the final conclusion for Build #38123874036 and Device Smoke #38123874041 on exact head `05c080e`.
2. Fix any failing shard/job; rerun all required checks after any code change.
3. Reconcile PR #2585 with current main safely; review diff and conflicts, no blind force push.
4. After CI passes, run physical-device/file-provider restore and Calendar event identity/no-duplicate acceptance.
5. Continue #2580 read-only/documentation audit in parallel where it does not change restore semantics.
6. Before release, complete Golden Flow, known issues, install/user guide, release notes and evidence report.

## Current Bottleneck
**Exact-head backup/restore validation**, followed by real-device/file-provider acceptance and Calendar identity proof.

## Risks
Partial restore; loss of unassigned Category/Tag values; Task/Project/settings/repeat/history/Calendar-link loss; duplicate external Calendar events; stale PR base; confusing emulator success with physical-device acceptance.
