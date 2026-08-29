# Arvin Document Authority Index

GitHub live reality outranks every narrative document.

## Authority order

1. Live `main`, current code, open/merged PRs/Issues and exact-head workflow evidence.
2. Newest explicit owner-approved product decision.
3. `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 and live execution board Issue #403.
4. Official scorecards.
5. Canonical product/UI indices such as `docs/PRODUCT_CONTRACT_MATRIX.md` and `docs/ARVIN_UI_CANONICAL.md`.
6. Current implementation-specific contracts.
7. Dated snapshots/handoffs/historical technical records.

## Active canonical references

| Area | Active reference |
| --- | --- |
| Governance / execution | `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 + Issue #403 |
| Live project snapshot | `docs/PROJECT_STATUS.md` |
| Whole-project progress | `docs/project_completion_scorecard.json` + `docs/PROJECT_PROGRESS_METRIC.md` |
| Product acceptance | `docs/PRODUCT_CONTRACT_MATRIX.md` |
| UI index | `docs/ARVIN_UI_CANONICAL.md` |
| Home | `docs/HOME_STYLE_LOCK.md` |
| Task detail / FollowUp UX | Issue #357 |
| Notebook | `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md` |
| Bidirectional Device Calendar Integration | `docs/BIDIRECTIONAL_DEVICE_CALENDAR_INTEGRATION_2026-08-29.md` + Issue #516 + existing provider lane #348 |
| Report typography | current `TaskReportPdfRenderer` + bundled Vazirmatn UI FD regression evidence |

## Calendar authority clarification — 2026-08-29

The binding target is now:

`Arvin ↔ Android Calendar Provider ↔ Google / Samsung / Other compatible calendars`

This supersedes narrower historical Google-only export wording.

Rules:
- one provider adapter foundation; no separate Google/Samsung engine without proven need;
- Settings only under `تنظیمات → تقویم و همگام‌سازی`;
- existing Work Agenda remains the aggregation foundation;
- external events begin as external/read-only projections and never auto-convert to canonical Tasks;
- external events stay outside Task Report/PDF/Share/Backup by default;
- merged idempotent sync planning and Issue #348 provider work must be reused.

## Snapshot rule

Files such as `AI_CONTINUATION_STATE.md`, `AI_HANDOFF_CURRENT_FA.md`, `PROJECT_STATUS.md`, `ARVIN_STATUS.md`, `ARVIN_PROJECT_STATE.md` and dated progress logs are time-sensitive. They must always be reconciled with live GitHub before action.

## Historical-document rule

Older architecture/proposal documents remain traceability evidence only. They cannot override current canonical Task/Project/Work Agenda/Report/Calendar decisions or newer owner-approved contracts.

## Conflict rule

When documents disagree: check recency and owner approval, current code/data constraints, live PR/Issue/CI evidence, preserve historical lineage, update the active contract/index, and leave an owning Issue for any accepted but incomplete behavior.

## Requirement-loss prevention

A merged Foundation is not equivalent to complete product acceptance. Deferred requirements remain `Missing` or `Partial` in the Product Contract Matrix until UI, tests, exact-head evidence and applicable device/visual acceptance converge.

This especially applies to Task detail UX, Projects integration, Work Agenda outputs, canonical reporting, typography and the phased Device Calendar target.
