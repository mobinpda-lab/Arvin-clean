# CENTER END-TO-END ACCEPTANCE — COMMAND 60-R.1
**Observed:** 2026-11-19 / ۲۸ آبان ۱۴۰۵
**Canonical SHA inspected:** `6d806125e91056fedb74b0644d77a273ee4b675f`
**Tracking issue:** #3550
**Status:** IN PROGRESS / BLOCKED

## What exists
The Schema 9 hierarchy migration `lib/services/g1_rev10_hierarchy_v9_migration.dart` creates relational Center and hierarchy structures including `centers`, `center_projects`, `categories` and `project_categories`, with migration safeguards and exception recording. The approved relationship contract is recorded in `docs/ADR/ADR-2026-11-14-CENTER-PROJECT-CATEGORY-M2M.md`.

## What is not present on the canonical branch
The canonical tree at `6d806125e91056fedb74b0644d77a273ee4b675f` has no dedicated:
- Center model,
- CenterStore/repository,
- Center management page,
- end-to-end Home Center selection and query path.

The existence of Schema 9 tables is not proof of a usable feature.

## Required acceptance chain
1. Center model with stable IDs and serialization contract.
2. CenterStore with file-backed create/read/update/archive/delete behavior and transaction-safe membership management.
3. Center↔Project and Project↔Category M2M links, preserving endpoint records and valid links.
4. Task's independent optional Center/Project/Category assignments according to the approved ADR.
5. Dedicated Center management page with create/edit/archive/restore and safe deletion behavior.
6. Home Center selector wired to Store and SQL query/projection.
7. Persistence after app process close/reopen.
8. Backup/Restore round-trip including Centers and relationship links, plus rollback test.
9. Exact-SHA Analyze, all six shards, Debug/Release APK and relevant Device Smoke.

## Decision
Schema foundation: PRESENT.
Domain/store/UI/backup/Home integration: NOT VERIFIED / NOT ACCEPTED.
No claim of completed Center capability.
