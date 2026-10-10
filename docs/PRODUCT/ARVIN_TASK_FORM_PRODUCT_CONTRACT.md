# Arvin Task Form — Product Contract

**Status:** Decision accepted; project-wide implementation and acceptance remain in progress.  
**Canonical issue:** [#2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593)

## User outcome
A user can create a simple Task quickly, or expand the same form to manage repeat schedules, checklist, project/category/tags and important commitments without learning technical concepts.

## Canonical form
- Title; optional short description; date and time.
- Repeat and Checklist.
- Project (0..1), Category (canonical single concept), Tags (0..n).
- Tracking level: ordinary or important-and-trackable.
- Conditional follow-up/tracking details.
- Optional Note.
- Explicit Cancel and Save actions.
- Existing Reminder and other supported capabilities remain available and must not regress.

## Architecture invariants
- Task remains the central entity and source of truth.
- Create/Edit reuses `ArvinTaskEditorDialog`, canonical Task model and existing Task persistence path.
- Checklist remains inside Task; recurring occurrence checklist state is independent.
- Repeat is a Task capability; occurrences are projections/execution state under existing architecture.
- Category and Group are not separate entities.
- Tracking level does not create a new entity.
- Date/time UI uses existing Jalali date support and Universal Arvin Time Picker.
- No duplicate model, storage, repository, editor, scheduling engine or workflow.

## Cross-feature integrity
Form changes must preserve canonical identity, history, Project/Category/Tag assignments, recurrence, checklist definition/state, follow-up/next action, reminder semantics, calendar links and backup/restore compatibility.

## Definition of Done
Do not call the form complete until:
- each related surface is audited and exceptions are documented;
- required scenarios in #2593 pass;
- exact-head Analyze, full tests, Debug and Release builds pass;
- relevant Android smoke passes;
- actual screenshots are reviewed for RTL, responsive layout and contrast;
- real-device interaction and product-owner visual acceptance are recorded;
- issue and implementation PR accurately list Changed, Evidence, Remaining and Next.
