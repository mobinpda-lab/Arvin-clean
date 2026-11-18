# Migration Risk Register

| ID | Risk | Severity | Detection | Mitigation / gate | Status |
|---|---|---|---|---|---|
| R01 | V19 removed source keys but has no Occurrence receipt | Critical | source absent + no receipt | mark ambiguous; restore/forensic path | OPEN |
| R02 | absent vs explicit NULL lost in V19 SQL projection | Critical | compare raw source and SQL | presence bits; no inference without source | OPEN |
| R03 | unknown nested Occurrence keys discarded | Critical | compare source state to SQL projection | opaque JSON + original state payload | OPEN |
| R04 | existing SQL rows conflict with legacy source | Critical | exact field-by-field reconciliation | abort, no overwrite | OPEN |
| R05 | schema version slot V20 overlaps M2M plan | High | inspect canonical PR/ADR | one coordinated migration train or re-sequence V21 | OPEN |
| R06 | TaskStore exposes data before migration gate | Critical | call graph review | central open coordinator blocks reads/writes | OPEN |
| R07 | SQLite transaction/PRAGMA ordering differs by runtime | High | file-backed Android/desktop test | foreign_keys before BEGIN; physical failure tests | OPEN |
| R08 | backup copy omits WAL state | Critical | restore test | online backup/quiesce protocol | OPEN |
| R09 | unknown SQL objects lost during table rebuild | Critical | schema inventory | additive ALTER only; fail on unknown objects | OPEN |
| R10 | model decoder applies defaults to malformed/missing fields | High | round-trip tests | strict adapter; containsKey; typed validation | OPEN |
| R11 | recurrence migration has separate marker semantics | High | source audit | keep recurrence step separately versioned and unchanged | OPEN |
| R12 | performance degrades on large occurrence histories | Medium | benchmark profiles | bounded batches inside one transaction; measure memory | OPEN |
| R13 | old app opens new schema but cannot preserve new fields | High | downgrade test | no downgrade; restore pre-migration backup | OPEN |
| R14 | hash canonicalization hides type/precision differences | High | adversarial JSON fixtures | typed canonical encoding + raw source digest | OPEN |
| R15 | interrupted/manual partial state has no receipt | Critical | ledger/destination mismatch | stop and restore/forensic review | OPEN |
| R16 | shared DB concurrent openers race migration | High | concurrent TaskStore open test | serialized coordinator + BEGIN IMMEDIATE | OPEN |

## Release blockers
R01–R04, R06–R09 and R15 are P0. No implementation or V20 evaluation may proceed while any critical risk lacks an accepted mitigation and physical evidence.
