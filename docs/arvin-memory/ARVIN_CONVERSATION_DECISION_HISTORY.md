# Arvin Conversation Decision History

Repository: https://github.com/mobinpda-lab/Arvin-clean
Updated: 2026-10-11
Purpose: durable index of owner requirements, decisions, reported installed-app findings and unresolved acceptance. This is not proof that implementation passed.

## Execution protocol
- Command v8 is an execution trigger, not a request for another explanation. Start by reading `ARVIN_EXECUTION_STATE.md`, find the latest Completed Step, re-check live GitHub, then CHECK → UNDERSTAND → DECIDE → EXECUTE → VALIDATE → RECORD → CONTINUE.
- GitHub is the project memory/source of truth. Inspect repo, branch, commit, issues, PRs, docs, architecture, code, tests, CI, build, release and existing memory before changing anything. Search code/commits/issues/PRs/tests/docs before creating new work.
- Every run must deliver DONE, BLOCKED or NEXT ACTION. Never claim completion without code, tests, build, validation and evidence appropriate to the feature. Empty CI status is not a pass; emulator is not physical-device acceptance.
- Record important decisions and user/device feedback in existing canonical Issues, PRs, ADRs and memory docs. Avoid duplicate memory hierarchies and do not treat this file as stronger than live GitHub or a governing ADR.
- Product first: Arvin is the product; GitHub/CI/automation/Factory are tools. Parallelize only independent, non-conflicting work. Stop for product-owner decision, data-loss risk, major architecture change or missing access.

## Canonical architecture invariants
- Task is the canonical source of truth. Quick Capture and Full Form edit the same Task identity; no duplicate Task on expanding the form.
- Project, Category and Tag are canonical taxonomy concepts. Category = Group synonym; no separate Group entity/store. Tag remains independently selectable/multi-select as supported by the schema. Do not infer database relationships from a conceptual diagram.
- Checklist and Repeat belong to Task. Repeat must not create copied root Tasks. Occurrence state is a projection/execution state; each occurrence's completion/checklist is independent. Past history is immutable; future repeat settings can change.
- Tracking = current status; Follow-up = next step/action. Repeat tracking level is separate from Follow-up.
- Calendar is a projection/integration surface, not Task owner. Create once and update by stable Task/external-event identity; never match by title/date and never silently create duplicate events.
- Home, Reports, widgets, Calendar and backup/restore must reuse canonical data; no parallel store, task engine, recurrence engine, report engine or backup engine.
- Backup/restore must preserve stable IDs, relations, catalogs, settings, notes/notebook checklists, occurrence history and Calendar-link metadata; maintain backward compatibility and rollback across every mutated store.

## Product and visual contract
- Persian-first, RTL, calm, minimal, fast, clear Personal Assistant experience with progressive disclosure.
- Preserve VazirHarf v34.003; do not replace it with Vazirmatn.
- Approved palette: primary #4A4CAB, light #E9EAFF, background #F8F8FB, card #FDFDFE, text #232433, secondary #80829C.
- Home: centered small «بسم الله الرحمن الرحیم», centered title «مدیریت کارها و پیگیری آروین», notification icon physically left and menu physically right, search, and four equal axes in RTL order زمان / پروژه‌ها / دسته‌ها / برچسب‌ها. No counters, old کل/فعال/انجام‌شده/عقب‌افتاده cards, «کارهای من» title or old dropdown.
- Keep clock and calendar icons side-by-side on every create/edit form. Lock-screen/widget reminder states: simple, multiple, expanded; actions done, snooze, edit, convert-to-task.
- Task form keeps common fields first and advanced fields progressively disclosed, but disclosure must never break or make required fields unreachable. Quick Capture stays minimal/one-row; Full Form supports canonical Task fields.
- Owner also requested a high-priority checklist directly under the full/edit Task form, generic for all Tasks. Example: daily school checklist active at 06:00 with کیف، خوراکی، لباس. Keep checklist inside Task; do not create a standalone checklist system.

## Universal Arvin Time Picker — accepted UX, implementation not accepted
- Decision/acceptance record: [Issue #2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589); UX docs PR [#2590](https://github.com/mobinpda-lab/Arvin-clean/pull/2590); implementation PR [#2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591).
- One reusable time-selection experience and consistent passive display formatting; contextual Persian title; large selected time in #4A4CAB with white text; circular 24-hour dial with outer 1–12 and inner 13–24; minute dial in 5-minute increments; exact-minute keyboard/manual entry with Persian/Arabic digits; RTL/accessibility/responsive behavior; explicit Cancel and Save, with Cancel never mutating caller.
- Picker selects time only; date remains separate. Preserve canonical Task times, All-Day semantics, Repeat/Occurrence, reminders, Follow-ups, Calendar, reports, scheduled backup and restore.
- Audit direct/custom picker calls and display formatters across Home filters, Backup Schedule, Follow-up, Report Center, Task Editor, Quick Capture and any other source paths. Existing main audit found six direct `showTimePicker` call sites at one checkpoint; recheck current code. No release closure without source audit, focused tests, exact-head CI, screenshots and physical-device interaction.
- PR #2590/#2591 are still open on stale base per latest recheck; #2591 has not passed physical-device acceptance.

## Task form and taxonomy acceptance
- Owner reported installed APK primarily showed stronger colors; the agreed form redesign and Project/Category/Tag arrangement were not visibly reflected. This is an acceptance failure recorded in [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139).
- Related form requirements: [#2162](https://github.com/mobinpda-lab/Arvin-clean/issues/2162), [#2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580), [#2582](https://github.com/mobinpda-lab/Arvin-clean/issues/2582).
- #2595 (simple-first form) is stacked on #2591; #2602 modifies the same Task Editor. Choose one canonical implementation lane after comparing live heads and patches. Do not duplicate the form implementation or merge stale branches.
- Exact-head #2602 Build run [#38139809938](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809938): Analyze and Debug/Release APK jobs passed, but three test shards failed. Device Smoke [#38139809930](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809930) was skipped. Failure details include missing repeat lifecycle/recurrence controls, automatic/manual reminder behavior, date-only All-Day persistence, custom Clock Dial behavior, and taxonomy row width 99.33px versus expected >270px. Fix root causes; do not weaken tests.

## Repeat Tracking Level Contract (RTLC)
- Accepted product direction recorded in [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605), related lifecycle [#2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254).
- Reuse `RecurrenceTrackingLevel.normal/tracking` already persisted inside `Task.recurrence`; older JSON defaults to normal. Do not add another Task field, entity, store, repository, database or engine.
- After Repeat, show «نوع پیگیری»: «عادی» default / «مهم و قابل پیگیری». Preserve simple-first form; tracking details progressively reveal start date, total/completed/missed/remaining, next occurrence, last status, history and progress only when canonical data supports them.
- Then add a restrained Home cue and Report Center filter «همه / عادی / مهم و قابل پیگیری», with defensible counts derived from canonical occurrence/history data. Do not show unsupported metrics.
- Preserve Task ID, Repeat rule, occurrence history, per-occurrence checklist state, backup compatibility and immutable past history. Add default/selection/edit-reopen/legacy JSON tests. Home and Reports are separate acceptance gates; screenshots/device proof remain pending.
- Do not confuse `recurrence.trackingLevel` with `followUpEnabled`.

## Calendar installed-app feedback
- Owner reported missing «ثبت در تقویم گوشی» and «ویرایش» actions, plus repeating tasks appearing only on the current day instead of all planned dates (up to seven). Track in [#2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) and owner ledger [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139).
- PR #2570 linked-event edit and PR #2587 collapsed-card actions/recurrence are merged in current mainline. That is not proof of installed-device acceptance. Verify both manual calendar actions, Edit, all scheduled recurrence dates, stable event update/no duplicate, and recurrence/checklist behavior on a real device.

## Backup/restore and release
- PR #2585 is merged at current main SHA `a6ced27660d34cd87dd8915aff68d3a7555fd57a`. It covers canonical catalogs, portable settings, stable-ID reconciliation and rollback improvements; physical-device file-picker/provider, export/restore round-trip, late-failure rollback and before/after integrity are still unverified.
- Release gate [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) and final acceptance ledger [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139) remain open.
- Before handover: validate Core Flow, backup/restore, migration, Calendar, Repeat, Checklist, Tracking, installation and physical-device behavior. Provide Release Notes, Installation Guide, User Guide, Known Issues, Architecture Summary and Evidence Report tied to exact artifact SHA and owner acceptance.
- Never call an APK “final” or “release-ready” from build success alone.

## Report Center
- [Issue #2385](https://github.com/mobinpda-lab/Arvin-clean/issues/2385) remains open. Extend existing canonical report projections, filters, preview, copy/share/print/PDF paths. No parallel report model, filter engine, renderer or export path.
- RTLC level filtering and validated metrics are additional work within the existing report path, not a new report subsystem.

## Current GitHub dependency snapshot (recheck before action)
- Main: `a6ced27660d34cd87dd8915aff68d3a7555fd57a`.
- PR #2600 documentation memory: OPEN/DRAFT, head `40963f0fe54ba8d34375c1c6c7fc62c01f27b627`, base `72a2f4cc24df7a38eff9856ce403461615db5280`; the memory branch is not main.
- Docs PRs #2598 and #2599 overlap #2600 and share stale base. Reconcile the hierarchy before merge.
- #2590 OPEN; #2591 OPEN/DRAFT; #2595 OPEN/DRAFT and stacked on #2591; #2602 OPEN/DRAFT with failing tests; #2601 OPEN and not a release-approved artifact.
- Current-main workflow lookup returned no PR-associated runs/statuses in one check. Treat as evidence missing, not pass. #2102 remains open.

## Next operational sequence
1. Re-read execution state and this decision index; refresh live refs/issues/PRs/Actions.
2. Fix and reconcile the single canonical Task-form/time-picker path; no competing implementations. Do not weaken tests.
3. Integrate RTLC once in that canonical form, then Home and Report Center, with occurrence/history/backup tests.
4. Complete calendar and physical backup/restore installed-device acceptance.
5. Reconcile documentation PRs and rebase to current main.
6. Only then close release gate with exact artifact, test/build/device evidence, complete handover package and explicit owner acceptance.


## 2026-10-11 — Owner decision recorded
- User explicitly chose Option 1: keep only the existing root Task `Description`/`description`; no separate root `Task.note` field.
- This decision resolves the data-model question, but does not authorize weakening tests or claiming the overlapping PRs are ready. The implementation must be reconciled to this contract and validated.