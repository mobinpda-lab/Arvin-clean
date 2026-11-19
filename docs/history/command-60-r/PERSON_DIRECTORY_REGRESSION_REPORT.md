# PERSON DIRECTORY REGRESSION REPORT — COMMAND 60-R.1
**Observed:** 2026-11-19 / ۲۸ آبان ۱۴۰۵
**Status:** IN PROGRESS / NOT ACCEPTED
**Canonical integration SHA:** `6d806125e91056fedb74b0644d77a273ee4b675f`
**Candidate fix PR:** #3549 — `ce9ce1d755ae994d1f2567285304dc23b07aa823`

## 1. Domain distinction
- `people` is the active reusable Person Directory. Removing a row here is a directory-membership operation.
- `task_people` and `follow_up_people` are historical Task/Follow-up identity relations. Removing a directory entry must not delete these rows, IDs, Task snapshots, Follow-up IDs or `personIds`.
- A historical Person reference is not evidence that the owner still wants the person in the active directory.

## 2. PR #3549 implementation review
The candidate adds `person_directory_exclusions` with a version marker `person_directory_exclusions_v1`.
- `G1PersonDirectoryExclusionV1Migration` creates the table transactionally and rejects an inconsistent marker/table state.
- `migrateTaskPeople` skips IDs recorded in the exclusion table.
- `TaskStore.savePeopleDirectory` records IDs removed from the current directory as exclusions, clears an exclusion only when that same ID is explicitly re-added, and leaves Task/Follow-up relation tables intact.
- Re-adding the same Person ID is explicit and does not create a new identity.
- The implementation is additive; it does not delete historical relation rows to satisfy the test.

## 3. File-backed evidence
PR #3549 adds `test/person_directory_exclusion_migration_test.dart` using `NativeDatabase(file)`.
The test writes a Person, Task and Follow-up; removes only the directory entry; verifies Task and Follow-up history; closes the database; reopens a fresh executor; installs the schema twice; verifies the exclusion; re-adds the same ID; closes and reopens again; and checks SQLite integrity and foreign keys.

## 4. Acceptance gaps
The candidate test does not yet prove all required cases:
1. Explicit SQL count assertions for `task_people` and `follow_up_people` after repeated migration, proving no duplicate relation rows.
2. A dedicated portable Backup → fresh database Restore test for a removed directory entry with historical Task and Follow-up references.
3. Rollback/failure injection during Restore, proving the exclusion and history remain consistent.
4. Compatibility behavior for an older backup without `peopleDirectory` must be explicit; absence of that field cannot be treated as proof that a person was intentionally deleted.
5. Verify the exact lifecycle in the canonical PR #3495 branch after the candidate code is adapted.

## 5. Branch safety
PR #3549 is not a safe direct merge/cherry-pick candidate: relative to canonical SHA `6d806125e91056fedb74b0644d77a273ee4b675f`, its head is 8 commits ahead and 30 behind (DIVERGED). The canonical branch does not yet contain `G1PersonDirectoryExclusionV1Migration` or the exclusion table. Port only the reviewed minimal change onto PR #3495, preserving later canonical work.

## 6. Decision
- Historical Task and Follow-up data: MUST PRESERVE.
- Directory removal: MUST remain effective after reopen and migration.
- Same-ID re-add: MUST explicitly clear the exclusion.
- Backup/Restore: NOT VERIFIED.
- Product acceptance: NOT ACCEPTED until the gaps above pass on one exact canonical SHA.
