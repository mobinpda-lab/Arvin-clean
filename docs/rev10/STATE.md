# REV10 — execution state
Snapshot source SHA before this documentation batch: `dddbac90fbc51f55ddf5f1ae3ac1be20ded1eed1`. Main baseline: `45e4202b03a434459e4c021a04efa7e8396359db`. PR #3495 OPEN / DRAFT / UNMERGED; branch `recovery-02/main-based-integration`. Mission 162-R. Merge NOT AUTHORIZED; Release NO-GO; Deployment NOT AUTHORIZED.
## Active work
- Home: page-owned completion callback added so widget tests can await the one initState Store load, not duplicate loads.
- Center: same page-owned load completion synchronization added; duplicate Store loads removed from helper.
- Backup encryption UX: completion callback added; test awaits actual asynchronous backup pipeline rather than pumpAndSettle during SQLite Futures.
- All three changes require exact-SHA CI confirmation; implementation is not acceptance.
## Previous exact-SHA evidence (878fb6363d1436b7a253f3b62b9213bd502151d6)
- Build 44990999360 FAILURE: Analyze and Debug/Release APK passed; all six test shards failed.
- Device Smoke 44990999375 SUCCESS (workflow/emulator only; not Galaxy A52s acceptance).
- Follow-up Persistence 44990999366 SUCCESS; Governance 44990999456 SUCCESS.
- COMMAND 20-E 44990999411 FAILURE at aggregate evidence gate; storage-persistence phase passed.
- Zero Dollar Smoke 44990996056 SUCCESS.
These results do not transfer to later SHAs.
## Blockers / next actions
1. Poll exact-SHA Build, six shards, Device Smoke, Follow-up Persistence and COMMAND 20-E after lifecycle fixes.
2. Resolve any remaining failures from job logs; do not infer a fix from source changes alone.
3. Continue Task/Center selectors/detail/Quick Capture and Home fifth filter with real SQLite.
4. Prove independent file-backed Backup A→B, repeat restore, rollback and destination preservation.
5. Slice-0 remains NOT ACCEPTED. Galaxy A52s physical evidence is BLOCKED until available.


## MASTER EXECUTION 165-R — live audit checkpoint (2026-11-22, Asia/Tehran)

**Live refs verified before this documentation commit:**
- Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db` (read-only; unchanged).
- Canonical branch / PR #3495 HEAD: `b303d8e2b45e0d06c08a901ebea4895d3546ad46`.
- PR #3495: OPEN / DRAFT / UNMERGED; base `main`; mergeable reported true. No merge or release authorization.
- Issue #3667: OPEN; Build failure feedback for the same canonical SHA.

**Exact-SHA CI evidence on `b303d8e2b45e0d06c08a901ebea4895d3546ad46`:**
- Build `45003209585`: FAILURE. Analyze job `137149100129`: SUCCESS. Debug APK job `137149099775`: SUCCESS; artifact `14747215094`. Release APK job `137149100063`: SUCCESS; artifact `14746549284`.
- Test shards: shard 0 `137149100070` FAILURE; shard 1 `137149100053` SUCCESS; shard 2 `137149099936` FAILURE; shard 3 `137149099986` FAILURE; shard 4 `137149100001` SUCCESS; shard 5 `137149099977` FAILURE.
- Failure logs confirm Center Management widget-test timeouts after 10 minutes: shard 0, `creates a Center and archives/restores without deleting it`; shard 2, `shows related Project names in Center details` and `manages Center to Project links through the existing store`; shard 3, `shows related Project names in Center details`; shard 5, `manages Center to Project links through the existing store`. Do not increase timeout or weaken assertions without a demonstrated cause.
- Device Smoke `45003209662`: SUCCESS; seven selected scenario jobs (backup-restore, sql-persistence, home, sql-migration, calendar, people, quick-capture) all report SUCCESS. This is CI/emulator evidence, not Galaxy A52s physical-device acceptance.
- Follow-up File Persistence `45003209555`: SUCCESS.
- COMMAND 20-E `45003209567`: FAILURE. Storage-persistence phase job `137149034925`: SUCCESS, including file-backed ProjectStore and process stop/fresh-process read. Final evidence gate job `137150826974`: FAILURE at `jq -e '.overall == "PASS"' regression_summary.json`; aggregate acceptance is not met. Evidence artifacts: `14747057913` and `14745984481`.
- Governance Validation `45003209575`: SUCCESS.

**Source audit — Center lifecycle:**
- `CenterManagementPage._load` awaits `CenterStore.load`, then separately awaits `ProjectStore.load`, then launches per-Center `projectIdsForCenter` calls with `Future.wait`.
- `CenterStore._ensureReady` itself calls `G1DriftSchema.install` and `ProjectStore.load`; `ProjectStore._ensureReady` calls `TaskStore.load`. Each `projectIdsForCenter` re-enters `CenterStore._ensureReady`.
- This confirms repeated readiness/Store initialization in the Center page path. It is a concrete investigation target, but the precise deadlock/timeout root cause is **NOT YET PROVEN**. No timeout change or test assertion change is authorized.

**Home / Backup:** page-owned completion callbacks and the corresponding test wait paths are present in the current source. Their targeted test outcomes have not yet been separately extracted from the shard logs in this checkpoint; do not mark them individually PASS based only on source presence.

**Execution disposition:** no source fix, test execution from a local Flutter/Dart environment, or new acceptance is claimed in this checkpoint. Continue with isolated reproduction and focused Center lifecycle correction on this canonical branch. Keep Slice-0, full Database A→B restore, and Galaxy A52s physical acceptance NOT ACCEPTED / BLOCKED until their own evidence exists. Main remains untouched; merge/release/deployment remain unauthorized.
