# Arvin Document Authority Index

## Why this exists

Arvin has accumulated historical snapshots, migration notes, architecture proposals, product contracts and live-status files. This index prevents a future session from treating an old but authoritative-looking file as current product truth.

GitHub repository reality always outranks narrative documents.

## Authority order

1. **Live GitHub reality** — current `main`, current code, current open/merged PRs/Issues, exact-head workflow evidence.
2. **Newest explicit owner-approved product decision** — binding issue/design/contract for the affected surface. As of 2026-09-12, Issue #845 and its Recovery Wave mapping are the newest cross-surface owner recovery decisions where they directly conflict with older wording.
3. **`docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0** — canonical governance and software-production rules.
4. **Official scorecards** — `docs/project_completion_scorecard.json` for total Arvin; `docs/progress_scorecard.json` for the 19-feature extension. Scorecards are evidence/planning registries, never permission to override a newer owner requirement.
5. **Canonical product/UI indices** — `docs/ARVIN_UI_CANONICAL.md`, `docs/PRODUCT_CONTRACT_MATRIX.md`, the 2026-09-12 recovery audit, and the detailed contracts they link.
6. **Implementation-specific current contracts** — current migration/security/calendar/sync/notebook/etc. documents when consistent with the above.
7. **Dated snapshots / handoffs / historical technical records** — context and evidence only; never override live GitHub or newer contracts.

## Active canonical references

| Area | Active reference |
| --- | --- |
| Governance / execution | `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 |
| Current owner recovery ledger | GitHub Issue #845 |
| Ordered recovery execution | `docs/ARVIN_RECOVERY_WAVE_EXECUTION_2026-09-12.md` + Issues #846–#853 |
| Exact-main recovery reconciliation | `docs/ARVIN_RECOVERY_WAVE0_EXACT_MAIN_AUDIT_2026-09-12.md` |
| Whole-project progress | `docs/project_completion_scorecard.json` + `docs/PROJECT_PROGRESS_METRIC.md` |
| Extension progress | `docs/progress_scorecard.json` + `docs/PRODUCT_EXTENSION_ROADMAP_2026-08-15.md` |
| Cross-surface product acceptance | `docs/PRODUCT_CONTRACT_MATRIX.md` + the newer recovery overlay where an older row has not yet been rewritten |
| UI index | `docs/ARVIN_UI_CANONICAL.md` |
| Home | `docs/HOME_STYLE_LOCK.md` + Issue #845/Wave #848 for the newer Home/More placement decision |
| Task detail / follow-up-enabled UX | Issue #357, preserved unless a newer explicit decision changes a specific interaction |
| Project / Category / Tag recovery | Wave #847 + existing Project/taxonomy foundations |
| Notebook / Simple Note / Checklist | `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md` + `docs/NOTEBOOK_COMPLETION_LANE_2026-08-26.md` + Wave #850 for newest editor/layout recovery |
| Calendar/device integration recovery | Wave #849 + #348/#516 + current provider-neutral Calendar foundation |
| Prayer state/report recovery | Wave #851 + current prayer source/completion projection |
| Backup / fonts / grouped Settings recovery | Wave #852 + current Backup/AppSettings foundations |
| Canonical Timeline | `docs/CANONICAL_TASK_TIMELINE_2026-08-26.md` + current code/evidence |
| Historical audit/reconciliation support | Issue #358; it does not outrank newer #845 decisions |

## 2026-09-12 conflict locks

The following conflicts are now explicit so future agents do not revive stale behavior:

- **Home `کارهای من`:** older UI references requiring a visible `کارهای من` section are superseded. The current owner decision moves those filters/categories to `بیشتر` while preserving Arvin's approved dashboard identity/color language.
- **No-follow-up label:** `یادداشت` used merely as a work-status label is superseded by `بدون پیگیری`; actual Notebook/Note terminology remains valid.
- **Notebook storage:** any historical separate `arvin.simple_notes` architecture remains superseded by canonical Task-backed Notebook persistence.
- **Device Calendar UX:** a narrow select-one-FollowUp/export flow is not sufficient for the latest owner target of provider-based bidirectional synchronization. Existing provider foundations are retained and extended; no second calendar engine is created.
- **Prayer statistics:** prayer rows are not general Tasks and may not inflate Task counts/completion percentages.
- **Backup/fonts:** existing foundations must be exposed/recovered; a missing Settings path is not evidence that the underlying foundation should be rebuilt.

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

`PROJECT_DOCUMENTATION_FA.md` at repository root is preserved as an important early technical/history record. Its older `ArvinTask` / `TaskRepository` / early Backup descriptions are **not** the current architecture authority. Do not start new work from that file without first reading v49, current `main`, #845, the current recovery audit, scorecards, current contracts and code.

Likewise, older v48.x governance documents, old manual percentage snapshots and superseded PR-era plans remain traceability evidence rather than competing active requirements.

## Conflict rule

When two documents disagree:

1. check live current-main code/evidence;
2. check which owner decision is newer and whether it explicitly changes the affected behavior;
3. check the current #845 recovery ledger/Wave owner when the capability is part of recovery;
4. check current Issues/PRs and exact-head CI;
5. preserve historical text rather than deleting it;
6. update the active contract/index so the conflict is explicit;
7. open or link an issue for any accepted behavior not yet implemented.

Example: a historical Simple Note proposal used `arvin.simple_notes`; current canonical Notebook deliberately uses `TaskStore/arvin.tasks`. The current canonical contract wins and the historical proposal remains only as lineage.

Example: August Home references placed a visible `کارهای من` section on Home; the explicit 2026-09-12 owner decision moves those filters/categories to `بیشتر`. The newer placement decision wins without discarding the approved Arvin Home visual identity.

## Requirement-loss prevention rule

When a product requirement is deferred from one slice to another, the first slice must leave a durable pointer in `docs/PRODUCT_CONTRACT_MATRIX.md`, the indexed recovery audit, or both, with status **Missing/Partial** and an owning Issue. A domain/service/persistence merge may not silently convert the requirement to “done” when the accepted user interaction is still absent.

For the current recovery program, every #845 requirement has an owner in #846–#853. A Wave cannot close merely because a class/file/old PR exists; it requires applicable exact-head implementation and acceptance evidence. Final removal from the recovery ledger is controlled by Wave #853.
