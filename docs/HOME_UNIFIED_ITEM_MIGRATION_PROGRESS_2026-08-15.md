# Arvin — Home Unified Item Migration Progress

## Audit result
The current `lib/main.dart` still defines legacy `ArvinTask` and `TaskRepository`, while the official `lib/models/task.dart` already contains the Unified `Task` model with reminders, follow-ups, recurrence, archive/trash and completion state.

## Rule
Do not add Reminder/Recurring UI to the legacy `ArvinTask` path. Migration must preserve legacy `arvin.tasks` data and avoid introducing a second persistence path before the storage strategy is explicitly proven.

## Current Wave
- Migration work stays isolated in `wave2/home-unified-migration-boundary`.
- CI is the merge gate: Analyze → Test → Build APK → Verify APK.
- Documentation is updated alongside migration slices.
- Production storage behavior is not changed until the migration boundary and rollback/idempotency contracts are proven.

## Completed slice — migration boundary hardening
Added `lib/services/task_migration_adapter.dart` as a small boundary around the canonical `Task` model.

The adapter now:
- validates that each legacy task is an object
- requires a non-empty task id
- validates the optional legacy title type
- accepts an empty list safely
- supports multiple tasks
- rejects duplicate task ids during decode
- rejects duplicate/empty ids during unified encode
- preserves the existing `followUpDate` → `FollowUp` behavior supplied by `Task.fromJson`
- uses package imports so CI analysis does not depend on relative `lib` imports

Tests in `test/services/task_migration_adapter_test.dart` cover:
- legacy `arvin.tasks` JSON → Unified `Task`
- preservation of legacy fields, category and follow-up date
- empty storage
- multiple tasks
- malformed JSON and malformed task entries
- missing ids
- invalid title types
- duplicate ids
- Unified serialization round-trip
- repeated conversion stability (conversion-boundary idempotency)
- duplicate ids during Unified encoding
- rejection of a non-list storage payload

## Completed slice — HomePage characterization boundary
Added regression/widget characterization coverage in `test/widgets/home_page_test.dart` for the current production HomePage before any migration rewiring.

The characterization tests currently prove:
- the existing Persian application title remains present
- search and filter controls remain present
- the new-task action remains present
- an existing legacy `arvin.tasks` item is loaded and rendered
- search filters the currently loaded legacy tasks

This is intentionally a behavior baseline, not a Unified `Task` test. It protects the current UI contract before the next load-only migration slice.

## Completed slice — read-only load boundary
Added `lib/services/task_migration_reader.dart` as a reversible, write-free boundary over the existing `arvin.tasks` key.

The reader now:
- reads the existing storage key without changing it
- delegates conversion and validation to `TaskMigrationAdapter`
- returns canonical `Task` objects
- preserves the legacy `followUpDate` → `FollowUp` conversion
- returns an empty list when storage is absent/empty
- surfaces malformed storage instead of silently discarding it
- is directly testable with injected `SharedPreferences`

Tests in `test/services/task_migration_reader_test.dart` prove:
- empty/missing storage
- legacy task loading into Unified `Task`
- follow-up preservation
- read-only/no-write behavior
- malformed storage propagation

## Completed slice — HomePage load-only wiring
HomePage now reads `arvin.tasks` through `TaskMigrationReader` and maps the canonical `Task` objects back into the existing `ArvinTask` UI view model.

This slice intentionally:
- changes only the Home load path
- keeps the existing `TaskRepository` save path unchanged
- keeps backup, restore, filter, search and multi-select behavior unchanged
- performs no write through the migration reader
- preserves `followUpDate` display using the migrated `FollowUp` date
- keeps the legacy UI model in place so this is reversible
- preserves the existing empty-state behavior if malformed storage is encountered

Regression coverage in `test/widget_test.dart` now proves a legacy `arvin.tasks` payload is loaded through the unified reader and rendered with its title, description, tag and follow-up date.

## Current validation — 2026-08-16
- Adapter boundary: PASS.
- HomePage characterization boundary: PASS.
- Read-only migration boundary: PASS on commit `5f15318094dc266dc334f5749f8ff52b823b9842`.
- HomePage load-only wiring: committed on the current branch; awaiting current-head CI.
- `Arvin Build` run #402 on the previous reader commit: PASS.
- `Arvin Parallel Wave` run #239 on the previous reader commit: PASS.
- PR #96 remains open and draft; no merge has been performed.
- Main remains on the legacy save path and no storage write semantics have changed.
- Production migration remains intentionally blocked until the load-only wiring is independently reviewed and current-head CI is green.

## Current gate
- Adapter boundary: PASS.
- HomePage characterization boundary: PASS.
- Read-only load boundary: PASS.
- HomePage load-only wiring: awaiting current-head CI.
- Production migration: BLOCKED intentionally until storage semantics and rollback/idempotency strategy are independently reviewed.
- PR #96: keep open until the next migration boundary is independently reviewed.

## Next implementation slice
After current-head CI is green, perform an independent review of the load-only Home wiring. If storage semantics and UI preservation remain clear, proceed to the next smallest reversible boundary. Do not introduce dual-write, a new storage key, save-path migration, or legacy removal until concrete data-preservation and rollback strategy is tested and reviewed.

## Review rule
If storage semantics, migration idempotency, or Home behavior becomes ambiguous, stop the change and request a DeepSeek cross-review before continuing.


## Completed slice — canonical Home follow-up projection

The legacy Home projection no longer selects a follow-up date directly from
`Task.followUps`. The compatibility rule now lives on the canonical `Task`
model as `legacyHomeFollowUpDate`:

- without follow-up history, it preserves `followUpDate`
- with history, it preserves the current Home behavior of rendering the first
  recorded follow-up
- it does not change persistence, the save path, or any visible workflow

Tests isolate both branches of this compatibility rule, including the
intentional distinction from `lastFollowUpDate`. This is a reversible
preparation step; Home remains on the legacy view model and save path.


## Implemented slice — lossless single-key Home writes

Home no longer writes its limited legacy projection directly through the
in-file `TaskRepository`. The new `TaskMigrationWriter` performs a
single-key read–merge–write against the existing `arvin.tasks` envelope:

- Home-editable fields, including the atomic
  `followUpEnabled`/`followUpDate` pair, are updated from a canonical
  `Task` snapshot
- reminder, recurrence, checklist, category, follow-up history and timestamps
  are preserved for existing items
- unrecognized future JSON fields are preserved
- omitted items are still deleted and new items are serialized canonically
- malformed or duplicate-id input is rejected before storage is overwritten
- no second key, dual-write path or Calendar coupling is introduced

`lib/main.dart` now delegates every Home save to this boundary and no longer
contains the direct legacy `TaskRepository` implementation. The visible
`ArvinTask` view model remains temporarily in place, keeping the UI slice
small and reversible.

Regression coverage in
`test/services/task_migration_writer_test.dart` proves preservation,
same-key semantics, deletion/new-item behavior and failure atomicity.

### Residual gate

Home still projects canonical tasks into `ArvinTask` for rendering. Backup
and restore semantics must be audited separately before that final view-model
conversion can be removed. Current-head Analyze → Test → APK validation is the
merge gate for this slice.
