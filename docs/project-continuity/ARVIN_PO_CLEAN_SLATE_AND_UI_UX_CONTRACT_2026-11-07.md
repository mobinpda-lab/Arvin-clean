# ARVIN — Product Owner Directive: Clean-Slate DB & Unified UI/UX Contract
**Decision date:** 2026-11-07  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Governing issue:** [#823](https://github.com/mobinpda-lab/Arvin-clean/issues/823)  
**Implementation lane:** PR [#3052](https://github.com/mobinpda-lab/Arvin-clean/pull/3052)  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Release:** **BLOCKED — RELEASE: NO-GO**  
**PR invariant:** OPEN / DRAFT / UNMERGED

## 1. Binding product-owner decision — clean-slate database

The product owner confirms that production has zero end-users and all existing installations are internal staging/test instances. Structural schema and model refactoring is explicitly authorized on the implementation branch.

Authorized:
- Alter, drop, or recreate Drift/SQLite tables as required by the approved canonical schema; no legacy migration compatibility overhead is required for the internal test dataset.
- Permanently eliminate deprecated/dead schema and model fields, including Next Follow-up scheduling and `followUpEnabled`.
- Establish canonical models and persistence boundaries for `Task`, `TaskReminder`, `FollowUpRecord`, and the Unified Person Entity.
- Remove obsolete columns, queries, serializers, UI controls, and tests that encode retired behavior only when replacement coverage preserves or improves acceptance.

Safety and evidence:
- This authorization is for structural refactoring; it does not mean a database operation has already run.
- Confirm the actual schema and all references before destructive DDL. Keep changes confined to the authorized branch.
- Do not delete, skip, bypass, or weaken tests. Replace obsolete assertions with positive canonical-contract coverage.
- Preserve the distinction between Task due date, independent Task reminders, recurrence projections, and historical Follow-up records.
- A Follow-up is historical only; it must not carry future scheduling state.
- A responsible person must use a real canonical persisted person relationship; do not infer an assignee from unrelated people.

## 2. Scope reconciliation under Issue #823

Issue #823 is expanded by this explicit owner decision to include the four unified UI/UX contracts below as prerequisites for a stable local Device Smoke APK. This is a narrow scope exception to the previous feature freeze, limited to:
1. Home
2. Calendar
3. Task Details / unified form / timeline
4. Universal filters and local Sync architecture documentation

The P2P Sync implementation remains limited to Phase 1 documentation and architecture audit (P2P-0). It must not block local UI/UX smoke stabilization. No cloud-sync implementation is authorized by this decision.

## 3. Home — canonical UI contract

- Header hierarchy: artistic Na'staliq/Naskh Bismillah centered above Arvin; title **آروین**; subtitle **مدیریت کارها، یادداشت‌ها و پیگیری‌ها**.
- Hamburger menu at physical right; global filter icon at physical left.
- No notification or search icons in the header.
- Search bar remains below the header.
- A strict single RTL row contains, in order, Time, Center, Projects, Categories, Tags, then Sort. Must fit 360–412dp devices without wrapping into a second row.
- Time-group headers show dynamic Persian full dates alongside the group title (example: **امروز — پنج‌شنبه ۱۴ آبان ۱۴۰۵**).
- Grouping is based strictly on Task Due Date, not reminder time, follow-up time, or last update.

## 4. Calendar — canonical UI contract

- Exact centered phrase at the top: **أُفَوِّضُ أَمْرِي إِلَى اللَّهِ**.
- Top bar: search loupe on physical right; today's full date and Go to Date picker on physical left.
- Triple-date display: Jalali centered and bold; Gregorian on right; Islamic Lunar on left.
- Lunar date offset is configurable in app preferences.
- View switcher: Daily, Weekly, Monthly, Yearly.
- Bottom content filters: All, Arvin Calendar, Device Calendar, Reminders, Uncompleted.
- Calendar source boundaries remain explicit; external deletion must never delete an internal Arvin Task.

## 5. Task Details, unified edit form, and timeline

- Tapping the header edit pencil changes the current screen into edit mode in place; no route/page jump.
- Five top summary cards: Time, Center, Project, Category, Tag.
- Structured sections:
  1. Main identity: title, status badge, priority, description.
  2. Due Date.
  3. Responsible Person using the Unified Person Entity.
  4. Independent Reminders.
  5. Recurrence.
  6. Checklist with isolated Create/Read/Update/Delete behavior.
  7. Last Follow-up.
  8. Vertical historical Follow-up Timeline.
- Task, TaskReminder, recurrence, and FollowUpRecord remain independent canonical concepts.
- Follow-up history is immutable in meaning: editing its note must not rewrite its historical completion timestamp.
- Do not display or persist deprecated Next Follow-up scheduling fields.

## 6. Universal multi-select filters

Reusable component contract: `ReusableMultiSelectFilterBottomSheet`.

- Reuse across applicable screens instead of maintaining divergent filter implementations.
- Checkbox-based multi-select.
- OR logic among selected values within the same dimension.
- AND logic between different dimensions.
- Inline creation is supported; a newly created value is automatically selected.
- Active selection count badges are shown.
- Filter dimensions include the applicable Time, Center, Project, Category, and Tag dimensions; screen-specific source/content filters remain semantically distinct.

## 7. Local P2P Sync — Phase 1 / P2P-0 only

- Strictly separate local P2P architecture from cloud sync.
- Three calendar layers:
  1. Internal Arvin calendar.
  2. Local Arvin calendar provider using `ACCOUNT_TYPE_LOCAL`.
  3. External calendar, View-Only.
- Deleting an external event must never delete an internal Arvin Task.
- Phase 1 deliverable is documentation/architecture audit only. P2P-0 is not a blocker for local UI/UX Device Smoke.

## 8. Governance and acceptance evidence

- Work only on `fix/recovery-calendar-device-smoke-2026-10-31` through PR #3052.
- PR #3052 must remain OPEN / DRAFT / UNMERGED.
- Direct mutations to `main`, branch merges, release, and publication are forbidden.
- No tests may be deleted or weakened.
- Record exact branch HEAD SHA, changed files, test results, CI workflow/run/job conclusions, artifacts, and Device Smoke progress.
- Physical-device evidence must identify Samsung SM-A528B/DS and include inspectable run/artifact evidence. A source test or emulator result is not physical-device acceptance.
- All PASS claims must be tied to the exact candidate SHA. Missing or stale evidence is NOT VERIFIED.
- P2P-0 documentation status is tracked separately and cannot block local UI/UX smoke.
- Release remains **BLOCKED — RELEASE: NO-GO** until all required release gates pass on one exact candidate SHA and owner acceptance is recorded.

## 9. Implementation status at decision recording

This file records the binding product decision and acceptance contract. It does not claim that the source audit, schema refactor, UI implementation, CI, APK build, or Samsung physical-device smoke has completed. Those results must be appended with exact SHA and evidence after execution.
