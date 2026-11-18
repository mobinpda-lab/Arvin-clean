# Migration Path Recommendation

**Recommendation only — Product Owner approval required.**

## Current proven state
Main is V7 and imports the Legacy SharedPreferences task list into SQL when `legacy_tasks_migrated` is absent. V19 and V20 are unmerged candidate PRs. The V19 fixture run passed only the tested V7 fixture with no Occurrence rows. The later V19 forensic run confirmed a retry mismatch and explicit NULL / unknown Occurrence-state parity failures. V20 is owned by the M2M hierarchy candidate.

## Recommended route
1. Keep Main V7 untouched until a release baseline is approved.
2. Keep the historical V19 commit immutable; do not claim it is production-installed.
3. Reserve schema V20 for the already-designed M2M hierarchy migration, but do not accept/release the current candidate solely because its focused workflow passed.
4. Design one coordinated forward-upgrade coordinator with a single target after M2M (provisionally V21). Its V7 path must preserve and validate Occurrence source before any operation that retires Legacy keys. It must not blindly run the current V19 Occurrence path on data with known parity hazards.
5. For V19 databases, reconcile only when source keys remain or trusted source snapshot / migration receipt exists. If keys are absent and no receipt exists, stop and require backup recovery.
6. For V20 databases, validate the M2M marker and relations before applying the Occurrence repair step. Do not repeat M2M writes.
7. For intermediate versions, require a separately documented predecessor adapter per exact schema fingerprint.
8. Release only after isolated physical fixture tests, full backup/restore, fault injection, TaskStore reopen, ID/relationship parity, device upgrade tests and independent acceptance.

## Prohibited shortcuts
- No direct V7→V20 jump based only on a version number.
- No assumption that all users have V19.
- No acceptance of missing Legacy keys as an empty Occurrence history.
- No INSERT OR IGNORE or silent conflict suppression in data-preservation logic.
- No destructive source-key deletion until a receipt and independent readback prove the target.
- No Phase A authorization from this recommendation.
