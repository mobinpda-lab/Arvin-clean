# V19 Execution Exception Ledger

**Run:** `44308608481`  
**Disposition:** No installer exception or SQL migration failure observed. The following compatibility observations remain documented.

| ID | Observation | Evidence | Impact / disposition |
|---|---|---|---|
| E48-001 | Installer-generated Task legacy envelope can contain model defaults that differ from SQL-owned Task fields | In post-snapshot, Task `task-done-002` has SQL `completed=1`, `completed_at=2026-11-10T09:30:00`, `priority=medium`; its generated envelope contains `completed=false`, `completedAt=null`, `priority=none` | Historical `TaskStore._decodeTask` overwrites these envelope fields from canonical SQL columns before decoding. SQL values are preserved. Consumers must use that canonical read boundary; raw duplicated envelope fields are not authoritative. |
| E48-002 | Drift open advanced `PRAGMA user_version` from 7 to 19 | Pre/post physical snapshots and execution verdict | Expected runtime behavior of the original `ensureOpen(schema)` path; no manual PRAGMA write was performed. |
| E48-003 | Initial probe snapshot used a label that conflated code schema version with database user_version | Run `44308068805` artifact | Corrected authoritative runner labels `installer_code_version` separately and explicitly asserts user_version 7 before / 19 after. |
| E48-004 | Fixture contains no occurrence-history rows | Pre-snapshot and zero post occurrence rows | Occurrence codec was part of original Installer path, but this fixture cannot prove transfer of non-empty occurrence history. Keep broader fixture coverage as future acceptance work. |

No unknown data loss, malformed source record, FK violation, SQLite integrity failure or installer exception was observed in the approved fixture run. These findings do not replace broader production-data testing.
