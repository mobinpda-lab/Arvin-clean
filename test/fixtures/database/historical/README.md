# Historical SQLite fixtures — v8 source recovery

**Status: PARTIAL — DDL fixture added; migration acceptance NOT RUN**

## Source of truth
- Historical commit: `874dd8b567fdceae7ed62f01a93804dcea1a5473`
- Historical schema blob: `f4d488fa3f972c4ce123df6089b66569b9c8849c`
- Source file: `lib/services/g1_drift_schema.dart`
- Extracted tables: 16, preserving the historical CREATE TABLE statements.
- Explicit named indexes in the historical source: one partial unique index, `idx_projects_active_template_center`.
- No additional named index DDL was present in the historical source. SQLite auto-indexes arise from the historical PRIMARY KEY / UNIQUE constraints.

## Checked-in artifacts
- `v8_schema.sql`: independent SQL DDL extracted from the historical source; it does not install the current schema first.
- `../../../../services/historical_v8_fixture_test.dart`: executes the SQL against an isolated in-memory SQLite executor, checks all 16 table names, key foreign-key declarations and the partial index.
- DDL file SHA-256 fingerprint: `9a11f8952cf1d11bebd020a785021e7f051410580762a6b78276b7b0f89dc2ba`.

## Remaining acceptance work
1. Run the fixture test and verify its fingerprint on CI.
2. Add deterministic historical records for active/archived Projects, valid/NULL/missing Center references, template definitions/tasks/applications, project_items, People, Follow-ups, Tags, Checklist and non-contiguous IDs.
3. Capture before/after schema and data snapshots.
4. Execute the actual v8→v9 migration against the independent fixture, including close/reopen, failure injection, rollback, retry, exception recovery and FK/integrity checks.
5. Preserve exact Candidate SHA and workflow evidence.

The DDL artifact is not a complete historical data fixture. No migration or product acceptance is implied by its presence.
