# Occurrence Data Ownership Report — WAVE 4

**Checkpoint SHA:** `dbfcdb02879ed3939cb6a69d3a150e2237283a51`  
**Status:** IMPLEMENTED IN SOURCE / CI NOT YET VERIFIED

## Relational ownership

- `task_occurrences`: stable occurrence ID, owning Task FK, scheduled timestamp, status, completion timestamp, result and ordinal.
- `occurrence_checklist_items`: occurrence FK, checklist ordinal and item value.
- Occurrence ID is deterministic from the owning Task ID and canonical scheduled timestamp.
- A checklist-only occurrence receives a pending occurrence row; its checklist remains independent from other occurrences.

## Data path

- Legacy Task envelope maps are migrated during the G1 schema transaction.
- Migration validates source/target Occurrence and checklist parity before removing those maps from the Task envelope.
- TaskStore reads Occurrence and checklist state from the relational tables.
- TaskStore save rewrites the relational rows in its SQL transaction.
- Task migration writer creates relational rows and validates them before COMMIT.
- Backup serialization remains a portable Task JSON representation; this is a transfer boundary, not local SQL ownership.

## Tests added

A migration/round-trip test covers two occurrences with different statuses, completion/result fields and independent checklist values; it checks the legacy envelope no longer contains the migrated maps and verifies TaskStore save/load.

## Remaining verification

The new tests have not yet passed on the current exact SHA. Unknown future Occurrence fields outside the currently modeled status/completion/result shape require explicit compatibility coverage. Android persistence/reopen and full backup/restore acceptance remain pending.
