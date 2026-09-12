# Arvin Canonical UI Reference

## Status
Accepted product/UI reference. Detailed governance is controlled by `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0.

This file is the **index of binding UI contracts**, not a replacement for their detailed acceptance criteria. A generic Material implementation is not acceptable when a more specific owner-approved surface contract exists.

## Latest recovery authority — 2026-09-12

GitHub Issue #845 and `docs/ARVIN_RECOVERY_WAVE0_EXACT_MAIN_AUDIT_2026-09-12.md` are the newest explicit owner-approved recovery overlay. They supersede older UI wording only where they directly conflict; the approved Arvin visual identity remains protected.

Current binding corrections:

- Home must no longer show the visible `کارهای من` title/options. Those filters/categories move under `بیشتر`.
- `کار امروز` is an automatic canonical due-date Task view; prayer entries and official events are excluded from Task counters.
- where `یادداشت` was used as the label for a work item merely because it had no FollowUp, use `بدون پیگیری`; this does **not** rename the real Notebook/Note concept.
- Task `+` / quick entry and full create/edit converge on one canonical editor behavior: title-only save is allowed and optional details remain available without creating another Task path.
- Notebook recovery targets a calm full-screen/near-full-screen content editor with category/actions at the top and easy same-ID move/delete while preserving canonical Notebook persistence.
- Project/Category/Tag, Calendar sync/actions, prayer state/reporting, Backup and font controls must reuse their existing foundations as mapped by Recovery Waves #847–#852.

Older screenshots/contracts remain traceability evidence. In particular, an older requirement for a visible `کارهای من` Home section is superseded by the explicit 2026-09-12 owner decision.

## Binding surface contracts

Before changing a product surface, read the most specific applicable contract:

- Recovery owner ledger and newest corrections: GitHub Issue #845 + `docs/ARVIN_RECOVERY_WAVE0_EXACT_MAIN_AUDIT_2026-09-12.md`
- Final owner decision for Home + Reminder Widget + Simple Note/To-do: `docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md`, except where superseded by the 2026-09-12 recovery overlay
- Home / Dashboard: `docs/HOME_STYLE_LOCK.md`, except the superseded visible-`کارهای من` placement rule
- Follow-up-enabled Task detail + add FollowUp flow: GitHub Issue #357
- Notebook / Simple Note / Checklist: `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md` + Recovery Wave #850 for the newest editor/layout requirement
- Follow-up Calendar: `docs/FOLLOWUP_CALENDAR_UX_CONTRACT_2026-08-27.md` when merged/current; live GitHub status outranks a stale branch copy
- Contextual Calendar/Notebook/Backup help: `docs/CONTEXTUAL_GUIDES_2026-08-27.md`
- Cross-surface acceptance registry: `docs/PRODUCT_CONTRACT_MATRIX.md`

When a new owner-approved visual/interaction decision is accepted, it must be added to the Product Contract Matrix or a newer explicitly indexed recovery overlay and linked here if it defines a primary surface.

## Core UI

AppShell / primary product surfaces include:
- Home / Dashboard
- Task detail
- FollowUp history and entry
- ReminderCard
- FollowUpCard
- Jalali Calendar
- Notebook / Simple Note / Checklist
- Quick Capture / unified Task entry behavior
- Project/taxonomy management surfaces
- Report/PDF/Print surfaces
- Notification/Widget surfaces
- First-run/contextual help and in-app User Guide

## Protected Rules

- Persian RTL-first presentation.
- Calm hierarchy and low visual noise.
- Approved navigation, typography, spacing, color language and component behavior remain stable unless a newer explicit owner decision changes a specific part.
- No broad UI redesign without explicit owner approval, design review, RTL verification, UX impact review and documentation.
- Current APK screenshots are runtime evidence; they do not automatically replace an accepted canonical design.
- A working backend/service does not count as UI completion when the accepted user interaction is missing.
- Splitting delivery into migration/parallel slices must not silently drop a deferred interaction; the Product Contract Matrix/recovery ledger remains open until the final user path is wired and validated.
- Help/onboarding is part of the product UI. It must not teach a superseded navigation, header action or creation flow.
- Recovery work must reuse canonical storage/models/services and must not create a second architecture merely to satisfy a visual change.

## Home Contract

The owner-supplied Arvin dashboard reference remains the final Home visual direction. Microsoft To Do is only a secondary source of small UX inspiration and is **not** the Home structure/color authority.

The 2026-09-12 recovery decision changes the information placement while preserving the visual identity:

- remove the visible `کارهای من` heading/options from Home;
- move the work filters/categories into `بیشتر`;
- keep Home focused on the approved dashboard hierarchy, current work/list content and compact primary add action;
- preserve the approved header/search/stat-card/task-card/bottom-navigation composition and indigo-led color language unless a later explicit owner decision changes it;
- expose `کار امروز` through canonical due-date semantics, not reminder/prayer/official-event timestamps.

Home identity safeguards:
- `بسم الله الرحمن الرحیم` and the product title remain the protected identity block.
- Backup is not a Home-header action.
- Quick Capture/selection utilities must not displace the approved identity/header hierarchy.
- Quick entry remains a fast input to the same canonical Task path and must converge with the owner-approved unified Task editor behavior; it must not create a parallel model/storage foundation.
- final visual acceptance requires applicable device/screenshot comparison with the owner-supplied Arvin reference while also verifying the newer placement decisions.

## Task / FollowUp Contract

Issue #357 remains binding where not superseded by newer #845 interaction decisions:
- Task create/edit exposes explicit `کار پیگیری‌دار` state.
- Home task tap opens task detail rather than jumping directly into edit where the detail contract applies.
- A follow-up-enabled Task detail exposes a round bottom `+` to append a FollowUp.
- Add FollowUp pre-fills system date/time, both editable.
- blank FollowUp text is valid and canonicalizes to `پیگیری`.
- save appends to existing canonical `followUps[]`; history is never erased by UI conversion/toggle behavior.
- Home shows the latest canonical FollowUp date/time.

Recovery Wave #848 additionally requires create/edit behavior to support title-only quick save and full optional details through one canonical editor path. This is a UX convergence requirement, not permission to duplicate Task storage or erase the existing detail/FollowUp contract.

## Notebook Contract

- «یادداشت ساده» and «چک‌لیست / To-do» remain distinct UX entry modes.
- Both reuse canonical `Task / TaskStore / arvin.tasks`; no Note/checklist storage path may be created solely for UI separation.
- A simple-note editor remains visually simple and does not show checklist controls by default.
- category/notebook grouping is visible and easy to reach; the newest recovery target places category/actions at the top of a full-screen/near-full-screen content-first editor.
- selecting a category immediately reassigns the same canonical Task through `Task.category`; do not clone or duplicate the note.
- delete/move actions should be easy to reach while still respecting Trash/soft-delete/data-safety rules.
- Joplin is a behavioral UX reference for notebook/category organization only; Arvin keeps its own canonical Flutter/Task architecture.

## Navigation Contract

Current verified shared implementation uses `خانه | تقویم | دفترچه | اقدام بعدی | بیشتر` through `ArvinPrimaryNavigation`.

The 2026-09-12 owner decision specifically makes `بیشتر` the home of the work-list filters/categories formerly shown as `کارهای من` on Home. It does not, by itself, change the five primary destinations above.

A future destination/order change requires an explicit owner-approved product decision and must update the applicable UI contract, Product Contract Matrix/recovery ledger, navigation tests and all user-facing help together.

## Help / Onboarding Contract

Arvin currently has distinct help concepts and they must not be conflated:
- first-run Home coach-marks may appear according to the dedicated seen-state contract;
- Calendar/Notebook/Backup contextual help is user-requested only per `docs/CONTEXTUAL_GUIDES_2026-08-27.md`;
- `UserGuidePage` is a read-only teaching surface and must match the current approved Home/navigation/workflows.

If UI/navigation changes, outdated help text or illustrations keep the related acceptance row **Partial** until reconciled. In particular, help must not teach a visible Home `کارهای من` filter block after Recovery Wave #848 lands, must not reintroduce Backup in the Home header, an obsolete extended primary add action, or an obsolete Calendar-as-launcher navigation model.

## Reminder / Widget Contract

`docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md` remains binding for reminder/widget hierarchy:

- `یادآور` is a type label; reminder content is the stronger main text.
- timed reminders show real time as accent metadata.
- all-day reminders show `تمام‌روز` and must not display a fabricated time.
- collapsed and expanded cards preserve a rounded light surface and clear reminder icon/hierarchy as platform space allows.
- expanded actions: complete, snooze, edit, convert to Task where permitted.
- Lock Screen/widget behavior remains consistent with approved semantics and platform capability.

Calendar-facing complete/snooze behavior reported broken by the owner is tracked as a recovery regression in #849 and cannot be treated as complete merely because reminder action services exist.

## Migration Direction

UI migration is incremental and must preserve existing working behavior while moving toward accepted canonical designs. Meaningful UI changes require appropriate widget/regression tests plus RTL and device/visual validation.

A deferred user interaction is not considered delivered merely because its domain model, service, persistence, reusable page or help text exists. Recovery status is governed by #845 and Waves #846–#853 until final convergence closes the ledger.
