# Multiple independent Task reminders — approved implementation design

Date: 2026-10-13
Repository: `mobinpda-lab/Arvin-clean`
Issue: #2654
Status: Owner approved feature and full Task editor entry point. UX numbering recommendation accepted as implementation direction; exact implementation and compatibility tests remain in progress.

## Product behavior

1. The full Task create/edit form contains a dedicated **یادآورها** section.
2. **+ افزودن یادآور** adds a new independent reminder without replacing existing reminders.
3. Each reminder has a stable immutable ID, editable title, date/time, explicit date-only/all-day state, and its own remove/edit controls.
4. New reminder title defaults to `<Task title> — یادآور N`. N is allocated monotonically for that Task; removing reminder 2 does not rename reminder 3 or recycle number 2. Titles remain editable. Default titles use Persian digits. A new timed reminder defaults to one hour from the current local time, so saving without further edits does not immediately trigger it.
5. Calendar event identity is based on stable reminder ID, never title/date. Editing title/date updates the same event; adding another reminder creates a different event.
6. `nextFollowUp` and reminder dates remain independent. Creating a reminder from next follow-up is opt-in; prefilled title/time are editable defaults only.
7. Editing/removing a reminder cannot mutate other reminders, follow-up history, or `nextFollowUp`.

## Canonical representation and compatibility

- Store the new reminder collection inside the canonical `Task` JSON model. Continue using the existing Task SQL envelope, backup and restore, Calendar bridge, and notification scheduling foundations. Do not create a parallel store/scheduler.
- Retain legacy `Task.reminderDate` and `FollowUp.reminderDate` JSON fields and decode them unchanged during transition. Do not silently migrate/clear either legacy field, copy a legacy reminder into the new list automatically, or infer all-day from a midnight timestamp.
- Existing legacy Task-level reminder must keep its current stable Calendar identity (`task-reminder:<taskId>`) until a deliberate, tested compatibility mapping is implemented. New reminders need distinct deterministic IDs in the `task-reminder-item:<taskId>:<reminderId>` namespace; the legacy identity must not be emitted twice.
- New collection entries use explicit `isAllDay` metadata. Date-only and intentional midnight are different values.
- Old records that have no new collection decode as an empty collection; legacy fields remain available through their existing paths. New writes preserve legacy values unless the user explicitly edits the corresponding legacy reminder in its existing compatibility control.
- Sequence allocation must be persisted or derived from all prior sequence numbers, including deleted-number history, so numbering never changes/recycles after deletion. If a persisted counter is introduced, it belongs to Task JSON and is covered by round-trip tests.

## Required regression coverage

- Legacy Task and FollowUp JSON decode/encode retains singular reminder values.
- Multiple new reminders round-trip through Task JSON, SQL save/reload, and backup/restore.
- Create/edit/delete one reminder leaves all other reminder objects, legacy fields, follow-up history, and nextFollowUp unchanged.
- Sequence numbers stay stable after deleting a middle reminder; titles are editable.
- Date-only and intentional midnight survive model, editor, backup and Calendar projection.
- Calendar CREATE then UPDATE uses the same stable event identity after title/date edits; distinct reminder IDs do not collide; existing legacy event is not duplicated.
- Exact-head Analyze, all test shards, Debug/Release APK, Calendar Provider Acceptance, all six Device Smoke lanes, and physical-device acceptance are required before release.

## Delivery discipline

Implementation is tracked on `feat/task-multiple-reminders-editor-20261013` in PR #2655. Keep changes scoped to the canonical model/editor/projection/tests. Do not merge automatically. Release remains NO-GO until the required CI and device evidence is available.


## AUTHORITATIVE SUPERSESSION — 2026-10-15 — Owner-selected legacy migration Option B

This section supersedes earlier statements in this design that prohibit automatic migration of legacy Task.reminderDate. Preserve those older entries as history only.

The owner explicitly selected Option B. On decoding legacy canonical Task JSON, migrate a non-null legacy Task.reminderDate into a TaskReminder record with stable ID legacy-task-reminder, explicit isLegacyTaskReminder metadata, preserved timestamp, and a persisted legacyTaskReminderMigrationVersion marker. Do not infer all-day from midnight. Keep the old date field during the compatibility transition, but do not project or schedule it a second time once the migration marker is set. The migrated reminder must retain the old Calendar ID task-reminder:<taskId> and the old scheduler delivery key so an existing event/alarm is reconciled rather than duplicated. Re-reading or restoring the same JSON must not add another reminder. Existing independent TaskReminder entries must remain unchanged; the migrated entry gets a sequence after the existing maximum.

The owner reports that the current app database is empty and Arvin is not yet populated with real user data. This does not prove that every backup, fixture, test database or other installation is empty, so compatibility tests remain required.

**Status:** Candidate implementation and regression tests are on this PR branch; exact-head CI, SQL/backup integration, Calendar provider and physical-device acceptance remain unverified. Do not merge or release until the final exact SHA passes all required gates.


## AUTHORITATIVE OVERRIDE — 2026-10-15 — Legacy Task reminder migration (Option B)

This section supersedes the earlier compatibility bullets above wherever they conflict with this decision.

- The owner explicitly selected Option B: when canonical Task JSON contains a non-null legacy `reminderDate` and migration version is below 1, migrate it once into `taskReminders` with stable ID `legacy-task-reminder` and `isLegacyTaskReminder: true`.
- Persist `legacyTaskReminderMigrationVersion: 1` so a deleted migrated reminder cannot be resurrected from the retained compatibility field. Keep `reminderDate` intact during compatibility; the version marker prevents duplicate projection/scheduling.
- Preserve the original timestamp. Midnight alone does not imply all-day. Preserve legacy Calendar event identity `task-reminder:<taskId>` and existing scheduler identity.
- Keep this data embedded in canonical Task JSON and use the existing SQL, backup/restore, Calendar and notification foundations; do not add a parallel store.
- This override changes the previous design statement that migration must not occur. All other requirements (stable independent IDs, monotonic numbering, no cross-reminder mutation, tests, and release gates) remain in force.
- Validation status is determined by the latest exact PR head and its recorded evidence, not by this design note. Emulator CI is not physical-device acceptance; release remains NO-GO until integrated acceptance is complete.
