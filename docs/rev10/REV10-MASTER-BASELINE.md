# REV10 MASTER BASELINE
**Record date:** 2026-11-21 (1405/08/30)
**Repository:** mobinpda-lab/Arvin-clean
**Canonical route:** PR #3495 / `recovery-02/main-based-integration`
**Product authority:** REV10 — owner-approved
## 1. Source identification
The current branch contains no standalone REV10 PDF or other PDF file. The full master charter is embedded in `docs/project-continuity/MASTER_GOVERNANCE.md`, beginning at the heading `REV10 — Unified Local-First Product, Data Architecture & Execution Governance` (source line 83 in the audited revision).
- Source document revision: REV10
- Source format: Markdown
- Source Git blob SHA: `cdea45d11f4e25795231f2aca10cfdc1b6cde521`
- Standalone PDF page count: N/A (no PDF found in the canonical branch tree)
- SHA-256 of the source file: NOT CALCULATED in this checkpoint; Git blob SHA is recorded separately and must not be represented as SHA-256.
## 2. Active canonical document set
The active continuity set is:
1. `README.md`
2. `docs/project-continuity/MASTER_GOVERNANCE.md`
3. `docs/project-continuity/PRODUCT_DECISIONS.md`
4. `docs/project-continuity/CURRENT_STATE.md`
5. `docs/project-continuity/ROADMAP.md`
6. `docs/project-continuity/OPEN_ISSUES.md`
7. `docs/project-continuity/IMPLEMENTATION_LOG.md`
8. `docs/project-continuity/HANDOFF.md`
Supporting ADRs and historical reports are evidence only. The REV10 master charter and current owner decision register take precedence over stale implementation notes.
## 3. Owner-locked invariants
- Primary Blue is exactly `#4169A1`; canonical source is `lib/arvin_colors.dart`.
- Center is a required first-class product entity; it is not replaceable by Project, Category or a visual-only filter.
- Home has five independent dimensions: Time, Center, Project, Category, Tags.
- OR applies among selected values within one dimension; AND applies across dimensions.
- Home retains five separate due-date groups: Overdue, Today, Tomorrow, Future, No Date.
- Center↔Project and Project↔Category are many-to-many. Task→Center/Project/Category are independently optional 0..1; Task↔Tag is many-to-many.
- Local SQL is the persistent source of truth. Multi-device synchronization remains suspended unless the owner explicitly reauthorizes it.
- Main is read-only. PR #3495 is the sole active development route. Merge, release, deployment and production-data migration require explicit owner approval.
## 4. Current evidence boundary
Audit Candidate: `c033513de5bd0067a093c59303c4071acf42f564`.
Main: `45e4202b03a434459e4c021a04efa7e8396359db`.
PR #3495: OPEN / DRAFT / UNMERGED.
The source and implementation inventories are recorded in the 124-R acceptance matrix. No historical SHA evidence transfers to a later candidate.
## 5. Known source-vs-implementation conflicts
- Home source has four filter dimensions/cards; REV10 requires five including Center.
- Center model/store exists, but management UI and integrations with Task Editor, Quick Capture, Task projection, Home and reporting are not accepted.
- Project↔Category has a schema-v9 relation table, but complete canonical store/UI/backup integration is not accepted.
- Reminder issue #3646 remains open; four-action Android UI and process/reboot/device acceptance are not present.
- Ruleset 20952260 protects Main from deletion/non-fast-forward and requires PR, but approving review count is zero, CODEOWNERS review is disabled, review-thread resolution is disabled and required CI checks are absent.
- The branch itself is not protected.
- No standalone REV10 PDF is present; obtain/attach one only if the owner identifies an external canonical file. Do not invent page counts or hashes.
