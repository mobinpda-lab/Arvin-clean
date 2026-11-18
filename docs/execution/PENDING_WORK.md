# Pending Work — COMMAND 38-R Follow-through
- Updated: 2026-11-18 | Priority: P0 → P1 → P2 → P3–P6

## P0 — Evidence and historical recovery
- [ ] Retrieve and archive complete original COMMAND 37-R report.
- [ ] Complete v7–v20 DDL/data-transfer inventory with exact source blobs.
- [ ] Resolve version-9 lineage ambiguity.
- [ ] Build exact SQLite fixtures for every supported historical source.
- [ ] Prove Main v7 upgrade route or document unsupported routes.

## P1 — Final architecture
- [ ] Finalize DATABASE_SCHEMA_DESIGN.md with concrete DDL and indexes.
- [ ] Finalize DATABASE_RELATIONSHIP_CONTRACT.md from current consumers.
- [ ] Add ProjectExecution with unique (project_id, center_id).
- [ ] Resolve duplicate semantic ownership among tasks.project_id, project_items and ProjectExecution.
- [ ] Audit all existing Task/Project membership tables.
- [ ] Determine Category-per-Task cardinality from product contract and code.
- [ ] Specify Reminder and Checklist ownership.

## P2 — Migration
- [ ] Implement ordered retry-safe migration registry.
- [ ] Preserve IDs, data and relationships.
- [ ] Add failure injection, rollback and retry tests.
- [ ] Do not drop historical structures before transfer proof.

## P3 — Stores and executor
- [ ] Consolidate CenterStore, ProjectStore, ProjectExecutionStore, CategoryStore, TaskStore, PersonStore and BackupRepository.
- [ ] Prove all stores use one Database Executor.
- [ ] Remove parallel Tag persistence only after migration/reconciliation.

## P4 — Reporting
- [ ] Aggregate by distinct Task identity.
- [ ] Per-Center execution status and progress.
- [ ] Completed, remaining, progress and delay metrics.

## P5 — Backup/Restore
- [ ] Backup all tables, IDs and M2M relations.
- [ ] Restore into independent SQLite file.
- [ ] Compare row counts and relation integrity.
- [ ] Run FK validation and corruption/recovery tests.

## P6 — Acceptance
- [ ] Run all 21 COMMAND 38-R acceptance tests on one SHA.
- [ ] Flutter Analyze, unit tests, APK build, device smoke.
- [ ] Preserve failures and attach logs.
- [ ] No Main merge, release or deployment without independent acceptance.