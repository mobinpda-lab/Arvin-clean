# Calendar Architecture

**Decision:** Calendar is a projection/bridge; canonical Task remains the owner of task identity and scheduling. See [Master Product Operating Protocol (AMPOP)](../constitution/ARVIN_MASTER_PRODUCT_OPERATING_PROTOCOL.md), Issue #2535 and provider umbrella #516.

## Ownership and mapping
- Task remains canonical.
- Calendar view projects Task and recurring scheduled occurrences into dates; projection must not create duplicate canonical Task records.
- External sync reuses existing Calendar Provider bridge and stable mapping: Task ID + external Calendar ID + external Event ID.
- Editing a linked Task should update its existing external event, not create a duplicate.
- Manual actions «ثبت در تقویم گوشی» and «ویرایش» must remain discoverable; automatic sync does not replace explicit user actions.

## Repeat projection
The existing execution protocol documents a rolling projection of up to seven upcoming repeats in the calendar window. This is a product contract to validate against current recurrence implementation; do not infer that it is fully implemented from documentation alone. Repeat count/end date still constrain valid occurrences; do not create a separate Task or Reminder for each repeat.

## Failure and recovery
Handle permission denial, unavailable calendars, removed external events and restore/relink scenarios without corrupting the canonical Task. Avoid silently creating duplicates. Record outcomes and recovery guidance.

## Acceptance / evidence
- [ ] On real Android device, Task edit and phone-calendar actions are visible and work.
- [ ] Create recurrence including the supported seven-occurrence case; verify every expected date in the visible calendar range.
- [ ] Edit Task and prove the same linked external event is updated.
- [ ] Check permissions, event deletion/recovery, recurrence, checklist state and backup/restore relinking.
- [ ] No duplicate Task, Reminder, occurrence record or external event.
- [ ] Capture screenshots and attach exact-head tests/build/device evidence to Issue #2535 / related PR.
- [ ] Do not call Calendar release-ready from CI success alone.
