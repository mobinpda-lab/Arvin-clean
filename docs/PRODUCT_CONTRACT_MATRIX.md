# Arvin Product Contract Matrix

## Canonical ontology — owner decision 2026-10-10

Exactly three taxonomy domain entities are valid throughout Arvin: **Project / پروژه**, **Category / دسته**, and **Tag / برچسب**. «گروه» is only an alternate Persian word for Category and must not be represented as an independent entity. Category and Tag are distinct. Home's Time / Project / Category / Tag controls are filters/views, not four domain entities. Display-only grouping (such as Tasks grouped by due date) remains allowed. No Group model, store, repository, migration, manager, or parallel taxonomy is allowed. This rule applies to code, persisted data, selectors, menus, filters, Notebook, Calendar, reports, help, tests and documentation.


## Purpose

This matrix prevents accepted product behavior from disappearing when implementation is split across migration, parallel or infrastructure slices.

It is a **discovery and acceptance registry**. It does not replace detailed contracts. GitHub reality, the most specific owner-approved contract, canonical code, tests and exact-head/device evidence must still be checked before claiming completion.

Audit baseline when this file was created: `main` `df325a42523ef657344bb5173b32ae5e6b8c8221` on 2026-08-27.

Live reconciliation refresh: 2026-09-08, based on current main lineage including `5cc493118d05a5988ffc344379a38af2693bfffe`; later merges still require revalidation before final release acceptance.

## Status meanings

- **Missing** — accepted behavior is not implemented on current main.
- **Partial** — foundation or part of the user path exists, but accepted interaction/evidence is incomplete.
- **Implemented** — user path exists; final regression/device/visual acceptance is still open.
- **Validated** — applicable automated + exact-head/device evidence exists; only wider roadmap/handoff closure may remain.
- **Done** — detailed contract Definition of Done is closed and current handoff/status agrees.
- **Deferred** — explicitly disabled or postponed by an owner decision; no implementation work should proceed until that decision changes.

## Permanent Brand Requirement — UI/UX Gate

The following is a non-removable Arvin brand requirement and must be preserved by every future UI/UX implementation, redesign, migration and release acceptance:

- stable identity/header area at the top of primary pages, with Home mandatory;
- **بسم الله الرحمن الرحیم** in a calm, respectful RTL presentation with generous whitespace and harmony with **#4A4CAB**;
- this identity placement is brand identity, not decorative copy, and may not be removed, hidden, replaced or relocated;
- Home must preserve **مدیریت کارها و پیگیری آروین**, the four primary filter/view controls **زمان / پروژه / دسته / برچسب**, simple daily-use hierarchy, Arvin indigo identity, custom Bottom Navigation and Persian personal-assistant character;
- **Report Center remains a separate surface** and must not be absorbed into Home;
- final screenshots/APK visual acceptance must explicitly check this brand gate.

Canonical detail: `docs/ARVIN_UI_CANONICAL.md` and `docs/HOME_STYLE_LOCK.md`.

## Matrix

| Surface / capability | Binding behavior | Binding source | Canonical foundation | Current main entry point | Acceptance evidence required | Current status | Owner issue / next gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Home visual identity | Current owner-approved Home target: Bismillah + centered product title, approved utility icons, rounded search, exactly four filter/view controls (`زمان`, `پروژه‌ها`, `دسته‌ها`, `برچسب‌ها`) without counters, canonical task content, compact add action and bottom navigation; indigo-led colors are part of the contract. The older visible `کارهای من`/stat-card placement is superseded. Microsoft To Do is secondary inspiration only, not the Home authority. | `docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md` + `docs/HOME_STYLE_LOCK.md` | canonical Task projections | `lib/main.dart` | widget filters + short/normal viewport + **real-device screenshot comparison to owner reference** | **Implemented** | canonical Home structure and grouping path are present; real-device screenshot/visual closure remains |
| Home header actions | notification + navigation hierarchy must preserve the approved identity block; Backup is not a Home-header action; Quick Capture/selection utilities must not displace identity | owner UI decision + `docs/HOME_STYLE_LOCK.md` | Home action routing | `lib/main.dart` | header regression + real screenshot | **Implemented** | current main keeps notification/menu hierarchy and removes Backup from the header; real-device visual closure remains |
| Quick Capture | fast minimal entry into the same canonical Task path; later detail/edit uses normal Task flow; no second model/storage; discoverable without replacing approved Home identity | owner conversation + Quick Capture contract/scorecard evidence + Home Style Lock | `QuickCaptureDialog`, `TaskMigrationWriter`, canonical Task | Home quick-capture action | parser/widget/persistence regression + Home visual placement + device | **Implemented** | add final visual/discoverability acceptance; keep no-duplicate-path guard |
| Task create/edit | title, description, tags; explicit `کار پیگیری‌دار` control for follow-up-enabled work | Issue #357 | `Task`, `TaskStore/arvin.tasks` | `lib/task_editor_dialog.dart` | toggle regression + migration/history preservation | **Validated** | #357 completed; preserve canonical same-Task conversion regression |
| Ordinary Task detail | tapping Home card opens read/view detail; edit is a separate action | Issue #357 | canonical Task | `lib/task_detail_page.dart` via canonical Home route | widget navigation + device flow | **Validated** | #357 completed; retain Home→detail navigation regression |
| Follow-up-enabled Task detail | normal back + history/detail + round bottom `+` for a new FollowUp | Issue #357 | `Task + followUps[] + TaskTimelineService` | canonical Task detail/timeline path | detail navigation + add button + device viewport | **Validated** | #357 completed with exact-head acceptance |
| Add FollowUp | optional text + date + time; system current date/time prefilled and editable; blank text saves as `پیگیری` | Issue #357 | `FollowUp`, `FollowUpRepository` | `lib/follow_up_entry_page.dart` | fixed-clock widget tests + blank/default + persistence append | **Validated** | #357 completed; append-only history remains canonical |
| FollowUp history | every save appends; previous history never erased | Issue #357 + canonical timeline docs | `followUps[]`, `FollowUpRepository.add`, `TaskTimelineService` | repository + timeline | persistence regression + chronological UI | **Validated** | #357 completed; preserve append/history invariants |
| Home latest FollowUp | follow-up-enabled card shows latest canonical FollowUp Jalali date + Persian time | Issue #357 | `Task.legacyHomeFollowUpDate` compatibility projection preferring `followUps[]` | `lib/main.dart` | multiple FollowUps regression + visual check | **Implemented** | #357 final acceptance styling |
| Reminder widget/card hierarchy | rounded light card; circular reminder icon; `یادآور` as type label; reminder title/content stronger below; real time as accent metadata; collapsed + expanded forms follow owner reference | `docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md` | canonical Reminder/FollowUp + widget bridge | in-app reminder surfaces + Android widget/keyguard | widget semantics + short/normal viewport + real-device screenshot comparison | **Partial** | align current widget/card presentation to owner reference and validate device rendering |
| Reminder expanded actions | expanded reminder exposes `انجام شد`, `تعویق`, `ویرایش`, `تبدیل به کار` where product state permits | owner UI decision + `docs/ARVIN_UI_CANONICAL.md` | canonical Reminder/Task conversion path | reminder/widget actions | action regression + no-data-loss/device flow | **Partial** | verify each action is wired consistently across applicable surfaces |
| Reminder all-day semantics | all-day reminder displays `تمام‌روز`; never fabricates a clock value; approved teal/green accent may distinguish all-day | owner UI decision + Reminder contract | canonical all-day reminder semantics | reminder/widget surfaces | all-day regression + visual check | **Implemented** | final widget visual acceptance remains |
| Simple Note creation | explicit `یادداشت ساده` mode, simple text-focused editor, autosave/read-only/edit; no checklist block by default | Notebook contract + owner UI decision | `Task.isSimpleNote`, `CanonicalNotebookRepository` | `lib/notebook_page.dart` | mode-specific widget test + autosave/persistence | **Validated** | current widget tests prove text-focused mode, autosave/edit and no checklist controls |
| Simple Note category move | category/notebook selector visible; selecting a category immediately reassigns the **same Task identity** by updating canonical `Task.category`; no duplicate note/store; no extra confirm solely for category change | `docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md` | `Task.category`, `CanonicalNotebookRepository`, `TaskStore/arvin.tasks` | `lib/notebook_page.dart` + `CanonicalNotebookRepository.updateCategory` | `test/notebook_page_test.dart` same-id move + persistence regression | **Validated** | delivered by #365; keep same-id/no-copy regression |
| Checklist / To-do creation | explicit separate `چک‌لیست / To-do` mode; presets allowed; reuse `Task.checklist`; editor stays distinct from Simple Note | Notebook contract + owner UI decision | `Task.checklist`, canonical repository | `lib/notebook_page.dart` | create/add/toggle/edit/remove + persistence | **Implemented** | separate visual editor/mode refinement |
| Checklist / To-do category move | same immediate category reassignment behavior as Simple Note; preserve checklist and Task identity | owner UI decision | `Task.category` + `Task.checklist` + `CanonicalNotebookRepository` | shared notebook editor category selector | same-id category move + checklist preservation regression | **Implemented** | shared canonical category path is present; retain checklist-preservation acceptance |
| Notebook persistence | no `arvin.simple_notes`; use canonical `TaskStore/arvin.tasks` only | Notebook contract + `docs/NOTEBOOK_COMPLETION_LANE_2026-08-26.md` | `CanonicalNotebookRepository`, `TaskStore` | services + notebook | repository key regression | **Validated** | keep duplicate-storage guard |
| Joplin-inspired notebook/category UX | Joplin is a behavioral reference for notebook organization/category reassignment/search/editing only; Arvin keeps its Flutter/Task architecture; any code reuse requires separate license/fit review | owner UI decision | Arvin canonical Task/category fields | notebook UX design/implementation | architecture review + no duplicate model/store | **Partial** | use as UX reference; do not import competing architecture |
| Search | Persian search uses one canonical Task search path; no second engine/UI | roadmap + semantic search docs | `TaskSearchService` / Home projection | Home search | focused + exact-head + device | **Validated** | final roadmap DoD only |
| Follow-up Calendar | Persian RTL, Jalali header, day/week/month behavior per approved contract | `docs/FOLLOWUP_CALENDAR_UX_CONTRACT_2026-08-27.md` when merged/current | canonical Calendar/FollowUp projections | Calendar page/launcher | navigation/count/viewport + exact-head/device | **Implemented** | PR #352 is merged and current code/tests cover RTL, Jalali, Today, day/week/month navigation; exact current-main/device evidence remains |
| Reminder | preserve timed/all-day semantics; no fabricated all-day time | owner UI decision + `docs/ARVIN_UI_CANONICAL.md` + reminder contracts | canonical Reminder/FollowUp foundation | reminder/calendar surfaces | regression + notification/device | **Implemented** | roadmap/device closure varies by slice |
| Waiting for response | explicit FollowUp state and latest-state user filter | feature contract/evidence in scorecard | canonical FollowUp result/state | FollowUp entry/office | regression + exact-head | **Validated** | final roadmap closure |
| Automatic FollowUp | due projection, scheduling/rescheduling/background delivery reuse same canonical data | feature evidence in scorecard | FollowUp + scheduler | due office/background services | exact-head + APK/device/post-merge | **Validated** | final roadmap closure |
| Timeline | one read-only chronological projection from canonical timestamps/history; no second history store | `docs/CANONICAL_TASK_TIMELINE_2026-08-26.md` | `TaskTimelineService` | `lib/task_timeline_page.dart` | regression + real entry point/device | **Implemented** | #357 detail integration improves original product path |
| People / Contacts | relation stays on canonical Task; no standalone CRM/storage | People contract/evidence | `PersonReference` on Task | `lib/task_people_page.dart` | Android E2E + exact-head/post-merge | **Validated** | final roadmap handoff closure |
| Next Action | deterministic canonical ranking, no duplicate task store | Next Action contract | canonical Task/FollowUp | `lib/task_next_action_page.dart` | UI + device/roadmap closure | **Implemented** | final feature DoD |
| Widget / Lock Screen | same Task identity/source; no widget database; graceful platform behavior; reminder information hierarchy follows owner reference as platform space allows | canonical Android widget docs + owner UI decision | `arvin.tasks` + widget bridge | native provider + Flutter bridge | real launcher/keyguard/resize/row-tap + visual comparison | **Implemented** | physical-device + final reminder-card visual acceptance remains |
| PDF / Print | shared canonical projection, RTL Persian output, no data fork | PDF/Print docs | task report projection | report page/renderer | physical print/share/device | **Implemented** | physical acceptance remains |
| Backup / Restore | portable versioned canonical bytes; safe validation before mutation; same Task data | backup portability/security contracts | existing backup service/manager | Backup UI/services | corruption/wrong-passphrase/no-mutation + cross-device | **Implemented** | final physical/recovery closure |
| Encrypted backup | versioned authenticated envelope; no passphrase persistence; legacy plaintext read | privacy/encryption contracts | canonical backup bytes | backup/security surfaces | exact-head/device + tamper/wrong passphrase | **Validated** | final roadmap closure |
| System/Google Calendar | only approved events; avoid duplicates in real sync; manual export remains separate | Calendar sync contracts | canonical FollowUp revision/link plan | `SystemCalendarBridge` + `CalendarProviderSyncExecutor` + minimal external link metadata | permission/revocation/idempotency/E2E | **Implemented** | #793 merged with exact-head Build/Device; #348 remains open for provider create→no-op→update→delete emulator acceptance/limitation evidence |
| Multi-device Sync | deterministic revision/merge/conflict/apply; no last-write-wins or second Task model | Sync contracts | canonical Task revisions/TaskStore | sync services/active lanes | remote transport + durable state + user conflict UI + E2E | **Partial** | #345/#351 stack and follow-on lanes |
| Task list scopes / sorting / Move to Today | All / Notes / Follow-up-enabled plus Today / Future / Overdue scopes; sort by date/latest/title with direction toggle; Move to Today mutates the same canonical Task `dueDate`; search remains available across relevant scopes | owner legacy brief reconciliation in #358 + #369 | `Task.dueDate`, canonical Task projections, `TaskMoveToTodayService`, search service | Home/list scope controls | projection + same-id mutation + search availability + RTL/device | **Implemented** | Issue #369 is closed as completed and current Home/list scope, sorting and Move-to-Today services are present; final discoverability/device evidence remains |
| Safe Back autosave / explicit Cancel | Task / FollowUp / Note / Checklist editing preserves safe-exit/autosave behavior on Back where contracted while explicit Cancel remains a zero-write path | owner legacy brief reconciliation in #358 | existing canonical editors/repositories | Task/FollowUp/Notebook editors | Back/Cancel regression + persistence/no-mutation tests | **Validated** | #370 completed; preserve zero-write Cancel and no-data-loss regressions |
| Category + Tag lifecycle | create/assign/reassign/manage categories and tags on canonical Tasks without parallel stores; coordinate with Notebook and bulk-selection flows | owner legacy brief reconciliation in #358 | `Task.category`, `Task.tags`, canonical editors/repositories | Home/Task/Notebook/bulk surfaces | same-id persistence + lifecycle + bulk assignment regression | **Implemented** | Issue #371 is closed as completed and current taxonomy management is wired to canonical Task category/tag fields; final cross-surface/device evidence remains |
| Independent FollowUp reminder | each canonical FollowUp may carry its own reminder independently of Task reminder and other FollowUps; no parallel reminder store | owner legacy brief reconciliation in #358 | canonical `FollowUp.reminderDate` + reminder delivery/projection services | FollowUp editor/calendar/work agenda | per-FollowUp persistence + scheduling + no-cross-talk + device notification | **Implemented** | #372 owns final end-to-end/device acceptance |
| Jalali PDF / Print / Share dates | all user-visible Task report dates render Persian/Jalali through the shared report path; no Gregorian user-visible dates in final output | owner legacy brief reconciliation in #358 + #373 | shared Task report projection/PDF renderer + `PersianDateFormatter` | report/PDF/Print/Share surfaces | renderer regression + valid PDF bytes + device/share/print acceptance | **Validated** | #373 completed; physical print/share target remains deferred by current owner policy |
| Primary navigation / More | one shared primary navigation; current implementation is `خانه`, `تقویم`, `دفترچه`, `اقدام بعدی`, `بیشتر`; no duplicate/debug destinations; an implementation change does not become a binding product decision without explicit approval | Home/UI contracts + current implementation; future owner decisions supersede | existing shell/navigation | `lib/widgets/arvin_primary_navigation.dart` | destination/order widget tests + cross-page device navigation + visual lock | **Implemented** | keep current reality documented; explicitly record any future owner-approved destination/order change |
| First-run Home guide | Home coach-marks may teach core first-run actions and persist a seen flag; must match current Home labels/actions and not revive stale header/navigation | existing Home guide implementation + Home Style Lock | `InteractiveGuideService`, `HomeInteractiveGuide` | `lib/main.dart` Home first-run path | first-run/seen/reset tests + copy/target regression | **Implemented** | reconcile wording/targets whenever Home contract changes |
| Contextual page help | Calendar/Notebook/Backup help opens only when requested by user; shared Persian RTL help component; closing help changes no product data | `docs/CONTEXTUAL_GUIDES_2026-08-27.md` | shared contextual-help component | Calendar/Notebook/Backup help actions | hidden-until-request + open/close + no-mutation contract tests | **Implemented** | keep distinct from first-run auto Home coach-marks |
| In-app User Guide | all screenshots/illustrations/instructions must teach the current binding Home/navigation/workflow; must not show superseded Backup-header or old launcher paths | Home Style Lock + owner UI decision + Product Contract Matrix + current approved surface contracts | read-only help content | `lib/user_guide_page.dart` | guide text/visual contract tests against current labels/navigation | **Deferred** | owner rule #1785 currently keeps the in-app User Guide/help entry points disabled; do not re-enable or modify until explicit owner instruction |

## Mandatory use rule

Before a meaningful product/UI change:
1. locate the row here;
2. read the binding source and current code;
3. verify whether a newer owner decision exists in GitHub;
4. update the row when acceptance status or owning Issue/PR changes;
5. do not mark **Done** until the detailed contract, tests, exact-head evidence and applicable device/visual acceptance agree.

If an accepted behavior is deferred to a later slice, the row must remain **Missing** or **Partial** and must name an owning issue. A deferred requirement may not silently disappear from the project because its foundation was merged.

## Help/onboarding consistency rule

User-facing help, onboarding, illustrations and coach-marks are product surfaces. When a binding UI/navigation contract changes, their copy/visuals/tests must be reconciled in the same acceptance wave or remain explicitly **Partial**. A stale guide must never teach a superseded workflow.


## Wave 5.48 — Capability inventory and acceptance state

**Product source baseline:** `4214101dd9a93542783fb97eb0d4a5cb34643950`. **Separate CI candidate:** `52781290a159f1836ebe23d719a8856408c3e52f` ([Build workflow](https://github.com/mobinpda-lab/Arvin-clean/blob/52781290a159f1836ebe23d719a8856408c3e52f/.github/workflows/build.yml), [Device Smoke workflow](https://github.com/mobinpda-lab/Arvin-clean/blob/52781290a159f1836ebe23d719a8856408c3e52f/.github/workflows/device-smoke.yml)). Code presence and acceptance are separate; this inventory is not release approval.

### A. Implemented and has historical acceptance evidence

| Capability | Source / implementation | Acceptance evidence | Open gap / next action | Evidence limit |
|---|---|---|---|---|
| Core Task create/edit and FollowUp append-only history | [Task model](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/models/task.dart) | Existing matrix rows record historical validation for canonical Task/FollowUp paths | Revalidate same Task ID, append-only history, persistence and restore on integrated candidate | Prior acceptance is not current-head integrated acceptance |
| Canonical Task ownership for Notes/Checklist | [Task model](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/models/task.dart); existing Notebook/Task rows above | Historical repository/widget regressions are recorded in the matrix | Preserve identity and complete current nine-lane Device Smoke | No claim of current full smoke acceptance |

### B. Implemented but not fully accepted

| Capability | Direct source | Current acceptance state | Next action | Limitation |
|---|---|---|---|---|
| SQL Persistence | [TaskStore / Drift](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/services/task_store.dart) | IMPLEMENTED_NOT_VERIFIED for integrated candidate | Run all required tests; prove same Task reload after process restart | Code/unit tests do not prove installed-device durability |
| SQL Migration | [Migration writer](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/services/sql_task_migration_writer.dart) and [focused test](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/test/services/sql_task_migration_writer_test.dart) | IMPLEMENTED_NOT_VERIFIED on current candidate | Verify legacy-to-SQL migration, idempotence and no data loss | No new migration test result claimed here |
| Repeat / Occurrence model | [Recurrence model](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/models/recurrence.dart) and [repository](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/services/task_recurrence_repository.dart) | Model/history exists; complete UI/report acceptance incomplete | Verify seven planned occurrences, immutable past history and per-occurrence checklist state | Source alone does not prove installed UI renders every planned occurrence |
| Restart / PID replacement | [Restart script](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/scripts/ci/run-device-smoke.sh) and [Task lifecycle test](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/integration_test/android_task_lifecycle_smoke_test.dart) | Mechanism implemented; new nine-lane run not terminal | Require old PID absent, new PID differs, launcher status OK and same Task data after restart | Previous run 39530698590 omitted Task lifecycle |
| Backup / Restore | [Backup manager](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/backup_manager.dart) and [Backup UI](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/backup_page.dart) | Code/rollback regressions exist; physical acceptance blocked | Real file-picker export/import; compare same Task ID, checklist/history, settings and Calendar-link metadata | Emulator/test doubles are not physical provider evidence |
| Notifications | [Scheduler](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/android_automatic_follow_up_scheduler.dart) and [notification sink](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/follow_up_reminder_notification_service.dart) | Implemented; OS delivery/tap/cold-start not fully accepted | Verify permissions, delivery, tap target, cold start and duplicate delivery on device | Service initialization is not end-to-end acceptance |
| Persian PDF / RTL | [PDF renderer](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/services/task_report_pdf_renderer.dart) and [renderer test](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/test/task_report_pdf_renderer_test.dart) | Renderer exists; visual acceptance NOT VERIFIED | Review a multi-page Persian RTL PDF generated through the actual APK path | Byte tests/substitute fonts do not prove visual correctness |

### C. Partially implemented or defective

| Capability | Source | Open defect / next action | Limitation |
|---|---|---|---|
| Repeat Tracking Level (RTLC) | [Recurrence model](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/models/recurrence.dart) | Complete form integration, Home cue, Report Center filters/metrics and historical-state acceptance | Model enum alone is not complete user-facing delivery |
| Checklist evolution | [Checklist integration test](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/integration_test/android_checklist_evolution_smoke_test.dart) | Prove A/B/C → A/B/D edit, preserve historical snapshots/checkmarks, apply intended future template and prevent duplicate occurrences | Previous 7-lane run omitted this test |

### D. Planned / future integration

| Capability | Current plan | Next action | Limitation |
|---|---|---|---|
| RTLC Home and Report Center integration | Existing product decisions call for simple-first selection and metrics derived only from canonical occurrence/history | Complete only through existing Task/Repeat paths; do not add a parallel model/store | Requirements do not prove delivery |

### E. Blocked

| Gate | Source / record | Blocker | Next action |
|---|---|---|---|
| Exact-SHA Dispatch | [Build](https://github.com/mobinpda-lab/Arvin-clean/blob/52781290a159f1836ebe23d719a8856408c3e52f/.github/workflows/build.yml) and [Device Smoke](https://github.com/mobinpda-lab/Arvin-clean/blob/52781290a159f1836ebe23d719a8856408c3e52f/.github/workflows/device-smoke.yml) at `52781290a159f1836ebe23d719a8856408c3e52f` | `BLOCKED — DISPATCH UNAVAILABLE`; connected tool has no dispatch operation | Dispatch both workflows on the same full SHA through an authorized path; verify every runner and artifact |
| Real Calendar Provider | [Provider executor](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/services/calendar_provider_sync_executor.dart); [acceptance script](https://github.com/mobinpda-lab/Arvin-clean/blob/d9fb7a247037762216662a20fb32028ecc8a0f6b/.github/scripts/calendar-provider-acceptance.sh) | No demonstrated writable-provider CREATE → NO-OP → UPDATE → DELETE on current candidate | Prove same external event ID and no duplicates |
| Official APK certificate acceptance | [Gradle signing guard](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/android/app/build.gradle.kts) | Approved certificate/fingerprint not supplied; current Build `Verify APK` checks only file existence | Obtain authorized secrets/fingerprint; hash actual APK and run `apksigner verify --verbose --print-certs` |
| Physical-device Golden Flow | [Acceptance criteria](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/docs/arvin-memory/ARVIN_ACCEPTANCE_CRITERIA.md) | No current installed-device end-to-end evidence | Run create → edit → Repeat/Checklist → Calendar → notification → Backup/Restore on one identified Task |

### F. Unknown / insufficient current evidence

| Capability | Known state | Next action | Limitation |
|---|---|---|---|
| Duplicate prevention across Task, Repeat and Calendar | Stable-identity guards exist in [CalendarProviderSyncExecutor](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/services/calendar_provider_sync_executor.dart) | Run duplicate create/edit/retry/restore tests and verify one canonical Task and one linked event | No complete current-SHA 9-lane/provider acceptance is attached |
| APK digest and certificate evidence in current Build | Workflow has `Verify APK`, but it only checks file existence | Add/verify a separately reviewed digest/certificate step before release | Do not infer digest or trust from artifact upload |

### G. Possible regressions or signs of missing behavior

| Capability | Direct record | Signal | Next action |
|---|---|---|---|
| Calendar edit / register in phone Calendar | [UX log](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/docs/arvin-memory/ARVIN_USER_EXPERIENCE_LOG.md) and [provider executor](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/services/calendar_provider_sync_executor.dart) | Owner reported missing actions; acceptance remains open | Verify visible actions in installed APK and real provider lifecycle |
| Repeat planned-occurrence rendering | [Recurrence model](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/lib/models/recurrence.dart) and [UX log](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/docs/arvin-memory/ARVIN_USER_EXPERIENCE_LOG.md) | Owner reported recurring Tasks show only current day instead of all promised planned occurrences | Reproduce on installed build; verify seven dates and stable occurrence identity |
| Checklist UI interaction/labels | [Checklist integration test](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/integration_test/android_checklist_evolution_smoke_test.dart) and UX log | Reported clipped labels / checkbox interaction issue remains unaccepted | Validate create/toggle/edit/reopen on compact and normal Android viewports |

**Needs Mobin's decision:** approved official certificate/fingerprint and signing credentials; acceptable writable Calendar Provider/device; whether RTLC Home/Report Center scope is mandatory for this release; final physical-device/visual acceptance. Missing evidence is not a product cancellation.

## Historical-document rule

Older snapshots and superseded design/architecture proposals remain useful evidence, but they cannot override this matrix, a newer explicit product decision, current canonical contracts or verified GitHub reality.

## Canonical taxonomy architecture decision
See `docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md` and Issue #2582. The only taxonomy concepts are Project, Category and Tag. Category/Group is one concept; the standard Persian UI term is «دسته». Home's Time / Project / Category / Tag controls are filters/views, not four taxonomy entities; date-based display grouping is presentation-only. Project, Category and Tag filters remain distinct and combine with AND. No feature-specific taxonomy model or Group entity may be added. Full conformance and legacy wording audit remains open in Issue #2580.
