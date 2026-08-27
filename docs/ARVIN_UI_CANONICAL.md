# Arvin Canonical UI Reference

## Status
Accepted product/UI reference. Detailed governance is controlled by `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0.

This file is the **index of binding UI contracts**, not a replacement for their detailed acceptance criteria. A generic Material implementation is not acceptable when a more specific owner-approved surface contract exists.

## Binding surface contracts

Before changing a product surface, read the most specific applicable contract:

- Final owner decision for Home + Reminder Widget + Simple Note/To-do: `docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md`
- Home / Dashboard: `docs/HOME_STYLE_LOCK.md`
- Follow-up-enabled Task detail + add FollowUp flow: GitHub Issue #357
- Notebook / Simple Note / Checklist: `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md`
- Follow-up Calendar: `docs/FOLLOWUP_CALENDAR_UX_CONTRACT_2026-08-27.md` when merged/current; live GitHub status outranks a stale branch copy
- Contextual Calendar/Notebook/Backup help: `docs/CONTEXTUAL_GUIDES_2026-08-27.md`
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
- Quick Capture
- Report/PDF/Print surfaces
- Notification/Widget surfaces
- First-run/contextual help and in-app User Guide

## Protected Rules

- Persian RTL-first presentation.
- Calm hierarchy and low visual noise.
- Approved navigation, typography, spacing, color language and component behavior remain stable.
- No UI redesign without explicit owner approval, design review, RTL verification, UX impact review and documentation.
- Current APK screenshots are runtime evidence; they do not automatically replace an accepted canonical design.
- A working backend/service does not count as UI completion when the accepted user interaction is missing.
- Splitting delivery into migration/parallel slices must not silently drop a deferred interaction; the Product Contract Matrix remains open until the final user path is wired and validated.
- Help/onboarding is part of the product UI. It must not teach a superseded navigation, header action or creation flow.

## Home Contract

`docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md` + `docs/HOME_STYLE_LOCK.md` are binding for Home.

The owner-supplied Arvin dashboard reference is the final Home direction. Microsoft To Do is only a secondary source of small UX inspiration and is **not** the Home structure/color authority.

In particular, do not replace the approved header/search/stat cards/task cards/compact circular add action/bottom navigation or indigo-led color system with an easier generic layout.

Home identity safeguards:
- `بسم الله الرحمن الرحیم` and the product title remain the protected identity block.
- Backup is not a Home-header action.
- Quick Capture/selection utilities must not displace the approved identity/header hierarchy.
- Quick Capture remains a fast input to the same canonical Task path; it must not create a parallel model/storage/UI foundation.
- final visual acceptance requires real-device comparison with the owner-supplied Home reference.

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

- «یادداشت ساده» and «چک‌لیست / To-do» are distinct UX entry modes.
- Both reuse canonical `Task / TaskStore / arvin.tasks`; no Note/checklist storage path may be created solely for UI separation.
- A simple-note editor should remain visually simple and should not show checklist controls by default.
- both surfaces expose a clear edit action and category selector.
- selecting a category immediately reassigns the same canonical Task through `Task.category`; do not clone or duplicate the note.
- Joplin is a behavioral UX reference for notebook/category organization only; Arvin keeps its own canonical Flutter/Task architecture.

## Navigation Contract

Current verified shared implementation uses `خانه | تقویم | دفترچه | اقدام بعدی | بیشتر` through `ArvinPrimaryNavigation`.

This records current implementation reality, not permission to change product navigation silently. A future destination/order change requires an explicit owner-approved product decision and must update Home Style Lock, Product Contract Matrix, navigation tests and all user-facing help together.

## Help / Onboarding Contract

Arvin currently has distinct help concepts and they must not be conflated:
- first-run Home coach-marks may appear according to the dedicated seen-state contract;
- Calendar/Notebook/Backup contextual help is user-requested only per `docs/CONTEXTUAL_GUIDES_2026-08-27.md`;
- `UserGuidePage` is a read-only teaching surface and must match the current approved Home/navigation/workflows.

If UI/navigation changes, outdated help text or illustrations keep the related acceptance row **Partial** until reconciled. In particular, old guide imagery must not reintroduce Backup in the Home header, an obsolete extended primary add action, or an obsolete Calendar-as-launcher navigation model.

## Reminder / Widget Contract

`docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md` is binding for reminder/widget hierarchy.

- `یادآور` is a type label; reminder content is the stronger main text.
- timed reminders show real time as accent metadata.
- all-day reminders show `تمام‌روز` and must not display a fabricated time.
- collapsed and expanded cards preserve a rounded light surface and clear reminder icon/hierarchy as platform space allows.
- expanded actions: complete, snooze, edit, convert to Task where permitted.
- Lock Screen/widget behavior must remain consistent with the approved semantics and platform capability.

## Migration Direction

UI migration is incremental and must preserve existing working behavior while moving toward accepted canonical designs. Meaningful UI changes require appropriate widget/regression tests plus RTL and device/visual validation.

A deferred user interaction is not considered delivered merely because its domain model, service, persistence, reusable page or help text exists.
