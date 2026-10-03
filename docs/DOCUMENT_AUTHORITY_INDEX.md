# Arvin Document Authority Index

## Why this exists

Arvin has accumulated historical snapshots, migration notes, architecture proposals, product contracts and live-status files. This index prevents a future session from treating an old but authoritative-looking file as current product truth.

GitHub repository reality always outranks narrative documents.

## Authority order

1. Live GitHub reality — current main, current code, current open/merged PRs/Issues and workflow evidence.
2. Newest explicit owner-approved product decisions and final contracts.
3. ARVIN_PROJECT_OPERATING_PACKAGE governance rules.
4. Canonical product contracts and acceptance documents.
5. Historical snapshots and handoffs only as evidence.

## Final 2026-09-14 product authority additions

The following documents are now the final reference layer for production completion:

| Area | Active reference |
| --- | --- |
| Visual appearance, layout, colors, screens | `docs/ARVIN_FINAL_UI_VISUAL_REFERENCE.md` |
| Product behavior, workflows, data rules, acceptance criteria | `docs/ARVIN_FINAL_PRODUCT_IMPLEMENTATION_CONTRACT_2026-09-14.md` |
| Authority transition rules | `docs/ARVIN_AUTHORITY_MIGRATION_PLAN_2026-09-14.md` |

These documents override older conflicting UI assumptions. They do not replace existing data models, services or foundations unless a specific migration decision is approved.

## Conflict locks added

- Old Home layouts containing superseded dashboard assumptions must not return.
- Visual similarity alone is not acceptance; real behavior and persisted data are required.
- Mockups are not evidence of completion.
- Existing Task, FollowUp, Project, Category, Label and Notebook foundations must be reused.
- New parallel storage or duplicate architecture must not be created only to match appearance.

## Production completion rule

A capability is complete only when:

1. Contract exists.
2. Real implementation exists.
3. Data behavior is verified.
4. Tests or manual evidence exist.
5. Android execution is verified where applicable.

A document, class, branch or old PR alone is never proof of completion.
