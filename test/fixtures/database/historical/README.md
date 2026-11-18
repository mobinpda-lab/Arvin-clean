# Historical SQLite fixtures — COMMAND 41-R
**Status: BLOCKED — NO FIXTURE ACCEPTED**

This directory is reserved for independently reproducible SQLite files/fixture builders derived from exact historical source DDL.

No database file or synthetic DDL is checked in yet. Do not treat this README as a fixture or test pass.

Before adding a fixture:
1. Record source version, source commit SHA, schema blob SHA and exact DDL source lines.
2. Create the SQLite file using only the extracted historical DDL.
3. Add deterministic Task, Follow-up, Person, Reminder, Recurrence, Template, Checklist and Tag identifiers and relation rows.
4. Include NULL, non-contiguous IDs and unknown legacy payload fields.
5. Capture a before snapshot and checksum.
6. Run the actual migration code, not a rewritten SQL approximation.
7. Capture after snapshot, FK/integrity checks and close/reopen/retry/failure evidence.
8. Preserve the fixture source and exact test runner SHA.

Main v7→v20 remains NO-GO until these fixtures execute successfully.
