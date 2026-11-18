# COMMAND-52-R-ACCEPTANCE
## Occurrence Idempotency Root Cause Investigation

**Repository:** mobinpda-lab/Arvin-clean  
**Canonical SHA:** 010cdfa016cd3884b9bea7eaf18b068620d4e980  
**Historical V19 commit:** 310c0e20e3447c488c1e1c102c38bea5040708ca  
**Test branch / SHA:** test/command-51-r-phase2-idempotency / 9847bb7b226709db592624c58ec5ea6b6eddf06e  
**Failed run:** 44377193111  
**Artifact:** 14461354012  
**Artifact ZIP SHA-256:** 063c4107b18f29010b8bdfc92accff6843b272343dbabb8a0f4ab2687ddc889

## 1. Executive decision

**Idempotency root cause: CONFIRMED from source + physical artifact.**  
**Explicit NULL Fidelity: CODE-PATH DEFECT CONFIRMED; independent physical round-trip: NOT RUN / INCONCLUSIVE.**  
**Unknown Occurrence Field Preservation: CODE-PATH DEFECT CONFIRMED; independent physical round-trip: NOT RUN / INCONCLUSIVE.**

The second V19 install reads the post-migration legacy_payload_json, in which occurrenceHistory and checklistOccurrences have already been removed. It therefore constructs empty expected maps, does not delete the existing SQL rows, reads those existing rows back, and compares non-empty SQL history with empty legacy history. The comparison fails for task c50-matrix-a.

No source code, historical Installer, canonical branch, Main, or original Fixture was modified. This investigation branch contains this report only.

## 2. Evidence inventory

The downloaded artifact contains 21 files. Relevant entries:
- snapshot-before-first-install.sqlite — 106,496 bytes
- snapshot-after-first-install.sqlite — 282,624 bytes
- snapshot-after-second-install-attempt.sqlite — 282,624 bytes
- command50-source-occurrences.json
- command50-first-install-sql.json
- command50-retry-sql.json
- command50-taskstore-readback.json
- command50-retry-error.txt
- command50-retry-integrity.json
- explicit-null.sqlite
- unknown-occurrence-field.sqlite
- flutter-test.log
- exit-code.txt
- evidence-sha256.txt
- command51-source-identity.txt

Artifact ZIP hash was independently recomputed from the downloaded file and matches the value above.

### Key source identities
- V19 schema blob: 9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21
- Occurrence codec blob: ae9fb8548fa57a8a3a48e1faa2e98a44e636003e
- Recurrence codec blob: 29ee7c0c778d99135daf376ba19f7773e4760ce4
- Task model blob: 328c402318878717d9165bccf8303fa6674321bf
- TaskStore blob: 625f7b24523e621adba7ae7a59e4c3e13c272a09

## 3. Root Cause Report

### 3.1 Historical code path

In lib/services/g1_drift_schema.dart at historical V19:
- The schema installation opens a transaction at approximately line 110.
- It calls OccurrenceSqlCodec.migrateLegacyEnvelopes(executor) at line 242 on every schema installation.
- The transaction commits at approximately line 267.

In lib/services/occurrence_sql_codec.dart:
- migrateLegacyEnvelopes begins at line 122.
- It reads legacy_payload_json for every task.
- It obtains rawHistory and rawChecklists from the decoded envelope around lines 136–137.
- It initializes empty maps and populates them only when those legacy keys are present.
- It calls writeTask around line 175.
- It reads SQL state back around line 176.
- It compares SQL readback with the maps derived from the legacy envelope.
- It removes the legacy keys from the envelope around lines 181–184, after parity succeeds.

### 3.2 First install

Before installation, task c50-matrix-a has three entries in occurrenceHistory and one checklist occurrence in checklistOccurrences.

The migration writes three rows to task_occurrences, preserves the checklist rows, verifies parity, then removes the two legacy keys from legacy_payload_json.

The first-install transaction commits. The resulting database therefore has three SQL occurrence rows for c50-matrix-a, no occurrenceHistory key in that task's legacy JSON envelope, and no checklistOccurrences key in that task's legacy JSON envelope.

### 3.3 Second install — exact failure chain

1. The schema installer calls migrateLegacyEnvelopes again.
2. The task still has a non-empty legacy_payload_json, so it is processed.
3. The two occurrence legacy keys are absent because the first successful migration removed them.
4. The codec initializes history = {} and checklists = {}.
5. writeTask receives an empty occurrence history and empty checklist map. Its loops do not delete or replace existing SQL rows.
6. readTask reads the three existing SQL rows.
7. The parity comparison compares non-empty restored SQL history against the empty expected history.
8. The codec throws Occurrence migration parity mismatch for Task c50-matrix-a.

This is not a duplicate-row failure. It is a false parity failure caused by treating absence of legacy occurrence keys as an empty expected occurrence history, rather than recognizing that the occurrence payload has already been migrated or was never present.

### 3.4 Why SQL rows remain

writeTask is additive/reconciliation-oriented: it inserts a row when the deterministic occurrence does not exist; validates an existing row and throws on identity/content conflict; and does not delete existing occurrence rows when the input map is empty.

Therefore SQL rows remain after the second attempt. The surrounding V19 schema installation is transactional; the observed after-attempt snapshot is byte-identical to the after-first-install snapshot.

### 3.5 Is prior successful migration detectable?

The current occurrence migration function does not consult or write an occurrence-specific completion receipt. It also does not branch on the absence of both legacy keys before running parity.

The database does contain the generic legacy_tasks_migrated=1 metadata entry after first install, but the inspected OccurrenceSqlCodec does not use that entry to determine occurrence migration state. It is not an occurrence-specific proof by itself.

For this captured database, evidence of completed first migration is strong: the original legacy keys are absent, corresponding SQL rows exist, and the first-install artifact records successful completion. For arbitrary databases, absence of those keys alone cannot reconstruct deleted source values or prove semantic equality if SQL rows have been independently altered.

## 4. Evidence Matrix

| Claim | Evidence | Assessment |
|---|---|---|
| First install writes occurrence rows | First-install SQL JSON and SQLite snapshot | CONFIRMED |
| First install removes legacy occurrence keys | Before/after task JSON | CONFIRMED |
| Second install builds empty expected maps | Historical codec control flow + absent keys in snapshot | CONFIRMED |
| SQL rows remain after retry | Retry SQL JSON and SQLite snapshot | CONFIRMED |
| Retry fails at parity for c50-matrix-a | Flutter log and retry-error file | CONFIRMED |
| No duplicate rows were added by failed retry | Before/after retry SQL and identical snapshots | CONFIRMED |
| SQLite structural integrity remains valid | retry-integrity JSON: ok | CONFIRMED |
| Foreign-key check remains clean | retry-integrity JSON: zero violations | CONFIRMED |
| Explicit NULL round-trip preserves key presence | No dedicated round-trip was run | INCONCLUSIVE |
| Unknown nested occurrence fields round-trip | No dedicated round-trip was run | INCONCLUSIVE |

## 5. SQL Before / After

### 5.1 Before first installation

The V7 source database has no task_occurrences table. Task c50-matrix-a stores three occurrence-history entries inside tasks.legacy_payload_json.

### 5.2 After first installation

For c50-matrix-a, task_occurrences contains exactly three rows:

| ordinal | scheduled_at | status | completed_at | result |
|---:|---|---|---|---|
| 0 | 2026-11-01T08:00:00.000Z | pending | NULL | NULL |
| 1 | 2026-11-02T08:00:00.000Z | completed | 2026-11-02T08:10:00.000Z | done |
| 2 | 2026-11-03T08:00:00.000Z | cancelled | NULL | NULL |

The first-install SQL evidence contains 8 occurrence rows across the four fixture tasks.

### 5.3 After failed second installation

The same three rows remain for c50-matrix-a. The retry SQL JSON reports the same IDs, task IDs, scheduled timestamps, statuses, and ordinals. No additional rows are present.

### 5.4 Snapshot comparison

| Snapshot | Bytes | SHA-256 |
|---|---:|---|
| Before first install | 106,496 | 7e0b1fb815389ec35c96893233382d8d40faab6647fe93044932a685b06cded4 |
| After first install | 282,624 | 5bcb71bd0f4895a6ee011133b018a81a985121d3eda171c575f7a11daeee9062 |
| After second attempt | 282,624 | 5bcb71bd0f4895a6ee011133b018a81a985121d3eda171c575f7a11daeee9062 |

The post-first-install and post-failed-retry snapshots are byte-for-byte identical.

## 6. JSON Before / After

### Before first installation

For c50-matrix-a, source JSON contains occurrenceHistory with three entries and checklistOccurrences with the values pack and snack. The task-level legacyCustomField value is preserve-me.

### After first installation

The two migrated keys are absent. The task JSON still contains legacyCustomField and the other task compatibility fields. The occurrence data is read back from SQL by TaskStore, not from the legacy JSON envelope.

The after-first-install and after-second-attempt JSON payloads are identical. This is consistent with the identical SQLite snapshots.

## 7. Three Defect Assessments

### 7.1 Idempotency

**Root cause: CONFIRMED.**

The migration always attempts parity against legacy envelope maps even after those maps have been retired. Existing SQL rows are preserved, but the expected source becomes empty. The migration therefore rejects its own successfully migrated state.

### 7.2 Explicit NULL Fidelity

**Code-path defect: CONFIRMED. Physical round-trip: INCONCLUSIVE.**

Historical codec lines 39–40 pass nullable values from state['completionDate'] and state['result'] into SQL. Historical codec lines 99–100 reconstruct those keys only when the SQL value is non-NULL.

Consequently, the codec cannot distinguish a key absent in source JSON from a key present with explicit JSON null. Both become SQL NULL, and the read path omits the key. The artifact contains explicit-null.sqlite with a source row having both keys explicitly set to null, but the phase-2 test stopped at the earlier Idempotency failure. No round-trip was run against that database. No physical PASS or measured loss is claimed.

### 7.3 Unknown Occurrence Field Preservation

**Code-path defect: CONFIRMED. Physical round-trip: INCONCLUSIVE.**

The historical writer reads only the known fields status, completionDate, and result from each occurrence map. The reader reconstructs only scheduledDate, status, and the two optional completion fields. There is no opaque per-occurrence payload in the historical SQL schema.

An unknown nested field such as futureField is therefore not represented by the current writer/reader contract. The artifact contains unknown-occurrence-field.sqlite, but no round-trip was executed against it because the earlier test stopped. Preservation of unknown fields is not marked PASS.

## 8. Proposed Patch — design only, not applied

No source patch was created or applied. The following is a design proposal for a separately reviewed implementation.

### A. Idempotency and conflict safety

1. Distinguish field absence from an empty map using containsKey for both legacy occurrence keys.
2. If one or both legacy keys are present, decode and validate them, reconcile every expected occurrence and checklist row, then compare complete canonical SQL state.
3. Only after parity succeeds, remove the migrated legacy keys and write a per-task occurrence migration receipt in the same outer SQLite transaction.
4. If both legacy keys are absent, do not compare existing canonical SQL rows with empty maps. Treat SQL as the canonical store for that task, validate row identity/uniqueness/foreign keys, and perform a no-op. This is required for already migrated tasks and tasks whose legacy payload never contained occurrence history.
5. If legacy keys are present and any SQL identity or content differs, fail closed. Do not use INSERT OR IGNORE to conceal a conflict, do not overwrite canonical data, and do not delete unmatched rows as a shortcut.
6. A receipt must be written only after full parity. It must not be used to bypass validation when legacy source keys are still present.

### B. Explicit NULL preservation

Add explicit presence metadata for nullable occurrence properties, for example completion_date_present INTEGER NOT NULL DEFAULT 0 and result_present INTEGER NOT NULL DEFAULT 0.

Writer semantics: absent key means presence bit 0; explicit JSON null means presence bit 1 and SQL value NULL; concrete value means presence bit 1 and SQL value.

Reader semantics: include a JSON key whenever its presence bit is 1, even if its SQL value is NULL.

Any schema upgrade/backfill must state that already-migrated rows with SQL NULL cannot reveal whether the original key was absent or explicitly null. Do not invent historical presence values.

### C. Unknown field preservation

Add an opaque per-occurrence JSON payload, e.g. extra_json TEXT NOT NULL DEFAULT '{}', or an equivalently lossless extension store.

- Store all non-reserved occurrence keys, including nested maps, lists and explicit nulls.
- Reconstruct those keys during readback.
- Reserve and validate canonical keys such as scheduledDate and status.
- Compare canonicalized extension JSON during parity checks.
- Never silently discard malformed extension JSON or unknown keys.

### D. Transaction and retry contract

- Keep row writes, source-key retirement, and migration receipt atomic.
- Retry after close/reopen must be a no-op with byte-stable logical data.
- Conflicting pre-existing SQL rows must raise an explicit conflict.
- Rollback must restore both source envelope and SQL tables if any validation or write fails.

## 9. Regression Test Plan

All tests must use disposable copies of the original fixture or purpose-built disposable SQLite databases. No test may use the user's live database.

1. First install: exact occurrence IDs, rows, ordering, statuses, checklist items and source retirement.
2. Close/reopen, second install: success, no row-count or content changes.
3. Close/reopen, third install: success, same logical snapshot.
4. Empty legacy history + existing canonical SQL rows: no-op, preserve all rows.
5. Legacy source + matching SQL rows: accept exact match.
6. Legacy source + conflicting SQL status, timestamp, ID, ordinal or checklist: fail closed and rollback.
7. Explicit NULL matrix: absent, explicit null, and concrete value for both nullable properties.
8. Unknown-field matrix: scalar, nested object, list, null and nested null; preserve through close/reopen.
9. Failure injection before SQL writes, after partial writes, before parity, and before source retirement: full rollback.
10. SQLite integrity_check, foreign_key_check, snapshot comparison and deterministic artifact hashes.
11. Verify migration receipt is written only after parity and cannot mask a later real conflict.
12. Verify pre-existing V19 databases without the new receipt are handled through an explicit, conservative compatibility path; if their state cannot be proven, fail closed rather than guessing.

For every test record full log, exit code, before/after snapshots, SQL rows, JSON payload, SHA-256 and a separate artifact. Do not weaken or delete existing tests.

## 10. Limits and acceptance status

- Idempotency root cause: CONFIRMED.
- Explicit NULL: code-path defect confirmed; physical test not run.
- Unknown occurrence fields: code-path defect confirmed; physical test not run.
- Proposed patch: design only.
- Patch implementation: NOT STARTED.
- Historical V19 Installer: UNCHANGED.
- Original Fixture: UNCHANGED.
- Main: UNCHANGED.
- Canonical branch: UNCHANGED.
- Canonical PR: UNCHANGED.
- Merge / Release / Deploy / V20: NOT STARTED.

**COMMAND 52-R decision:** Root cause of the second-install failure is established. The two additional preservation defects are established by code inspection but remain physically unverified. No implementation is authorized by this report.