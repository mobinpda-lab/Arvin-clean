# Arvin Canonical UI Reference

## Status
Accepted product/UI reference. Detailed governance is controlled by `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0.

This file is the **index of binding UI contracts**, not a replacement for their detailed acceptance criteria. A generic Material implementation is not acceptable when a more specific owner-approved surface contract exists.

## Binding surface contracts

Before changing a product surface, read the most specific applicable contract:

- Home / Dashboard: `docs/HOME_STYLE_LOCK.md`
- Follow-up-enabled Task detail + add FollowUp flow: GitHub Issue #357
- Notebook / Simple Note / Checklist: `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md`
- Follow-up Calendar: `docs/FOLLOWUP_CALENDAR_UX_CONTRACT_2026-08-27.md` when merged/current; live GitHub status outranks a stale branch copy
- Cross-surface acceptance registry: `docs/PRODUCT_CONTRACT_MATRIX.md`

When a new owner-approved visual/interaction decision is accepted, it must be added to the Product Contract Matrix and linked here if it defines a primary surface.

## Core UI

AppShell / primary product surfaces include:
- Home / Dashboard
- Task detail
- FollowUp history and entry
- ReminderCard
- FollowUpCard
- Jalali Calendar
- Notebook / Simple Note / Checklist
- Report/PDF/Print surfaces
- Notification/Widget surfaces

## Protected Rules

- Persian RTL-first presentation.
- Calm hierarchy and low visual noise.
- Approved navigation, typography, spacing and component behavior remain stable.
- No UI redesign without explicit owner approval, design review, RTL verification, UX impact review and documentation.
- Current APK screenshots are runtime evidence; they do not automatically replace an accepted canonical design.
- A working backend/service does not count as UI completion when the accepted user interaction is missing.
- Splitting delivery into migration/parallel slices must not silently drop a deferred interaction; the Product Contract Matrix remains open until the final user path is wired and validated.

## Home Contract

`docs/HOME_STYLE_LOCK.md` is binding for Home. In particular, do not replace its approved header/search/stat cards/task cards/compact circular add action/bottom navigation with an easier generic layout.

## Task / FollowUp Contract

Issue #357 is binding until superseded by a newer explicit owner decision:
- Task create/edit exposes explicit `کار پیگیری‌دار` state.
- Home task tap opens task detail rather than jumping directly into edit.
- A follow-up-enabled Task detail exposes a round bottom `+` to append a FollowUp.
- Add FollowUp pre-fills system date/time, both editable.
- blank FollowUp text is valid and canonicalizes to `پیگیری`.
- save appends to existing canonical `followUps[]`; history is never erased by UI conversion/toggle behavior.
- Home shows the latest canonical FollowUp date/time.

## Notebook Contract

- «یادداشت ساده» and «چک‌لیست» are distinct UX entry modes.
- Both reuse canonical `Task / TaskStore / arvin.tasks`; no Note/checklist storage path may be created solely for UI separation.
- A simple-note editor should remain visually simple and should not show checklist controls by default.

## Reminder Contract

- `یادآور` label with smaller time beside it when a time exists.
- All-day reminders must not display a fabricated time.
- Reminder title is shown below.
- Expandable details/actions are supported where approved.
- Quick actions: complete, snooze, edit, convert to Task where the product contract permits.
- Lock Screen/widget behavior must remain consistent with the approved concept and platform capability.

## Migration Direction

UI migration is incremental and must preserve existing working behavior while moving toward accepted canonical designs. Meaningful UI changes require appropriate widget/regression tests plus RTL and device/visual validation.

A deferred user interaction is not considered delivered merely because its domain model, service, persistence, or reusable page exists.
