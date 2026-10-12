# Multiple independent Task reminders — approved implementation design

Date: 2026-10-13
Repository: `mobinpda-lab/Arvin-clean`
Issue: #2654
Status: Owner approved feature and full Task editor entry point. UX numbering recommendation accepted as implementation direction; exact implementation and compatibility tests remain in progress.

## Product behavior

1. The full Task create/edit form contains a dedicated **یادآورها** section.
2. **+ افزودن یادآور** adds a new independent reminder without replacing existing reminders.
3. Each reminder has a stable immutable ID, editable title, date/time, explicit date-only/all-day state, and its own remove/edit controls.
4. New reminder title defaults to `<Task title> — یادآور N`. N is allocated monotonically for that Task; removing reminder 2 does not rename reminder 3 or recycle number 2. Titles remain editable.
5. Calendar event identity is based on stable reminder ID, never title/date. Editing title/date updates the same event; adding another reminder creates a different event.
6. `nextFollowUp` and reminder dates remain independent. Creating a reminder from next follow-up is opt-in; prefilled title/time are editable defaults only.
7. Editing/removing a reminder cannot mutate other reminders, follow-up history, or `nextFollowUp`.

## Canonical representation and compatibility

- Store the new reminder collection inside the canonical `Task` JSON model. Continue using the existing Task SQL envelope, backup and restore, Calendar bridge, and notification scheduling foundations. Do not create a parallel store/scheduler.
- Retain legacy `Task.reminderDate` and `FollowUp.reminderDate` JSON fields and decode them unchanged during transition. Do not silently migrate/clear either legacy field, copy a legacy reminder into the new list automatically, or infer all-day from a midnight timestamp.
- Existing legacy Task-level reminder must keep its current stable Calendar identity (`task-reminder:<taskId>`) until a deliberate, tested compatibility mapping is implemented. New reminders need distinct deterministic IDs such as `task-reminder:<taskId>:<reminderId>`; the legacy identity must not be emitted twice.
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

Implement on `feat/task-multiple-reminders-editor-20261013`, keep changes scoped to the canonical model/editor/projection/tests, and open a PR for review. Do not merge automatically. Release remains NO-GO until the required CI and device evidence is available.
