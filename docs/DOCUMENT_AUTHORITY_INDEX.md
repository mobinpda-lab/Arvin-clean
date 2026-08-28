# Arvin Document Authority Index

## Why this exists

Arvin has accumulated historical snapshots, migration notes, architecture proposals, product contracts and live-status files. This index prevents a future session from treating an old but authoritative-looking file as current product truth.

GitHub repository reality always outranks narrative documents.

## Authority order

1. **Live GitHub reality** — current `main`, current code, current open/merged PRs/Issues, exact-head workflow evidence.
2. **Newest explicit owner-approved product decision** — binding issue/design/contract for the affected surface.
3. **`docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0** — canonical governance, automation and software-production rules.
4. **Official scorecards** — `docs/project_completion_scorecard.json` for total Arvin; `docs/progress_scorecard.json` for the 19-feature extension.
5. **Comprehensive product/UI registry** — `docs/PRODUCT_CONTRACT_MATRIX.md` is the comprehensive cross-surface product contract/status matrix; `docs/ARVIN_UI_CANONICAL.md` is the canonical UI index; detailed contracts remain authoritative for their own surface.
6. **Implementation-specific current contracts** — current migration/security/calendar/sync/notebook/report/etc. documents when consistent with the above.
7. **Dated snapshots / handoffs / historical technical records** — context and evidence only; never override live GitHub or newer contracts.

## Active canonical references

| Area | Active reference |
| --- | --- |
| Governance / execution / automation | `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 + live GitHub Actions/automations |
| Whole-project progress | `docs/project_completion_scorecard.json` + `docs/PROJECT_PROGRESS_METRIC.md` |
| Extension progress | `docs/progress_scorecard.json` + `docs/PRODUCT_EXTENSION_ROADMAP_2026-08-15.md` |
| **Comprehensive cross-surface product contract/status** | **`docs/PRODUCT_CONTRACT_MATRIX.md`** |
| UI index | `docs/ARVIN_UI_CANONICAL.md` |
| Home visual identity | `docs/HOME_STYLE_LOCK.md` + owner UI decision |
| Home list scopes / sorting / Move-to-Today | Issue #369 + current projection/code evidence |
| Safe edit exit / autosave / Back | Issue #370 + current editor/repository evidence |
| Category / Tag lifecycle | Issue #371 + current taxonomy/bulk/notebook evidence |
| Task detail / follow-up-enabled UX | Issue #357 + `docs/FOLLOWUP_FINAL_OWNER_CONTRACT_2026-08-28.md` + current code/evidence |
| FollowUp independent reminder / single alarm convergence | Issue #372 + current code/evidence |
| Due date / Task scheduling | Issue #375 + current code/evidence |
| Bulk selection / PDF / Print / Share | Issue #367 + canonical Task report foundation |
| **Today / selected-day / date-range work agenda and reporting** | **Issue #438** — reconcile with existing report/due/reminder/FollowUp foundations; no second report system |
| Notebook / Simple Note / Checklist | `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md` + current code/evidence |
| Recurrence / Resume From Today | Issue #208 / merged #209 + canonical `Task.recurrence` evidence |
| Prayer Times | merged #197 + current Calendar code/evidence; informational Calendar capability, not work-report data |
| Daily Content | #260-series / merged #261–#266 + bounded-cache evidence; informational Calendar capability, not work-report data |
| Canonical Timeline | `docs/CANONICAL_TASK_TIMELINE_2026-08-26.md` + current code/evidence |
| Widget / Lock Screen | Issue #361 + current Android/Flutter bridge evidence; future Quick FollowUp enhancement tracked separately (#394) |
| Current audit/reconciliation work | Issue #403 + live GitHub reality |

## Two-day reconciliation coverage — 2026-08-27 through 2026-08-28

The comprehensive product matrix must retain traceable coverage for owner decisions and meaningful implementation from the rolling two-day audit, including at minimum:

- approved Home visual direction and Reminder/Widget hierarchy;
- canonical Simple Note / Checklist separation and same-id category reassignment;
- Home scopes and sorting plus the owner-preserved Move-to-Today action (#369);
- safe Back/autosave semantics without overriding explicit Cancel (#370);
- category/tag lifecycle and bulk reuse (#371/#367);
- Task Detail / FollowUp add-edit-history behavior, blank→`پیگیری`, derived elapsed/interval values, newest-first timeline/no-history state, Jalali/Persian timestamps and latest-real-FollowUp semantics;
- independent Task due date, Today/Future/Overdue due scopes, and canonical Home edit application;
- independent FollowUp reminders, delivery state and single-alarm convergence under #372;
- selected/single/all report scopes and the shared PDF/Print/Share path;
- Recurrence / Resume From Today;
- Prayer Times and Daily Content as existing informational Calendar capabilities;
- Widget/Lock Screen canonical identity/deep-link behavior and future Quick FollowUp enhancement;
- Vazirmatn as the canonical production typography, including bundled offline PDF font assets;
- #438 work-only Today/selected-day/date-range agenda/report behavior, explicitly excluding occasions, Prayer Times and Daily Content from work-report composition.

Operational choices such as Maximum Parallel, exact-head Fast → full Build/APK/Device gating, stale-lane reconciliation, superseded-run cancellation and hourly automation belong to `ARVIN_PROJECT_OPERATING_PACKAGE.md`, live workflow configuration and #403. They should be referenced by the product matrix when needed but not duplicated as a competing product feature contract.

## Product reconciliation rule

A new owner request must first be compared with the existing canonical implementation and the Product Contract Matrix. Reuse and composition are preferred over duplicate capability.

Examples:
- date/range work reporting (#438) must reuse the existing `TaskReportProjection` / `TaskReportPdfRenderer` / `TaskReportPage` path rather than create a second PDF/Print/Share system;
- `TaskDueScopeService` remains dueDate-only even though #438 needs a broader daily work agenda; the broader agenda belongs in a separate read-only composition layer rather than changing the meaning of the existing filter;
- official occasions, prayer times and Daily Content remain Calendar information sources and are not user-work report entries.

If the existing foundation covers part of a request, the missing behavior must be recorded as **Partial** rather than reimplemented from scratch.

## Snapshot documents: useful but time-sensitive

These files may describe a real historical checkpoint, but their SHA/PR/percentages can become stale quickly. They must be reconciled with live GitHub before use:

- `docs/AI_CONTINUATION_STATE.md`
- `docs/AI_HANDOFF_CURRENT_FA.md`
- `docs/PROJECT_STATUS.md`
- `docs/ARVIN_STATUS.md`
- `docs/ARVIN_PROJECT_STATE.md`
- dated progress snapshots/logs/audits

A stale snapshot is not an implementation bug by itself; it becomes a bug when someone uses it instead of current GitHub reality.

## Historical / superseded technical records

`PROJECT_DOCUMENTATION_FA.md` at repository root is preserved as an important early technical/history record. Its older `ArvinTask` / `TaskRepository` / early Backup descriptions are **not** the current architecture authority. Do not start new work from that file without first reading v49, current `main`, scorecards, current contracts and code.

Likewise, older v48.x governance documents, old manual percentage snapshots and superseded PR-era plans remain traceability evidence rather than competing active requirements.

## Conflict rule

When two documents disagree:

1. check which one is newer and whether it is explicitly owner-approved;
2. check current code/data migration constraints;
3. check live Issues/PRs and exact-head CI;
4. preserve historical text rather than deleting it;
5. update the active contract/index so the conflict is explicit;
6. open or link an issue for any accepted behavior not yet implemented.

Example: a historical Simple Note proposal used `arvin.simple_notes`; current canonical Notebook deliberately uses `TaskStore/arvin.tasks`. The current canonical contract wins and the historical proposal remains only as lineage.

## Requirement-loss prevention rule

When a product requirement is deferred from one slice to another, the first slice must leave a durable pointer in `docs/PRODUCT_CONTRACT_MATRIX.md` with status **Missing** or **Partial** and an owning Issue. A domain/service/persistence merge may not silently convert the requirement to “done” when the accepted user interaction is still absent.

This rule protects, among other cases, FollowUp-enabled task detail, Home list actions, safe edit exit, taxonomy, bulk operations, independent FollowUp reminders, and the #438 day/range work agenda/report path.
