# COMMAND 35 — PR Transfer Matrix
Audit baseline: `ed4f1e0c0e01f186155b194b34212b7f2ffb584b`
Canonical target: PR #3495 / `recovery-02/main-based-integration`

| Source | Unique work identified | Destination / disposition | Test evidence on source SHA | Transfer SHA |
|---|---|---|---|---|
| #3052 | Broad product/UI, Calendar, Center, Reminder, Backup, SQL schema v17, Task/Project stores, tests and continuity docs | NOT TRANSFERRED wholesale. Selective recovery required after exact blob and dependency comparison. | Build FAILURE; Device Smoke CANCELLED; Follow-up Persistence SUCCESS; Calendar Provider Acceptance SUCCESS | None |
| #3384 | SQL and schema v19; recurrence/occurrence codecs; stores; tests; documentation; VazirHarf assets | NOT TRANSFERRED. v19 source is stacked on a non-Main branch; sequential migration and REV10 compatibility unresolved. | Build FAILURE; Device Smoke CANCELLED; Follow-up Persistence SUCCESS; SQLite Snapshot SUCCESS; Hierarchy Candidate SUCCESS | None |
| #3463 | v19→v20 M2M migration, Center↔Project and Project↔Category join tables, Task link columns, acceptance/failure-recovery tests | NOT TRANSFERRED. Source-only files absent in Canonical; current schema version mismatch. Adaptation required. | Dedicated SQLite v20 lifecycle/M2M workflow SUCCESS; Build FAILURE; Device Smoke CANCELLED; Follow-up Persistence SUCCESS | None |
| #3376 | QueryInterceptor envelope diagnostics and diagnostic workflow | Preserve as historical forensic source; do not add a second permanent workflow without proving current diagnostic need. | Diagnostic workflow FAILURE; Build FAILURE; Device Smoke CANCELLED; Follow-up Persistence SUCCESS | None |
| #3380 | Reopened NativeDatabase initialization in diagnostic test harness | Preserve test intent; compare with current test lifecycle before adaptation. | Diagnostic workflow FAILURE; Build FAILURE; Device Smoke CANCELLED; Follow-up Persistence SUCCESS | None |
| #3382 | Independent SQL rows/relations capture before TaskStore.load; JSON artifact + SHA256 | Potentially reusable as a focused test pattern; no production change. Do not port the old workflow blindly. | Raw SQL evidence workflow SUCCESS; Build FAILURE; Device Smoke CANCELLED; Calendar Provider Acceptance SUCCESS | None |
| #3470 | Vazirmatn weight cleanup across 20 app files and a typography contract test | Candidate for selective adaptation to Canonical; do not cherry-pick stacked branch. | Build FAILURE; Device Smoke CANCELLED; Follow-up Persistence SUCCESS | None |
| #1901 | Checklist enablement, Home filter/visual contract, Notebook shared taxonomy, Quick Add date/time, Task editor and regression tests | Preserve product requirements; selectively compare current code and exact blobs. PR remains open and unmerged. | No workflow runs returned for inspected head | None |

## Blob comparison evidence
- #3463 `g1_many_to_many_hierarchy_migration.dart` (blob `a2c768da3c90d2610ea2285ddd248e8fbbc27489`) is absent from Canonical at the audit baseline.
- #3463 `center_store.dart` (blob `192c919295a3adee7c25dd1cfafb808df73b6bc2`) is absent from Canonical at the audit baseline.
- #3463 M2M acceptance and migration test files are absent from Canonical at the audit baseline.
- #3463 `g1_drift_schema.dart`: historical blob `b03b90efac9f3c5cbef3b1b649385cdf6369ca62`; Canonical blob `3d932bcaf27a5bd8f7ecb744ce9dcf8bb254246f`; different.
- #3463 `project_store.dart`: historical blob `ca5a9b1f156568d49dbe0752f0faee35bedcb22b`; Canonical blob `01659d00afa0df6b588bab01fc3bfe68d8707159`; different.
- #3052 selected core files are not blob-identical to Canonical: `g1_drift_schema.dart`, `task_store.dart`, `models/task.dart`, `project_store.dart`.

## Transfer ledger
No source commit has been cherry-picked or rewritten into the canonical branch in this phase. Consequently every transfer SHA is intentionally recorded as NONE, not fabricated. The matrix must be updated per transfer with source commit, source blob(s), target path, target blob, tests and resulting SHA.
