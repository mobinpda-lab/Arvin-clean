## Post-audit documentation tree refresh — 2026-11-10

At working SHA `a934cabebc814aea13c1800ab151821d12714226`, recursive tree is complete (953 entries; not truncated):
- docs/: 271 files, including 266 Markdown.
- docs/project-continuity/: 45 files.
- Whole repository Markdown: 285 files.
- Main docs/: 209 files, including 204 Markdown.
- Prior count of 259 working docs and 33 continuity files is the pre-a934 snapshot.
- All 12 REV8 audit deliverables exist and are indexed from canonical README. No historical doc was deleted.

---

# Arvin Documentation Reconciliation — REV8

**Snapshot:** 2026-11-10  
**Working SHA:** `9846f10850031c63964fdc81ae0ab1cdb3028517`

## Inventory

| Area | Main | Working branch |
|---|---:|---:|
| Total docs/ Markdown or text files | 209 | 259 |
| Root-level docs files | — | 178 |
| Nested docs files outside project-continuity | — | 48 |
| `docs/project-continuity/` files | — | 33 |
| `docs/audit/` files | — | 3 |

The 33 continuity files contain the eight Canonical documents plus historical specs/checkpoints. There was no `docs/project-continuity/audit/` directory before REV8. The 12 REV8 audit files are being added under that directory.

## Link check

- All 33 continuity files were fetched from the working branch.
- **99 internal Markdown links** were checked against the live repository tree.
- **0 broken internal links** were found in that 33-file set.
- Links in the remaining 226 docs outside continuity were not exhaustively checked.

## Authority and duplication candidates

1. `PRODUCT_DECISIONS.md` is the active product decision ledger. `DECISIONS.md` is a parallel historical/technical decision record and must not be mistaken for the active product authority.
2. `calendar_ui_ux_spec.md` is the 135-line dated, owner-approved Calendar UI/UX reference linked by the continuity README. `CALENDAR_UIUX_SPEC.md` is a separate 52-line older proposal referencing a historical commit. Preserve it as historical; do not merge blindly.
3. `TODO.md` remains a working backlog snapshot. Its entries must be reconciled into `OPEN_ISSUES.md`/ `ROADMAP.md` before being treated as active.
4. Older root docs such as `core-foundation-audit.md`, `UNIFIED_ITEM_MIGRATION_2026-08-15.md`, `HOME_UNIFIED_ITEM_MIGRATION_PLAN_2026-08-15.md`, and `CLEAN_CODE_AUDIT_2026-08-16.md` describe `ArvinTask`/`TaskRepository` as current. Current `lib/main.dart` uses canonical `TaskStore`; those statements are historical, not live architecture authority.
5. Root docs include numerous old governance, state, roadmap, contract and changelog snapshots. Their age alone does not authorize deletion.

## SHA staleness

The eight canonical documents contain 425 SHA references (292 unique strings). None mentions current working HEAD `9846f108...`. Several still mention historical baseline `b789343c...`. Historical references are retained; current state must be explicitly added rather than replacing history.

## Canonical document set

1. `MASTER_GOVERNANCE.md`
2. `PRODUCT_DECISIONS.md`
3. `CURRENT_STATE.md`
4. `ROADMAP.md`
5. `OPEN_ISSUES.md`
6. `IMPLEMENTATION_LOG.md`
7. `HANDOFF.md`
8. `README.md`

The REV8 audit index is linked from the canonical README. No historical doc, branch, tag, release, or commit was deleted.
