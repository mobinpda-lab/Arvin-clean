# ARVIN ACCEPTANCE CRITERIA — 2026-10-13

Status vocabulary: **PASS** means reproducible evidence exists for the exact candidate SHA; **FAIL** means a criterion was tested and failed; **BLOCKED** means required owner input, access, or evidence is absent. A green result from another SHA does not satisfy a gate.

## AC-01 — Reconcile implementation branch with current main (P0/P1)
- **Pass when:** implementation is based on current `main` (observed SHA at checkpoint creation: `139a76567ab59b16f74c4f5a3d7e19f50fdede44`); no unresolved merge conflicts; changed-file list and diff are reviewed; no unrelated or generated files are introduced.
- **Evidence:** base SHA, candidate SHA, PR mergeability, changed-file list, and reviewed diff.
- **Current:** **BLOCKED** — PR #2655 targets older base `8136c929...` and is non-mergeable.

## AC-02 — Checklist editor behavior (P1)
- **Pass when:** a new Task has checklist disabled and the checklist block is absent; enabling it shows the block; disabling hides the block without deleting rows; re-enabling restores the exact prior rows and order; saved/reloaded Task preserves enabled state and row contents.
- **Evidence:** passing focused widget tests for initial state, toggle off/on preservation, and save/reload. Do not weaken or delete regression assertions to obtain green CI.
- **Current:** **FAIL** — two tests in `test/task_editor_dialog_test.dart` failed on the recorded candidate.

## AC-03 — Reminder row Material/ink rendering (P1)
- **Pass when:** the multiple-reminder editor test runs without Flutter's ListTile background/ink assertion; row background, border radius, tap target, ink feedback, and RTL layout remain visually correct.
- **Evidence:** focused widget test plus full suite; add a golden/screenshot assertion if practical.
- **Current:** **FAIL** — the multiple-reminder test triggers a ListTile/DecoratedBox Material assertion.

## AC-04 — Multiple reminders remain independent (P1; data integrity)
- **Pass when:** one canonical Task stores at least two reminders with stable, distinct IDs; editing/deleting one does not mutate another; ordering is deterministic; no Task copy is created; Calendar/notification delivery keys are stable and do not duplicate an event.
- **Pass when:** legacy singular Task reminder and per-FollowUp reminder data either remain preserved and round-trip correctly or are migrated through an explicitly approved, tested compatibility strategy. No silent overwrite, normalization, or loss.
- **Evidence:** tests for add/edit/delete of two reminders, stable IDs, legacy/current JSON decode/encode, database persistence, backup/restore, and duplicate prevention.
- **Current:** **BLOCKED** — complete implementation and compatibility evidence are not established.

## AC-05 — Follow-up and reminder semantics (owner contract)
- **Pass when:** setting Next Follow-up alone creates no reminder; an explicit user action may seed a reminder using Task title and Next Follow-up schedule; afterward each can be independently edited/deleted; clearing either does not rewrite the other; existing reminders are neither overwritten nor duplicated.
- **Evidence:** regression tests for first-time activation, explicit opt-in seeding, edit/clear independence, existing-reminder preservation, and idempotency.
- **Current:** **BLOCKED** — owner contract is documented; implementation evidence is still required.

## AC-06 — Date-only/all-day semantics (data integrity)
- **Pass when:** date-only/all-day intent is stored explicitly and independently for each supported reminder; an intentional midnight timed reminder remains timed; legacy records without a marker decode according to an approved backward-compatible rule; JSON, SQL persistence, backup, and restore preserve the marker.
- **Block:** never infer all-day from midnight; do not introduce a model or backup-format migration without owner approval and compatibility tests.
- **Current:** **BLOCKED** — compatibility and implementation proof are not complete.

## AC-07 — Exact-head automated validation (P0 release gate)
- **Pass when:** on one recorded candidate SHA, Analyze passes; every test shard passes with zero failures; Debug and Release APK builds pass; Calendar Provider Acceptance passes; all six Device Smoke lanes pass (Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore).
- **Evidence:** workflow URLs and each run's exact `head_sha` equals the candidate SHA.
- **Current:** **FAIL** — Build failed on `217c57ad2574ef7f87182c8edfed84c0be0c38ab` although Calendar Provider Acceptance and six Device Smoke lanes passed on that head.

## AC-08 — Data safety and backup/restore (P0 release gate)
- **Pass when:** old-format backup restores without loss; new-format backup round-trips multiple reminders and explicit date-only metadata; Task identity, checklist rows, recurrence history, follow-up data, and Calendar links remain consistent; injected restore failures roll back records and related Category/Tag catalogs.
- **Evidence:** automated round-trip and failure-injection tests plus a documented restore report on the candidate SHA.
- **Current:** **BLOCKED** — required end-to-end evidence is not established.

## AC-09 — Calendar projection and duplicate prevention (P0 release gate)
- **Pass when:** first sync creates one linked external event; later sync updates that event by Task ID/external event ID; repeated sync creates no duplicate; editing/deleting a reminder affects only its linked projection; imported phone-calendar events are not treated as Arvin-owned Tasks.
- **Evidence:** automated integration tests plus physical-device create → update-existing → repeat-sync validation with event IDs and before/after counts.
- **Current:** **BLOCKED** — physical-device evidence remains outstanding.

## AC-10 — Physical-device and Persian RTL acceptance (P0 release gate)
- **Pass when:** installation and core flow complete on a real device; Home, Quick Capture, Task editor, Checklist, Repeat, Tracking, Follow-up, Reminder, Calendar, and Backup/Restore are exercised; no crash, data loss, duplicate event, clipped Persian text, broken RTL, inaccessible tap target, or unusable compact-screen layout is observed.
- **Evidence:** device model/OS, app build SHA/version, steps, result, screenshots or recording, and known issues. Emulator smoke alone is insufficient.
- **Current:** **BLOCKED** — physical-device acceptance evidence is missing.

## AC-11 — Release handover (P0 release gate)
- **Pass when:** Release Notes, Installation Guide, User Guide, Known Issues, Architecture Summary, and Evidence Report exist in the repository; each claim points to verified artifacts; explicit owner release approval is recorded.
- **Current:** **BLOCKED** — complete handover and approval have not been established.

## Execution rule
Every gate status must cite a commit SHA and evidence artifact. Update this file when evidence changes; never set PASS based on intention, source inspection alone, or results from another SHA. Release stays **NO-GO** while any P0 gate is FAIL or BLOCKED.


## Follow-up & Reminder v2.0 acceptance additions — 2026-10-13

- Confirm the full Task form keeps the Follow-up toggle and does not expose an auto-generated Follow-up timestamp.
- Confirm Follow-up entry supports optional explicit Reminder creation with editable initial values.
- Confirm Quick Entry Follow-up and Checklist toggles remain compact and reveal their roll boxes only when enabled.
- Confirm Follow-up, `nextFollowUp`, Reminder and `reminderDate` are independently filterable/searchable wherever supported.
- Confirm each Task-level Reminder is independently editable/removable and linked to the canonical parent Task.
- Confirm legacy fields, JSON/SQL, backup/restore, all-day-vs-midnight, notifications, Calendar stable IDs and no-duplicate behavior.
- Resolve in-app vs phone Calendar scope before projecting follow-up-only values to the phone Calendar.
- Acceptance requires exact-head automated checks and physical-device evidence; documentation alone does not pass the gate.
