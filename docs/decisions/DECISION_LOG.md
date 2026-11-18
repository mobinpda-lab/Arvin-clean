# Decision Log — Arvin
- Updated: 2026-11-18
- Append-only in intent. Corrections must be dated amendments, not silent rewrites.

## 2026-11-18 — ADR-001 Project Execution Model
- Status: APPROVED PRODUCT DECISION; implementation not accepted.
- Project is shared identity; Center↔Project is many-to-many.
- ProjectExecution is independent per Project/Center pair.
- Task attaches to ProjectExecution, not directly to shared Project identity.
- Task may have no Project, Center or Category.
- Category identity is independent/shareable.
- Tag has one SQLite-backed source.
- Aggregate and per-Center reports required; aggregate counts each Task ID once.
- Source: COMMAND 39-R, based on COMMAND 37-R / 38-R product decision.

## 2026-11-18 — COMMAND 38-R NO-GO
The audited implementation did not provide ProjectExecution; duplicate Task↔Project semantic ownership remained; historical migration, Store consolidation, reports and backup/restore were not accepted; workflows had failures. See COMMAND-38-R.md and TEST_RESULTS.md. No Main merge or release authorized.

## Open decisions — evidence required
Category cardinality per Task; exact canonical Task relation; existing membership-table disposition; Reminder/Checklist ownership; migration lineage handling for historical schema version 9.

## 2026-11-18 — COMMAND 40-R P0 HISTORICAL RECOVERY
- Decision: NO-GO remains. No schema or production-data migration is authorized.
- Canonical branch HEAD verified before documentation writes: `6005fb58f6c40db404353cf695445726e933d5cd`; PR #3495 is OPEN / DRAFT / UNMERGED, base `main`, head `recovery-02/main-based-integration`.
- Main base SHA in PR metadata: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Main `G1DriftSchema.version` is 7 (source blob `cd065ff25c680ed064e89068b3d063e737091025`).
- Canonical branch `G1DriftSchema.version` is 9 (source blob `3bd140f9a07b54c1e4a1dff26d64f965b437ec52`), with a distinct `G1Rev10HierarchyV9Migration` source blob `f9569182a1d79a116e1e1f4c400e69f7c47863b4`.
- PR #3384 head `310c0e20e3447c488c1e1c102c38bea5040708ca` declares schema v19 (schema blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`).
- PR #3463 head `812082964c649be7660c41213209ec34aea7167b` declares schema v20 (schema blob `b03b90efac9f3c5cbef3b1b649385cdf6369ca62`).
- Version 9's Task Template lineage and REV10 v8→v9 hierarchy migration are distinct; compatibility is not assumed.
- Full DDL extraction, exact adjacent migration edges, independent file-backed SQLite tests and data-preservation proof remain BLOCKED.
- Five COMMAND 40-R reports are evidence ledgers only; none represents P0 acceptance.


## 2026-11-18 — COMMAND 41-R HISTORICAL DATABASE FORENSICS
- Decision: NO-GO remains; no schema rollout, Main change, merge, release, deployment or production database operation is authorized.
- Exact canonical HEAD audited: `f5c64285687cd2665cc383e10277cb6e0266f4c2`; Main SHA: `45e4202b03a434459e4c021a04efa7e8396359db`; PR #3495 OPEN / DRAFT / UNMERGED.
- Git source history identifies schema points 7, 8, 9-A, 10–19 and 20. v9-A Task Template and v9-B REV10 hierarchy are distinct sources.
- Git ancestry confirms Main→v9-A→v19→v20 historical source lineage; current canonical #3495 HEAD is diverged from historical v20 line, with Main as merge base.
- Historical v20 exact-SHA workflows passed selected lifecycle and SQLite snapshot suites; they do not prove Main v7→v20 and do not transfer to current canonical SHA.
- Current canonical Build failed (runs 44273882049); COMMAND 20-E failed (44273881957); Follow-up File Persistence and Device Smoke passed (44273881944, 44273881994).
- No end-to-end Main v7 physical SQLite fixture was executed. Full DDL transcription, source fixture and complete data/ID preservation proof remain BLOCKED.
- Original COMMAND 37-R report remains unavailable in the retrievable context; no reconstruction was made.
- Evidence recorded in DATABASE_SOURCE_EVIDENCE.md, updated history reports, sqlite-test-results/COMMAND-41-R.md and historical fixture README.
