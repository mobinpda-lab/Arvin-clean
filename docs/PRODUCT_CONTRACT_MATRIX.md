# Arvin Product Contract Matrix

## Purpose

This matrix is the **comprehensive cross-surface product contract and acceptance registry** for Arvin. It prevents accepted product behavior from disappearing when implementation is split across migration, parallel or infrastructure slices.

It does not replace detailed contracts. GitHub reality, the most specific owner-approved contract, canonical code, tests and exact-head/device evidence must still be checked before claiming completion.

**Comprehensive review baseline:** `main` `4e2fe43737a47df2c03fc4a313df387e641c4a1e` on 2026-08-28, after merged #430 and #435 and owner reconciliation for #438.

## Status meanings

- **Missing** — accepted behavior is not implemented on current main.
- **Partial** — foundation or part of the user path exists, but accepted interaction/evidence is incomplete.
- **Implemented** — user path exists; final regression/device/visual acceptance is still open.
- **Validated** — applicable automated + exact-head/device evidence exists; only wider roadmap/handoff closure may remain.
- **Done** — detailed contract Definition of Done is closed and current handoff/status agrees.

## Comprehensive reconciliation checkpoint — 2026-08-28

This review explicitly applies the project rule **reconcile existing capability before adding new capability**.

Verified reusable foundations on current main include:
- canonical `Task`, `FollowUp`, `TaskStore/arvin.tasks` and unified Notebook persistence;
- `TaskReportProjection`, `TaskReportPdfRenderer` and `TaskReportPage` for shared PDF/Print/Share reporting;
- report preselection via `TaskReportPage.initialSelectedIds` (merged #430);
- canonical due-date scopes via `TaskDueScopeService`;
- Home's historical FollowUp-today projection via `HomeTodayProjection`;
- canonical FollowUp scheduling, independent `FollowUp.reminderDate`, reminder due-delivery and delivery metadata foundations;
- official occasions/holidays, prayer times and Daily Content as separate informational Calendar sources rather than Task/FollowUp work data.

Owner request #438 is therefore **not a new report system**. The remaining gap is one read-only day/range **work agenda composition** that combines existing user-work scheduling concepts, de-duplicates canonical identities and feeds the existing report/PDF/Print/Share path. Existing narrow scopes such as `TaskDueScopeService` must keep their current semantics.

## Matrix

| Surface / capability | Binding behavior | Binding source | Canonical foundation | Current main entry point | Acceptance evidence required | Current status | Owner issue / next gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Home visual identity | Owner-supplied Arvin dashboard is the final Home visual target: Bismillah + centered product title, approved utility icons, rounded search, four tappable stat cards, task cards, compact circular `+`, bottom nav; indigo-led colors are part of the contract. Microsoft To Do is secondary inspiration only, not the Home authority. | `docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md` + `docs/HOME_STYLE_LOCK.md` | canonical Task projections | `lib/main.dart` | widget filters + short/normal viewport + **real-device screenshot comparison to owner reference** | **Partial** | final visual spacing/color/card closure remains |
| Home header actions | notification + navigation hierarchy must preserve the approved identity block; Backup is not a Home-header action; Quick Capture/selection utilities must not displace identity | owner UI decision + `docs/HOME_STYLE_LOCK.md` | Home action routing | `lib/main.dart` | header regression + real screenshot | **Partial** | reconcile utility placement with final approved reference |
| Quick Capture | fast minimal entry into the same canonical Task path; later detail/edit uses normal Task flow; no second model/storage; discoverable without replacing approved Home identity | owner conversation + Quick Capture contract/scorecard evidence + Home Style Lock | `QuickCaptureDialog`, `TaskMigrationWriter`, canonical Task | Home quick-capture action | parser/widget/persistence regression + Home visual placement + device | **Implemented** | final visual/discoverability acceptance |
| Task create/edit | title, description, tags; explicit follow-up-enabled control; canonical due date remains independent from Task reminder and FollowUp scheduling | #357 + #375 | `Task`, `TaskStore/arvin.tasks`, canonical editor | `lib/task_editor_dialog.dart` | toggle + due/reminder/history preservation regressions | **Implemented** | #434 is active final due-date editor delivery lane; do not duplicate editor/store |
| Ordinary Task detail | tapping a Task opens read/view detail; edit is a separate action; same canonical Task identity is preserved | #357 | canonical Task | `lib/task_detail_page.dart` | detail navigation + edit regression + device | **Validated** | keep detail/report entry consistent with future changes |
| Follow-up-enabled Task detail | normal detail/history, latest FollowUp state, round add action for a new FollowUp, edit existing FollowUp in place | #357 | `Task + followUps[] + TaskTimelineService + FollowUpRepository` | `lib/task_detail_page.dart` / timeline flow | add/edit/history widget regression + device | **Validated** | reminder delivery integration continues under #372 |
| Add/Edit FollowUp | optional text; blank title saves canonical `پیگیری`; date/time editable; independent reminder timestamp can be set/preserved/cleared without changing FollowUp identity | #357 + #372 | `FollowUp`, `FollowUpRepository` | `lib/follow_up_entry_page.dart` | fixed-clock + blank/default + reminder preservation/clear + persistence | **Validated** | platform notification/single-alarm convergence under #372 |
| FollowUp history | every save appends or explicit edit updates the intended canonical entry; previous history never silently erased | #357 + canonical timeline docs | `followUps[]`, repository, timeline | detail/timeline | persistence + chronological identity regression | **Validated** | preserve full identity in reports/sync |
| Home latest FollowUp | follow-up-enabled card shows latest canonical FollowUp date/time and does not fabricate history from legacy schedule | #357 | canonical `followUps[]` with legacy compatibility projection | `lib/main.dart` | multiple FollowUps + presentation regression | **Validated** | final visual styling only |
| Reminder widget/card hierarchy | rounded light card; reminder type/title/time hierarchy; collapsed + expanded forms follow owner reference; all-day never fabricates clock | owner UI decision + `docs/ARVIN_UI_CANONICAL.md` | canonical Reminder/FollowUp + widget bridge | in-app reminder/widget surfaces | semantics + viewport + real-device screenshot | **Partial** | final visual/device acceptance |
| Reminder expanded actions | expanded reminder exposes applicable complete/snooze/edit/convert actions without data loss | owner UI decision + UI canonical | canonical Reminder/Task path | reminder/widget actions | action regression + device | **Partial** | verify parity across applicable surfaces |
| Reminder all-day semantics | all-day reminder displays `تمام‌روز` and never fabricates a clock value | owner UI decision + Reminder contract | canonical all-day reminder semantics | reminder/widget surfaces | regression + visual | **Implemented** | final visual acceptance |
| Independent FollowUp reminder | each canonical FollowUp may own optional `reminderDate` independent from Task reminder and `nextFollowUp`; delivery metadata is not a second domain store | #372 | `FollowUp.reminderDate`, reminder projection/delivery/state | FollowUp entry + reminder services | JSON/persistence + due/exact-now + delivery identity + notification/device | **Partial** | #431/#432/#433 active convergence lanes; #435 delivery metadata merged |
| Single alarm convergence | automatic FollowUp schedules and independent FollowUp reminders must share one Android scheduling foundation, never parallel alarm engines | #372 + project architecture rules | existing alarm foundation + canonical projections | scheduler/background services | deterministic arbitration + inactive filtering + APK/device | **Partial** | #432 safety guard then #433 arbiter; supersedes standalone planner approach when validated |
| Simple Note creation/edit | explicit simple-note mode; text-focused editor; no checklist block by default; edit/category actions preserve same canonical Task identity | Notebook contract + owner UI decision | `Task.isSimpleNote`, `CanonicalNotebookRepository` | `lib/notebook_page.dart` | create/edit/category/persistence widget tests | **Validated** | keep UI refinement aligned with owner reference |
| Simple Note category move | category selector immediately reassigns the same canonical Task by updating `Task.category`; no duplicate note/store | owner UI decision | `Task.category`, canonical Notebook/TaskStore | notebook category UI | same-id move + persistence + no duplicate | **Validated** | bulk category path should reuse same semantics |
| Checklist / To-do creation | explicit checklist/To-do mode; presets allowed; reuse `Task.checklist`; distinct from Simple Note | Notebook contract + owner UI decision | `Task.checklist`, canonical repository | `lib/notebook_page.dart` | create/add/toggle/edit/remove + persistence | **Implemented** | visual/mode refinement |
| Checklist / To-do category move | same immediate category reassignment behavior as Simple Note; preserve checklist and Task identity | owner UI decision | `Task.category` + `Task.checklist` | notebook category UI | same-id move + checklist preservation | **Implemented** | add explicit checklist-focused regression if missing |
| Notebook persistence | no `arvin.simple_notes`; canonical `TaskStore/arvin.tasks` only | Notebook contract | `CanonicalNotebookRepository`, `TaskStore` | services + notebook | storage-key regression | **Validated** | keep duplicate-storage guard |
| Joplin-inspired notebook/category UX | Joplin is behavioral reference only; Arvin keeps its Flutter/Task architecture | owner UI decision | canonical Task/category | notebook UX | architecture + no duplicate model/store | **Partial** | use only as UX reference |
| Search | Persian search uses one canonical Task search path; no second engine/UI | roadmap + semantic search docs | `TaskSearchService` / Home projection | Home search | focused + exact-head + device | **Validated** | maintain semantic/identity contract |
| Due-date Today / Future / Overdue | these Home scopes are derived **only from `Task.dueDate`**; reminder and FollowUp times must not silently change membership | #375 + current canonical code | `TaskDueScopeService` | Home list projection/stats | today/future/overdue + inactive + read-only tests | **Validated** | do not broaden this service for #438; compose separately |
| Historical Home Today FollowUp view | existing `HomeTodayProjection` selects active Tasks whose canonical/legacy Home FollowUp schedule is on today; it is a narrow historical Home behavior, not a complete daily agenda | current canonical code + historical Today contract | `legacyHomeFollowUpDate` compatibility projection | Home Today drawer/path | projection tests | **Implemented** | #438 must not mistake this for all-work agenda |
| Work agenda — Today / selected day | one work-only daily agenda combines relevant Task due date, Task reminder, FollowUp schedule and independent FollowUp reminder without duplicating canonical Task/FollowUp identity; official occasions/prayer/Daily Content excluded | **#438 owner-approved reconciled contract** | existing Task/FollowUp projections + report foundation | missing unified composition/entry | de-dup + identity + local-day + exclusion + UI/device | **Partial** | #438 — add only unified read-only composition + entry point; reuse existing foundations |
| Work report — date range | select Jalali start/end inclusive; group user work chronologically by day; same projection feeds preview/PDF/Print/Share; no informational Calendar sources | **#438** | same work agenda composition + existing report/PDF | missing range entry/adapter | inclusive boundaries + grouping + RTL/Jalali + no mutation | **Partial** | #438 |
| Follow-up Calendar | Persian RTL, Jalali header, day/week/month behavior per approved contract | FollowUp calendar UX contract + current code | canonical Calendar/FollowUp projections | Calendar page/launcher | navigation/count/viewport + device | **Implemented** | do not merge informational Calendar aggregation into #438 work reports |
| Official occasions / prayer / Daily Content | informational calendar sources remain visible where their own Calendar contracts require; they are **not user work** and must not enter Task/FollowUp work reports | calendar source contracts + #438 | separate Calendar sources | Calendar | source-specific tests + #438 exclusion tests | **Validated boundary** | preserve source separation |
| Reminder | preserve timed/all-day semantics; no fabricated all-day time | owner UI decision + UI canonical | canonical Reminder/FollowUp | reminder/calendar | regression + notification/device | **Implemented** | independent FollowUp reminder platform convergence under #372 |
| Waiting for response | explicit FollowUp state and latest-state user filter | feature contract/evidence | canonical FollowUp result/state | FollowUp entry/office | regression + exact-head | **Validated** | maintain latest-state semantics |
| Automatic FollowUp | due projection, scheduling/rescheduling/background delivery reuse same canonical data | feature evidence + #372 | FollowUp + existing scheduler | office/background | exact-head + APK/device | **Validated foundation** | converge independent reminder on same alarm path |
| Timeline | one read-only chronological projection from canonical timestamps/history; no second history store | canonical timeline docs | `TaskTimelineService` | timeline/detail | regression + entry/device | **Validated** | preserve in reports and sync |
| People / Contacts | relation stays on canonical Task; no standalone CRM/storage | People contract/evidence | `PersonReference` on Task | `lib/task_people_page.dart` | Android E2E + exact-head/post-merge | **Validated** | preserve through edits/backup/report context as applicable |
| Next Action | deterministic canonical ranking, no duplicate Task store | Next Action contract | canonical Task/FollowUp | `lib/task_next_action_page.dart` | UI + device | **Implemented** | final roadmap closure |
| Widget / Lock Screen | same Task identity/source; no widget database; graceful platform behavior | widget docs + owner UI decision | `arvin.tasks` + widget bridge | native provider + Flutter bridge | real launcher/keyguard/resize/tap + visual | **Implemented** | physical-device/final visual acceptance |
| PDF / Print / Share | one canonical Task report projection/renderer; RTL Persian; selected/all/single scopes; preselected IDs may enter report directly; `PdfPreview` provides Print + Share; no data fork | #367 + PDF/Print docs | `TaskReportProjection`, `TaskReportPdfRenderer`, `TaskReportPage` | report page/detail/bulk entry | renderer/page tests + APK/device/physical print as applicable | **Validated foundation** | #438 adapts day/range scope into this path; do not create second renderer |
| Bulk selection / report entry | one/many/all current scope; selected count; clear; same canonical IDs; output opens existing report path with initial selection | #367 | `TaskBulkSelectionService`, shared selection bar, report preselection | shared bulk UI/report | selection + layout + report identity + device | **Partial** | #436/#437 active UI foundations; Home/Notebook wiring + mutations remain |
| Bulk archive/trash/category/tags | selected canonical items mutate in place; category reassigns without copy; tag assignment additive/preserves unrelated tags; safe trash/archive semantics | #367 | `TaskBulkMutationService` + shared UI/dialogs | partial foundations | selected-only mutation + confirmation + persistence + reload | **Partial** | #436 Archive surface; #437 shared category/tag input; final Home/Notebook wiring |
| Backup / Restore | portable versioned canonical bytes; safe validation before mutation; same Task data | backup contracts | backup service/manager | Backup UI/services | corruption/wrong-passphrase/no-mutation + cross-device | **Implemented** | final physical/recovery closure |
| Encrypted backup | authenticated envelope; no passphrase persistence; legacy plaintext read | privacy/encryption contracts | canonical backup bytes | backup/security | tamper/wrong passphrase + device | **Validated** | final roadmap closure |
| System/Google Calendar | only approved events; avoid duplicates in real sync; manual export remains separate | Calendar sync contracts | canonical FollowUp revision/link plan | system calendar bridge/sync lanes | permission/revocation/idempotency/E2E | **Partial** | provider integration remains separate from #438 work report |
| Multi-device Sync | deterministic revision/merge/conflict/apply; no last-write-wins or second Task model | Sync contracts | canonical Task revisions/TaskStore | sync services | transport + durable state + conflict UI + E2E | **Partial** | continue dedicated sync lanes |
| Primary navigation / More | one shared primary navigation; current implementation `خانه`, `تقویم`, `دفترچه`, `اقدام بعدی`, `بیشتر`; no duplicate/debug destinations | Home/UI contracts + current implementation | shell/navigation | `lib/widgets/arvin_primary_navigation.dart` | destination/order tests + device + visual lock | **Implemented** | new report entry must integrate without inventing competing navigation |
| First-run Home guide | coach-marks teach current Home actions and persist seen state; must track current labels/actions | Home guide + Home Style Lock | interactive guide service | Home | first-run/seen/reset + target regression | **Implemented** | reconcile when report/bulk entry changes Home |
| Contextual page help | Calendar/Notebook/Backup help opens only when requested; shared RTL help; no product mutation | contextual guide docs | shared help component | pages | hidden/open/close/no-mutation | **Implemented** | add report help only if needed, without duplicate guide system |
| In-app User Guide | screenshots/instructions must teach current binding Home/navigation/workflow and not revive superseded paths | Home Style Lock + owner decisions + this matrix | read-only help | `lib/user_guide_page.dart` | guide contract tests | **Partial** | reconcile after current Home/bulk/report UX settles |

## Reconcile-before-add rule

For every new owner request or feature:
1. identify existing canonical models, services, UI surfaces and tests that already satisfy part of the request;
2. preserve their narrow semantics when those semantics are intentional (for example `TaskDueScopeService` is dueDate-only);
3. add only the missing composition/user interaction;
4. extend or adapt the existing report/storage/scheduler path instead of creating a parallel path;
5. record any intentionally missing behavior here with an owning Issue.

A request that sounds new does not automatically justify a new model/service/store. Composition over existing canonical foundations is preferred when it preserves clear boundaries.

## Mandatory use rule

Before a meaningful product/UI change:
1. locate the row here;
2. read the binding source and current code;
3. verify whether a newer owner decision exists in GitHub;
4. reconcile the request with existing capability before designing additions;
5. update the row when acceptance status or owning Issue/PR changes;
6. do not mark **Done** until the detailed contract, tests, exact-head evidence and applicable device/visual acceptance agree.

If an accepted behavior is deferred, the row must remain **Missing** or **Partial** and name an owning Issue. A foundation merge may not silently make the user-facing requirement disappear.

## Help/onboarding consistency rule

User-facing help, onboarding, illustrations and coach-marks are product surfaces. When a binding UI/navigation contract changes, their copy/visuals/tests must be reconciled in the same acceptance wave or remain explicitly **Partial**.

## Historical-document rule

Older snapshots and superseded design/architecture proposals remain useful evidence, but they cannot override this matrix, a newer explicit owner decision, current canonical contracts or verified GitHub reality.
