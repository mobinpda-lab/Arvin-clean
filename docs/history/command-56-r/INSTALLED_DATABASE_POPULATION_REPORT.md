# Installed Database Population Report

**Status: BLOCKED — no production inventory source available**  
**Audit date:** 2026-11-18

## What repository evidence tells us
- Main source currently declares G1 Schema V7.
- Main TaskStore installs that schema and checks the `legacy_tasks_migrated` marker. If absent, it imports `arvin.tasks` from SharedPreferences through `SqlTaskMigrationWriter`.
- V19 and V20 exist as open draft PR candidates only; neither is merged.
- Two GitHub release records are draft prereleases, marked unapproved, and have no APK/AAB asset. Their only assets are checksum and evidence text files, both with zero downloads.
- The repository tags predate the V19 candidate source snapshot.
- A V7 fixture was physically upgraded to V19 in COMMAND 48-R. This is test-fixture evidence, not installed-user evidence.

## Population status matrix
| Population | Evidence available | Status |
|---|---|---|
| New installs running current Main | Main schema v7 source | Source-level only |
| Existing users with SharedPreferences tasks | Main TaskStore importer source | Existence/path evidenced; population count unknown |
| Users with V7 G1 SQLite | Main schema and fixture evidence | Real user count unknown |
| Users with intermediate schemas | No device inventory | UNKNOWN |
| Users with V19 | No production artifact/store rollout evidence found | NOT EVIDENCED / UNKNOWN |
| Users with V20 | PR #3463 unmerged; no release evidence | NOT EVIDENCED / UNKNOWN |
| Mixed Legacy JSON + SQL | Source supports migration transition; no real population sample | UNKNOWN |
| Partial / ambiguous databases | No device inventory | UNKNOWN |

## Required evidence to unblock
1. Google Play Console release tracks, version codes, rollout dates and artifact hashes.
2. Signed APK/AAB provenance for every distributed build.
3. Crash-free / upgrade telemetry or an opt-in anonymized schema census.
4. A privacy-safe, read-only inventory from real installations: schema fingerprint, table/column presence, migration markers, Legacy key presence, counts and backup provenance. Do not collect task text or personal payloads.
5. Explicit separation of production, internal testing, sideload and development installations.

No personal database should be uploaded or used as a test fixture. The inventory must be consented, minimized and privacy-preserving.
