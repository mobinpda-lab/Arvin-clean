# Arvin Calendar Task Interaction Decision

Version: 1.0
Date: 2026-10-13
Status: **Product decision accepted; initial implementation committed; exact-head validation pending**
Repository: `mobinpda-lab/Arvin-clean`
Working branch: `integration/task-multiple-reminders-safe-20261013`
Related PR: [#2666](https://github.com/mobinPda-lab/Arvin-clean/pull/2666)

## 1. Final product rule

**Tap = open the canonical Task. Long press = manage the item.**

Task remains the source of truth. Calendar is a read-only projection/navigation surface, not an alternative Task editor or owner of Task data.

A normal tap must open Task Detail for Arvin-owned Task, Follow-up, Reminder and recurrence occurrences. It must not reveal a management menu, edit/register chips, or trigger any mutation.

A long press on an actionable calendar item opens a contextual action menu. It must not trigger the item's normal-tap action as a side effect.

## 2. Normal tap

For an Arvin-owned item, a short tap opens the canonical Task Detail view for the existing Task ID. The detail view should expose the canonical Task's title, description, Project, Group/category, tags, checklist, Follow-ups, independent Reminders and history, with the selected calendar item type identified clearly.

- A Task due/recurrence occurrence opens its parent canonical Task, not a newly created Task.
- A Follow-up item opens the parent Task Detail and clearly identifies which Follow-up was selected.
- A Reminder item opens the parent Task Detail and labels the selected item as a Reminder; it must not edit Follow-up data.
- Imported external-calendar entries may use their existing source-specific open behavior; they must not be presented as canonical Arvin Tasks unless explicitly converted.
- Prayer and Daily Content items retain their domain-specific read behavior and must not receive Task-only actions.

Forbidden on a normal tap: showing management chips/menu, editing, deleting, registering to device Calendar, changing time, completing a record, creating a Task, or producing another external Calendar event.

## 3. Long press action menu

Long press on a supported Arvin-owned item opens a contextual menu with only actions supported by that item and available callbacks:

- Edit Task
- Register/sync with device Calendar (only if not already registered or the operation is an idempotent update)
- Manage Reminder
- Change date/time
- Delete (with explicit confirmation for destructive removal)
- Other supported actions appropriate to the item type

The menu must be contextual and typed. A Follow-up action must not masquerade as a Reminder action. A Reminder operation must not mutate Follow-up history or `nextFollowUp`. Task recurrence occurrences must resolve to the existing canonical Task and preserve recurrence identity.

If an operation is unavailable or the item is read-only, do not display an inert action.

## 4. Item type labeling

Calendar item cards and Task Detail must distinguish at minimum:

- Task / due occurrence
- Follow-up (پیگیری)
- Reminder (یادآور)
- Recurrence occurrence
- Imported device Calendar item
- Prayer / Daily Content where applicable

Do not infer semantic type from a generic title alone. Use canonical IDs/source metadata. Keep `nextFollowUp` (next action/review time) independent from Reminder notification time.

## 5. Safety and data integrity

- Short tap must be side-effect-free except navigation.
- Long press must not also fire short-tap navigation.
- Editing must retain the existing Task ID and must not create a duplicate Task.
- Registering an item to external Calendar must be idempotent and preserve stable event identity.
- Repeated opening/menu display must not create Events.
- Deleting one Reminder must not delete its Task, Follow-ups or sibling Reminders.
- Deleting a Follow-up must not delete a Reminder or Task.
- Destructive operations require an explicit confirmation.
- The gesture must coexist with scrolling, horizontal calendar navigation and the small-screen layout.

## 6. Acceptance tests

### Test 1 — normal Task tap
Given an Arvin-owned Task item in day, week or month view, when the user taps it once, then the canonical Task Detail for the same Task ID opens. No action menu or management chip is displayed.

### Test 2 — long press Task
When the user long-presses the item, then a typed contextual action menu appears. No edit/delete/register action executes until the user selects it.

### Test 3 — long press Reminder
When the user long-presses a Reminder item, then Reminder-specific actions are offered. The menu does not mutate Follow-up status, history or `nextFollowUp`.

### Test 4 — short tap has no management side effects
Tap alone must not edit, delete, complete, register, reschedule, convert or create anything. No duplicate external Calendar Event is created.

### Test 5 — edit existing Task
Select Edit from the long-press menu. Saving changes updates the same Task ID. Task count and stable Calendar event identity remain unchanged.

### Test 6 — Follow-up identity
Tap and long press a Follow-up projection. The UI clearly labels it Follow-up and resolves actions to the existing parent Task and exact Follow-up ID. Reminder data remains independent.

### Test 7 — recurrence identity
Open and edit a recurrence occurrence. The occurrence opens its existing parent Task and does not create a duplicate Task or a duplicate Calendar Event.

### Test 8 — read-only/imported items
External Calendar, prayer and Daily Content entries only show actions appropriate to their source; no canonical Task-only action is shown without an exact canonical target.

### Test 9 — gestures and viewport
Verify on a small Android viewport and in day, week and month views: Tap/Long Press distinction, menu bounds, RTL/Persian text, scroll and swipe coexistence, and no accidental action.

### Test 10 — regression
Run Calendar widget tests, Task Detail navigation tests, reminder projection/identity tests, Calendar Provider acceptance, and relevant device smoke lanes on the exact final commit.

## 7. Current code reality (audit, not a pass)

Inspected `lib/calendar_page.dart` and `test/calendar_runtime_actions_fast_track_test.dart` on the working branch.

- Initial implementation now routes a normal tap on recognized Arvin Task/Follow-up/Reminder items to canonical Task Detail, and the selected item type is passed into the detail app bar.
- Task management actions were moved out of the card body and into a long-press bottom sheet; deleting a Task from this menu asks for confirmation.
- Long press on a calendar item now opens the contextual action menu. Long press on a date cell still creates a Task for that date; this is a separate date-cell gesture and should be validated not to interfere with item scrolling/navigation.
- The existing test named “Arvin Task primary actions are visible before expansion” asserts the old behavior and must be replaced with the new acceptance contract rather than weakened.
- The current `CalendarPage` callback surface has edit/delete/register callbacks but no explicit canonical Task Detail open callback. The wiring through `official_calendar_page.dart`, `widgets/canonical_calendar_launcher.dart` and the owning route must be traced before implementation.
- Calendar labels now distinguish Task due dates (موعد کار), Reminder (یادآور), and Follow-up (پیگیری) using item ID prefixes rather than titles. Task Detail receives the selected item type; recurrence items receive a separate label.
- Code and acceptance tests were updated in commits through code head `a9c5b7d6c68548fa78e3dbfaf035a9eeb04ffff3`. GitHub Build, Calendar Provider Acceptance and Device Smoke for this code wave were pending/queued at last poll; no passing result is claimed. No screenshots or physical-device evidence have been captured yet.

## 8. Required implementation sequence

1. Trace canonical Task Detail navigation and exact ID resolution through the existing Calendar owner/launcher. Reuse the existing route; do not create a second detail page or data store.
2. Add a typed item action contract and canonical open callback to the existing Calendar flow.
3. Replace tap-to-expand with tap-to-open; move all management operations behind long-press contextual actions. Preserve a reachable, accessible alternative for devices where long press is difficult, without making it the normal-tap behavior.
4. Ensure Reminder, Follow-up and recurrence actions are typed and resolve to stable canonical IDs. Make device Calendar registration idempotent.
5. Replace the old “actions visible before expansion” test with the acceptance tests above. Keep meaningful assertions; do not remove tests simply to make CI green.
6. Run relevant tests, Analyze/build, Calendar Provider acceptance and device smoke on the exact final SHA. Current test changes cover Tap vs Long Press, menu actions, delete confirmation and distinct item labels; their result is pending. Capture small-screen day/week/month evidence and record links/screenshots only when actually available.
7. Update this document with commit SHA, run URLs, test outcomes, and genuine screenshots. Keep release status NO-GO until all relevant gates pass.

## 9. Evidence ledger

- Source inspected: `lib/calendar_page.dart` (working branch at audit time).
- Existing test inspected: `test/calendar_runtime_actions_fast_track_test.dart`.
- Existing wiring candidates to inspect: `lib/official_calendar_page.dart`, `lib/widgets/canonical_calendar_launcher.dart`, and the owning route in `lib/main.dart`.
- Screenshots: **not yet captured**.
- Automated acceptance: **not yet run for this decision**.
- Physical-device acceptance: **not yet evidenced**.

## 10. Final rule

**Tap: enter the Task. Long press: manage the item.**
Calendar displays and navigates; canonical Task data and lifecycle remain owned by Task.
