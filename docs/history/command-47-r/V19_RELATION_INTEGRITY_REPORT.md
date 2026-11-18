# V19 Relation Integrity Report — Updated Evidence

**Fixture-level post-migration integrity: PASS.**

Authoritative run: `44308608481`; artifact: `14429935379`.

## SQLite checks

- Before: `integrity_check=ok`, FK violations 0, `user_version=7`.
- After: `integrity_check=ok`, FK violations 0, `user_version=19`.

## Relationship verification

The corrected runner asserts:
- Task-Person source rows equal the new `task_persons` projection.
- Follow-up-Person source rows equal the new `follow_up_record_people` projection.
- Person identities are preserved across legacy People and linked Person references.
- Follow-up IDs are preserved in `follow_up_records`.
- Checklist rows, Task-Tag rows and Project-Task rows are unchanged.
- Project source fields and IDs remain unchanged.

The fixture's legacy source relations remain available after the v19 Installer. No FK violation or integrity failure was observed.

This is evidence for the approved fixture only. Custom production constraints/indexes/triggers and non-empty occurrence histories need their own coverage. Retry and recovery gates remain open.
