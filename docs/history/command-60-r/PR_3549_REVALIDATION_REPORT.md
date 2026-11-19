# PR #3549 REVALIDATION REPORT — COMMAND 60-R.1
**Observed:** 2026-11-19 / ۲۸ آبان ۱۴۰۵
**PR:** #3549 — OPEN / DRAFT / UNMERGED
**Exact tested head:** `ce9ce1d755ae994d1f2567285304dc23b07aa823`
**Build run:** `44418907693`
**Device Smoke run:** `44418907517`
**Follow-up File Persistence run:** `44418907531`

## Exact-SHA CI
| Gate | Result |
|---|---|
| Analyze | PASS |
| Test Shards 0–5 | PASS |
| Debug APK | PASS |
| Release APK | PASS |
| Device Smoke | PASS — seven emulator scenarios |
| Follow-up File Persistence | PASS |

## Reviewed scope
- Adds marker-versioned Person Directory exclusion persistence.
- Prevents repeated `migrateTaskPeople` from restoring explicitly excluded IDs.
- Preserves Task and Follow-up historical references.
- Supports explicit re-add of the same Person ID.
- Adds a file-backed SQLite close/reopen test.
- Adds a separate Schema 9 occurrence/checklist persistence test.

## Remaining acceptance gaps
- No dedicated Backup → fresh database Restore regression proving a removed Person remains absent while historical Task/Follow-up references survive.
- No explicit SQL count assertion for duplicate `task_people` and `follow_up_people` rows across repeated installs.
- Device Smoke is emulator evidence, not physical-device acceptance.
- PR head is DIVERGED from canonical PR #3495: 8 commits ahead / 30 behind. Direct merge or blind cherry-pick is prohibited.

## Decision
**CI PASS ON THIS SHA; PRODUCT ACCEPTANCE NOT YET.** Preserve this evidence. Integrate only the reviewed minimal change through canonical PR #3495 and repeat all required tests on the resulting exact SHA.
