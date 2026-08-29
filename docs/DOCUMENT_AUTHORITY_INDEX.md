# Arvin Document Authority Index

## Why this exists

Arvin has accumulated historical snapshots, migration notes, architecture proposals, product contracts and live-status files. This index prevents a future session from treating an old but authoritative-looking file as current product truth.

GitHub repository reality always outranks narrative documents.

## Authority order

1. **Live GitHub reality** — current `main`, current code, current open/merged PRs/Issues, exact-head workflow evidence.
2. **Newest explicit owner-approved product decision** — binding issue/design/contract for the affected surface.
3. **`docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0** — canonical governance and software-production rules.
4. **Official scorecards** — `docs/project_completion_scorecard.json` for total Arvin; `docs/progress_scorecard.json` for the extension roadmap.
5. **Canonical product/UI indices** — `docs/ARVIN_UI_CANONICAL.md`, `docs/PRODUCT_CONTRACT_MATRIX.md`, and the detailed contract they link.
6. **Implementation-specific current contracts** — current migration/security/calendar/sync/notebook/etc. documents when consistent with the above.
7. **Dated snapshots / handoffs / historical technical records** — context and evidence only; never override live GitHub or newer contracts.

## Active canonical references

| Area | Active reference |
| --- | --- |
| Governance / execution | `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 + Issue #403 for the live Maximum Parallel execution board |
| Whole-project live snapshot | `docs/PROJECT_STATUS.md` (always re-check GitHub before acting) |
| Whole-project progress | `docs/project_completion_scorecard.json` + `docs/PROJECT_PROGRESS_METRIC.md` |
| Extension progress | `docs/progress_scorecard.json` + `docs/PRODUCT_EXTENSION_ROADMAP_2026-08-15.md` |
| Cross-surface product acceptance | `docs/PRODUCT_CONTRACT_MATRIX.md` |
| UI index | `docs/ARVIN_UI_CANONICAL.md` |
| Home | `docs/HOME_STYLE_LOCK.md` |
| Task detail / follow-up-enabled UX | Issue #357 |
| Notebook / Simple Note / Checklist | `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md` + `docs/NOTEBOOK_COMPLETION_LANE_2026-08-26.md` |
| Canonical Timeline | `docs/CANONICAL_TASK_TIMELINE_2026-08-26.md` + current code/evidence |
| Bidirectional Device Calendar Integration | `docs/BIDIRECTIONAL_DEVICE_CALENDAR_INTEGRATION_2026-08-29.md` + Issue #516; Provider execution continues under #348 |
| Report typography | current `TaskReportPdfRenderer` + bundled Vazirmatn UI FD + merged PR #514 evidence |
| Current audit/reconciliation work | GitHub live Issues/PRs; historical Issue #358 remains context only where superseded by newer decisions |

## Calendar authority clarification — 2026-08-29

The newest binding Calendar integration decision is **Bidirectional Device Calendar Integration**.

It supersedes narrower historical wording that described only a Google Calendar export. The current architectural boundary is:

`Arvin ↔ Android Calendar Provider ↔ Google / Samsung / Other compatible calendars`

Key authority rules:

- one provider adapter foundation; no Google/Samsung-specific engine without a later proven requirement;
- Settings only under `تنظیمات → تقویم و همگام‌سازی`;
- existing Work Agenda remains the aggregator foundation;
- external events are read-only projections initially and never auto-convert to canonical Tasks;
- external events remain outside Task Report/PDF/Share/Backup by default;
- existing idempotent sync planning from merged PR #381 must be reused;
- Issue #348 is the existing Android Calendar Provider implementation lane and should not be duplicated.

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

Historical Google-only Calendar proposals remain useful lineage, but they do not override the 2026-08-29 bidirectional device-calendar decision or current Android Calendar Provider architecture.

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

This applies especially to cross-wave requirements such as Task detail UX, Projects integration, Work Agenda outputs and the phased Device Calendar target. A merged Foundation never means the complete product path is Done without the corresponding UI, exact-head evidence and applicable real-device acceptance.
