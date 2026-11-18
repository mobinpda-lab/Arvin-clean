# DATABASE RELATION INTEGRITY REPORT — COMMAND 42-R
**Status:** V7 BASELINE PASS / MIGRATED RELATIONSHIP PARITY BLOCKED
## Physical v7 baseline
- `PRAGMA integrity_check`: `ok`.
- `PRAGMA foreign_key_check`: zero violations.
- Project→Task membership: 2 rows.
- Task→Person: 1 row.
- Task→Tag: 1 row.
- Follow-up→Person: 1 row.
- Follow-up→Task: 1 row.
- Checklist→Task: 2 rows.
## Not yet proven
No after-migration relation graph exists. The v19 installer transfers legacy Follow-up/Person relationships and retires legacy tables; the v20 migration creates Center↔Project and Project↔Category junctions while retaining legacy relation evidence. Neither transformation has been executed against this Main v7 fixture. Ambiguous links, orphan rows, NULLs and unknown values require explicit before/after comparison and exception-ledger review.
