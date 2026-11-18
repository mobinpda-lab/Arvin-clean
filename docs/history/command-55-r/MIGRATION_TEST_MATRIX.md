# Migration Test Matrix — Future Physical Acceptance

**Status:** DESIGN ONLY. No tests in this document have been executed. No PASS is claimed.

Each test uses a disposable file-backed SQLite fixture, a stable fixture ID, and a fresh independent copy. Capture raw source, pre/post SQL snapshots, schema inventory, receipt, quick_check, foreign_key_check, TaskStore readback and test-run logs.

| ID | Fixture / initial state | Operation | Expected result | Snapshot / PASS evidence | FAIL |
|---|---|---|---|---|---|
| T01 | Healthy V19; source present; target empty | migrate once | exact copy and receipt | all IDs/fields/hash parity; reopen; receipt | any loss or mismatch |
| T02 | V19 non-empty history + checklist | migrate | all ordered rows preserved | occurrence/checklist snapshots | missing/reordered row |
| T03 | V19 Task without occurrence data; source key explicitly absent | preflight | presence state preserved; no fabricated occurrence | raw envelope + target snapshot | defaults fabricate state |
| T04 | Migration already committed with valid receipt | run twice | ALREADY_APPLIED, no writes | identical DB fingerprint | any mutation |
| T05 | Same as T04 | run three times | same stable state | fingerprints after each run equal | drift/duplicates |
| T06 | source state lacks completionDate | migrate | present=0,value=NULL | JSON readback omits key | key emitted as null |
| T07 | source completionDate:null | migrate | present=1,value=NULL | JSON readback includes null | key omitted |
| T08 | source completionDate:string | migrate | present=1,value=value | exact round-trip | changed value |
| T09 | simple unknown string/bool/number | migrate | all preserved | unknown_fields_json and readback | missing/type coercion |
| T10 | nested unknown map/list | migrate | recursive structure preserved | semantic + raw hashes | flattening/loss |
| T11 | unknown key with null | migrate | key remains present with null | containsKey check | omitted key |
| T12 | duplicate Occurrence ID/natural key conflict | migrate | hard failure + rollback | before/after snapshots identical | overwrite/ignore |
| T13 | matching destination row exists | reconcile | exact match only; no duplicate | row equality and count | duplicate or blind upsert |
| T14 | malformed/incomplete legacy envelope | migrate | reject and rollback | source intact; no receipt | partial success |
| T15 | inject failure after DDL | migrate | rollback DDL | schema snapshot unchanged | DDL remains |
| T16 | inject failure after Nth row | migrate | rollback all rows | exact pre-snapshot | partial rows |
| T17 | inject failure before receipt insert | migrate | rollback data and schema | no receipt and unchanged DB | data without receipt |
| T18 | inject failure during receipt insert | migrate | rollback all | no data/receipt drift | partial receipt |
| T19 | force close before commit | reopen | uncommitted work absent | integrity + exact pre-state | partial commit |
| T20 | verified backup then restore to new file | restore | semantic equality | hashes, row counts, integrity | backup not restorable |
| T21 | TaskStore readback after reopen | load | model parity incl NULL/unknown | serialized Task snapshot | mismatch |
| T22 | integrity check | check | quick_check=ok | captured output | any non-ok |
| T23 | foreign key check | check | zero violations | captured output | any row |
| T24 | preserve Task/Occurrence/Checklist IDs and all FK edges | migrate | exact identities and edges | before/after graph snapshot | changed/missing edge |
| T25 | repeat entire suite on two independent fixture files | run suite twice | same deterministic outputs | fixture IDs + hashes + logs | nondeterminism |
| T26 | source absent, destination present, no receipt | preflight | AMBIGUOUS; no writes | unchanged snapshot + diagnostic | auto-success |
| T27 | source absent, destination empty, no receipt | preflight | AMBIGUOUS; no writes | unchanged snapshot | inferred no history |
| T28 | valid receipt but altered destination | verify | CORRUPT_AFTER_MIGRATION | receipt mismatch evidence | accepted as applied |
| T29 | unknown schema column/index/trigger | preflight | stop without rebuild | schema inventory unchanged | unknown object dropped |
| T30 | recurrence and all non-Occurrence relations present | migrate | no collateral mutation | domain snapshots unchanged | unrelated change |

## Fixture profiles
- Small: 1,000 Tasks, 5,000 Occurrences, 10,000 checklist items.
- Medium: 10,000 Tasks, 100,000 Occurrences, 250,000 checklist items.
- Large: 100,000 Tasks, 1,000,000 Occurrences, 2,500,000 checklist items.

## Evidence package
Every run must include exact source SHA, app/test commit SHA, fixture SHA-256, SQLite version, test command, exit code, logs, before/after snapshots, receipt, backup/restore evidence, integrity checks and artifact identifiers. A test not run is PENDING, never PASS.
