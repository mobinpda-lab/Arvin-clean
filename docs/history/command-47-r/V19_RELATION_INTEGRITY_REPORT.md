# V19 Relation Integrity Report

**Status: PRE-MIGRATION ONLY — POST-MIGRATION NOT TESTED**

## Pre-migration evidence

- SQLite `integrity_check`: `ok`.
- SQLite `foreign_key_check`: 0 violations.
- Fixture `PRAGMA user_version`: 7.
- The fixture was opened using the dedicated read-only v7 inspection user.

## Required post-migration checks — NOT RUN

- Full `integrity_check` and `foreign_key_check` on the migrated copy.
- All source-to-destination relation mappings, including Task/Project, Task/Tag, Task/Person, Follow-up/Person and Checklist ownership.
- Unique constraints and indexes in the actual v19 schema.
- Close/reopen and full destination snapshot comparison.

The pre-migration checks do not establish the integrity of a database that has not been migrated.
