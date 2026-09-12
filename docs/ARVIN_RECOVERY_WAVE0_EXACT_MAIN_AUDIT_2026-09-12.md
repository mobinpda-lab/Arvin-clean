# Arvin Recovery Wave 0 — Exact-main audit

Date: 2026-09-12  
Parent ledger: #845  
Wave owner: #846  
Audited baseline: `main` `5a228b6edb4f35f10fb1a6059a5ff3ab3b3cefe0`

## Purpose

This is the durable Wave 0 reconciliation layer for the owner requirements recorded in #845. It separates four things that had become mixed together in older Arvin documents:

1. a capability that already exists in canonical code;
2. a capability whose foundation exists but whose final UI/integration is incomplete or inaccessible;
3. a genuinely missing owner interaction;
4. a historical contract that has been superseded by a newer explicit owner decision.

The rule for all later Waves is **recover/reuse first; extend only the canonical implementation; never create a parallel Task, Notebook, Calendar, Project, Settings or Backup architecture.**

## Authority correction introduced by #845

The 2026-09-12 owner decisions in #845 are newer than the August Home/Notebook screenshots/contracts where they conflict.

The important Home conflict is explicit:

- older Home material required a visible `کارهای من` section on Home;
- the current owner decision removes the visible `کارهای من` title/options from Home and moves its filters/categories under `بیشتر`;
- this changes **information placement**, not Arvin's approved indigo-led identity, dashboard hierarchy, cards, Persian RTL direction or overall design language;
- Microsoft To Do remains interaction inspiration only and is not the visual authority for Arvin Home.

Historical files remain preserved as lineage. They must not be silently edited to pretend the older decision never existed.

## Exact-main requirement reconciliation

Status vocabulary:

- **Existing + verified foundation** — canonical implementation and focused tests/evidence are present; final installed UX may still be checked in a later Wave.
- **Existing + hidden/partial** — important code already exists, but the owner path is incomplete, inaccessible, stale or contradicted by current UI.
- **Partial** — some pieces exist, but meaningful implementation work remains.
- **Missing** — no adequate current owner path was found and the owning Wave must implement it.
- **Superseded** — an older product decision is no longer authoritative.
- **Deferred** — intentionally not part of the current recovery/release scope.

| #845 area | Exact-main finding | Status | Evidence / canonical reuse | Owning recovery Wave |
| --- | --- | --- | --- | --- |
| 1. Product identity | Task, FollowUp, Notebook/Note, Calendar, Report and Project foundations all exist. Arvin must not be reduced to a simple todo list. | **Existing + partial integration** | `lib/models/task.dart`, canonical FollowUp services, `CanonicalNotebookRepository`, Calendar services, report surfaces, ProjectPlan services | W0 governance + W7 convergence |
| 2. Home / More | Current `lib/main.dart` still renders visible `کارهای من`. Shared `بیشتر` navigation already exists, but the newest owner placement is not implemented. | **Partial / current UI conflicts with newest decision** | `lib/main.dart`; `ArvinPrimaryNavigation`; older `HOME_STYLE_LOCK.md` is superseded only for this placement rule | **W2 #848** |
| 3. `کار امروز` | Canonical due-date/list-scope machinery exists, including Today/Future/Overdue projections and Move-to-Today. Final owner-facing `کار امروز` placement under More and counter isolation must be reconciled. | **Existing + partial** | `Task.dueDate`, `TaskDueScopeService`, Home scope services, `TaskMoveToTodayService` | **W2 #848** |
| 4. Unified Task quick/full entry | Canonical Task editor exists, but Quick Capture remains a separate interaction surface. Owner now wants one editor behavior for title-only quick save and full details/edit. | **Partial** | `lib/task_editor_dialog.dart`, `lib/quick_capture_dialog.dart`, canonical Task write path | **W2 #848** |
| 5. Task editor fields/selectors | Project/category integration and many scheduling fields already exist. Compact unified selectors and complete field availability require UX reconciliation. | **Existing + partial** | `TaskEditorDialog`, `ProjectSelectorField`, `HomeTaskEditorContextService`, due/reminder/recurrence foundations | **W1 #847 + W2 #848** |
| 6. Project first-class grouping | Project domain, page, lifecycle, assignment and Task editor selector already exist. Project deletion with contained Tasks is blocked. Full owner-facing lifecycle/Settings/Note relationship still needs closure. | **Existing + hidden/partial** | `lib/models/goal_project.dart`, `lib/projects_page.dart`, `TaskProjectAssignmentService`, `ProjectSelectorField`; project lifecycle tests | **W1 #847** |
| 7. Dependency-safe deletion | Project dependency protection is already proven. Equivalent complete Category/Tag/Project lifecycle semantics are not yet uniformly proven across all surfaces. | **Partial** | `ProjectDeleteBlocked`; `project_lifecycle_service_test.dart`; taxonomy work from #371 | **W1 #847** |
| 8. Dynamic Category/Tag/Project management | Canonical Category/Tag fields and lifecycle work exist, but Settings/menu management and safe referenced-delete behavior remain incomplete as one coherent user path. | **Partial** | `Task.category`, `Task.tags`, taxonomy services/UI slices; no new store permitted | **W1 #847** |
| 9. Device calendar two-way sync | Android Calendar Provider discovery/read/write, sync planning, external-link metadata and idempotent executor foundations exist. Current launcher/help still describes selecting/exporting an eligible FollowUp, which is narrower than the newest owner requirement. Full continuous bidirectional user path is not closed. | **Existing + partial** | `SystemCalendarBridge`, `CalendarProviderSyncExecutor`, external event links, #348/#516 | **W3 #849** |
| 10. Calendar day/week/month/year navigation | Current Calendar has explicit view-mode machinery and day/week/month UI. The owner requires complete previous/next swipe behavior in day/week/month/year plus `امروز`; year and all navigation acceptance remain incomplete. | **Partial** | `lib/calendar_page.dart`, existing date navigation services/tests | **W3 #849** |
| 11. Calendar `انجام شد` / `تعویق` | Reminder/FollowUp action foundations exist and previous fixes route canonical actions, but the installed build was observed by the owner to have non-working Calendar actions. Treat as a live regression until exact current behavior is proven. | **Partial / regression suspected** | canonical reminder action routing and FollowUp writes must be reused; no second action engine | **W3 #849** |
| 12. Official occasions/holidays | Iranian official holiday source and Calendar integration already exist in repository history/current code. Owner did not see the expected occasions in the installed app, so visibility/data coverage is a recovery issue, not permission to build another Calendar source. | **Existing + hidden/partial** | `iranian_official_holiday_source.dart`, official calendar surfaces | **W3 #849** |
| 13. Prayer-time state/report/counter isolation | Prayer calculation source and additive completion projection already exist. Full visible done/not-done workflow, reports and strict exclusion from every general Task statistic still require acceptance. | **Existing + partial** | `iranian_prayer_time_source.dart`, `PrayerCompletionProjection`, existing report foundation | **W5 #851** |
| 14. Notebook full-screen/top-category UX | Canonical Notebook exists and same-ID category reassignment is already delivered. The new owner requirement for content-first full-screen/near-full-screen editing, top category/actions and immediately reachable delete/move is not complete. | **Existing + partial** | `lib/notebook_page.dart`, `CanonicalNotebookRepository.updateCategory`, same-ID tests | **W4 #850** |
| 15. Notebook capabilities | Simple Note/Checklist, autosave/edit and canonical persistence exist. Project association, complete bulk operations, final global-search/convert behavior and the newest editor layout require reconciliation. | **Partial** | `CanonicalNotebookRepository`, `Task.isSimpleNote`, `Task.checklist`, Notebook tests, bulk foundations | **W4 #850** |
| 16. Backup/Restore + automatic backup | Backup/restore foundations, schedule page, notification channel and tests exist. The installed product did not expose the complete previously requested settings, so this is primarily recovery/wiring/completion rather than a new backup architecture. | **Existing + hidden/partial** | `lib/backup_schedule_page.dart`, backup manager/services, backup notification service/tests | **W6 #852** |
| 17. Font/appearance selection | `AppSettingsService.fontFamily` and global theme consumption exist; VazirHarf is the current canonical default. A user-facing multi-font picker with preview/size and persistence is not fully exposed in the installed product. | **Existing foundation + missing/partial UX** | `AppSettingsService`, `theme/app_fonts.dart`, app ThemeData; requested open-source font set is owned by W6 | **W6 #852** |
| 18. Owner UI reference | Canonical Home/Notebook/Reminder UI contracts exist, but newer #845 placement/editor decisions supersede parts of older wording. Final acceptance must compare actual user paths, not merely classes or screenshots. | **Partial** | `ARVIN_UI_CANONICAL.md`, owner UI decision docs, Home Style Lock plus this recovery overlay | **W2/W4/W7** |
| 19. Anti-forgetting / recovery governance | Requirement-loss rules, Product Contract Matrix, autonomous queue, production loop and the new 5-minute Recovery Wave Controller exist. This becomes complete only when #845 has a final state/evidence for every requirement. | **Existing + active** | #845, #846–#853, Recovery Wave Controller, Product Contract Matrix | **W0 + W7 #853** |

## Canonical foundations that later Waves MUST reuse

### Task / FollowUp
- `TaskStore/arvin.tasks` is the canonical persistence path.
- Existing `Task`, FollowUp history, due date, reminders, recurrence, search, timeline and safe-write boundaries are retained.
- A UI recovery must never create another Task database or erase FollowUp history.

### Notebook
- `CanonicalNotebookRepository` is backed by canonical Task storage.
- Historical `arvin.simple_notes` proposals are superseded.
- Simple Note and Checklist may have distinct UX modes without becoming separate persistence models.
- Category move changes the same canonical identity.

### Project / taxonomy
- Reuse ProjectPlan/current Project services and Task membership/assignment services.
- Category, Tag and Project are semantically distinct.
- Existing Project dependency protection is the minimum safety standard to extend to taxonomy lifecycle.

### Calendar
- Reuse provider-neutral Android Calendar Provider bridge, planning/executor and external-link mapping.
- Official holiday and prayer rows are Calendar content, not Tasks.
- No Google-only/Samsung-only duplicate Calendar engine is permitted.

### Settings / fonts
- Extend `AppSettingsService`; do not add feature-specific settings stores.
- VazirHarf remains the public/default fallback unless a newer explicit owner decision changes it.
- Additional font assets/downloads require license/packaging review.

### Backup
- Extend the existing canonical backup/restore envelope and scheduling boundaries.
- Dropbox remains out of scope for v1 under the current owner release policy unless explicitly promoted later.

## Accepted capabilities outside #845 that must not regress

Recovery work also preserves these already accepted Arvin capabilities; they do not become disposable merely because #845 focuses on another set of corrections:

- Task detail / FollowUp detail / append-history path (#357).
- Reminder/widget hierarchy and all-day semantics (#361 and canonical UI docs).
- Quick Capture canonical persistence and zero-write cancel acceptance (#341), even while W2 reconciles its interaction with the unified editor requirement.
- Bulk Task/Note actions and safe batch mutation (#367), reused by W1/W4.
- Safe Back/autosave/no-silent-data-loss behavior (#370).
- Category/Tag lifecycle work (#371), folded into W1 rather than duplicated.
- Independent FollowUp reminder (#372).
- Jalali report/PDF/Print/Share date semantics (#373).
- Search, Timeline, Next Action, People relations, Widget/Lock Screen, report/PDF/Print and notification foundations already represented in the Product Contract Matrix.
- Bidirectional provider work #348/#516, folded into W3 rather than replaced.
- Multi-device sync remains tracked separately and must not be confused with Android Calendar sync.
- Smart Multi-Instance FollowUp (#613) remains post-RC unless a newer owner decision promotes it.

## Explicit scope / supersession decisions

### Superseded only where explicitly stated
- Visible `کارهای من` on Home: superseded by #845; filters move to `بیشتر`.
- The narrow UX mental model “select a FollowUp and export it to the device calendar” is insufficient for the current owner target. The underlying provider foundation remains reusable.
- A separate Notebook database/storage proposal remains superseded by canonical Task-backed Notebook.

### Deferred / out of current v1 recovery scope
- Dropbox remote integration/auth/data transfer remains out of scope for v1.
- Voice/AI/OCR/general attachment/collaboration/advanced analytics remain post-v1 unless explicitly promoted.
- Physical-phone-only evidence may be recorded `NOT VERIFIED / Deferred` under current release policy; emulator/device-smoke and all non-physical acceptance remain required.

## Ordered execution ownership

- **W0 #846:** this reconciliation, authority correction and anti-forgetting map.
- **W1 #847:** Project + Category/Tag/Project dependency-safe lifecycle.
- **W2 #848:** Home/More/Today + unified Task entry/edit.
- **W3 #849:** Calendar navigation, bidirectional device integration, action bugs, official events.
- **W4 #850:** Notebook full-screen/top-category/action/move/delete UX.
- **W5 #851:** Prayer completion/report/statistical isolation.
- **W6 #852:** Backup scheduling/restore + font picker + grouped Settings.
- **W7 #853:** combined regression, exact-final-main proof and #845 closure.

## Wave 0 exit rule

Wave 0 may close only when:

1. this audit is merged on current main;
2. `ARVIN_UI_CANONICAL.md` explicitly records the newer Home/Notebook recovery authority where it conflicts with older UI wording;
3. `DOCUMENT_AUTHORITY_INDEX.md` points to #845, this audit and the ordered Waves;
4. every #845 requirement has exactly one visible status and owning Wave;
5. exact-head CI for the documentation reconciliation is green;
6. no product behavior is falsely marked complete merely from the presence of a class, branch, old PR or stale scorecard.
