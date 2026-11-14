## OWNER-APPROVED ARCHITECTURE SUPERSESSION — 2026-11-14

**Decision ID:** ARVIN-ADR-2026-11-14-CENTER-PROJECT-CATEGORY-M2M
**Status:** APPROVED — explicit Product Owner confirmation on 2026-11-14.
**Authority:** This addendum supersedes every conflicting single-parent Center→Project and Project→Category rule in this document.

### Canonical relationship contract
- Center ↔ Project: many-to-many; each side may have zero or many links.
- Project ↔ Category: many-to-many; each side may have zero or many links.
- Task → Center: optional, zero or one direct assignment.
- Task → Project: optional, zero or one direct assignment.
- Task → Category: optional, zero or one direct assignment.
- Task ↔ Tag: many-to-many.

Task may remain fully standalone. Where a Task directly selects both endpoints of a defined association, that pair must exist in the corresponding canonical SQL join relation. A Center+Category pair without an explicit Project is valid only if at least one associated Project provides a path between them. Do not derive and persist duplicate ancestor assignments.

### SQL and migration requirements
- Use one canonical normalized join relation for Center↔Project and one for Project↔Category.
- Enforce endpoint foreign keys, unique pairs, bidirectional indexes and transaction-safe relationship writes.
- Removing a link must not delete either endpoint or unrelated links.
- Preserve every existing entity ID, Task assignment, history and proven relationship.
- Migrate existing Center→Project ownership as one edge. Never guess Project↔Category links from names, labels or unrelated Task text.
- Preserve unassigned/ambiguous Categories until a safe mapping is proven.
- Backup/restore must preserve both join relations and exact pair parity.
- Schema, migration, UI, query and test implementation remain unverified until exact-SHA evidence exists.

**Historical single-parent language is SUPERSEDED, not erased.** Merge, release and deployment remain unauthorized.
# ARVIN — MASTER PRODUCT, DESIGN & GOVERNANCE CHARTER
## REV10 — Unified Local-First Product, Data Architecture & Execution Governance

**Document ID:** ARVIN-MASTER-CHARTER-REV10  
**Revision:** REV10  
**Product Owner:** Mobin  
**Primary Repository:** `mobinpda-lab/Arvin-clean`  
**Related Factory Repository:** `mobinpda-lab/NIRA`  
**Architecture:** Local-First / SQL-Only  
**Acceptance Policy:** Single SHA Acceptance  
**Merge:** NOT AUTHORIZED  
**Release:** NOT AUTHORIZED  
**Deployment:** NOT AUTHORIZED  
**Status:** APPROVED PRODUCT DIRECTION; implementation and verification are tracked separately.

> «بسم الله الرحمن الرحیم»

## 0. Purpose, scope and status vocabulary

REV10 is the current owner-authorized master charter. It preserves every valid, non-conflicting REV9 requirement and incorporates the newer explicit decisions recorded below. REV9 is retained verbatim in [MASTER_GOVERNANCE_REV9_ARCHIVE.md](MASTER_GOVERNANCE_REV9_ARCHIVE.md); REV8 remains preserved in its existing archive. Neither archive is an active authority where it conflicts with REV10.

Use these statuses precisely:
- **APPROVED** — explicit Product Owner decision or ratified product contract.
- **PROPOSAL** — candidate idea; not implementation authority until approved.
- **SUPERSEDED** — formerly valid decision replaced by a newer explicit decision; retain historical context.
- **IMPLEMENTED** — present in source code or canonical schema; not proof of correctness.
- **VERIFIED** — proven by a passing test, CI job, artifact, device result or explicit owner acceptance tied to the exact SHA and scope.
- **BLOCKED** — a required dependency, failure or missing approval prevents acceptance.
- **UNRESOLVED** — evidence or an owner decision is insufficient; do not invent an answer.

Decision, implementation and verification are independent axes. A product decision may be APPROVED while its implementation is MISSING and its verification UNVERIFIED.

## 1. Authority and conflict resolution

The authority order is:
1. Latest explicit and approved Product Owner decisions.
2. Latest approved product and architecture decisions.
3. This REV10 Master Charter.
4. Canonical architecture, data, UX and product contracts.
5. Actual source code and SQLite/Drift schema for implementation facts.
6. Tests and CI evidence tied to exact SHAs.
7. Historical reports, older charters and conversation summaries.

When REV9 conflicts with a newer approved decision:
- Apply the newer decision in REV10 and every affected operational document.
- Mark the old decision SUPERSEDED in the decision history.
- Preserve its wording and context in the REV9 archive.
- Update related architecture contracts, tests, implementation contracts and handoff records.
- Never leave contradictory instructions active or silently erase historical evidence.

GitHub is the operational source of truth for repository state, code, branches, commits, PRs, workflows, tests and artifacts. A document does not prove that code is implemented; code does not prove that behavior is verified.

## 2. Product identity and foundational principles

Arvin is one integrated personal and professional commitment, task, reminder and follow-up management system. It is not merely a To-Do List.

Its purpose is to preserve commitments, manage actions and responsibilities, track follow-ups and waiting states, record outcomes, and retain reliable historical records.

Foundational principles:
- One integrated product and one canonical product database.
- One SQL source of truth for durable product data.
- Local-First operation; essential capabilities must work offline.
- Zero intentional data loss and preservation of valid identities, relationships and history.
- No parallel permanent JSON, SharedPreferences or secondary database persistence.
- No false success, completion, acceptance or release reporting.
- Persian RTL-first UX and Jalali calendar behavior where applicable.
- Preserve valid REV9 design requirements unless an explicit newer decision supersedes them.

Multi-device synchronization, cloud transport and remote sync remain suspended unless Mobin explicitly reauthorizes them. NIRA is a separate development factory, not a runtime dependency or product authority for Arvin.

## 3. Canonical entity hierarchy and cardinality

The approved business hierarchy is:

`Center → Project → Category → Task`

Ownership:
- One Center can contain multiple Projects.
- Every Project belongs to exactly one Center.
- One Project can contain multiple Categories.
- Every Category belongs to exactly one Project.
- One Category can contain multiple Tasks.
- Tags are independent entities with many-to-many Task assignments.
- Person is an independent reusable entity with persisted relationships to Tasks and Follow-up records where supported by the approved model.

Task relationships are optional and do not define whether a Task is valid:
- Center: zero or one.
- Project: zero or one.
- Category: zero or one.
- Tags: zero to many.

Valid examples include an entirely unorganized Task, Center-only, Project-only, Category-only, Tags-only, and every ownership-compatible combination.

Ownership derivation:
- A Task assigned to a Category can derive its Project and Center through Category → Project → Center.
- A Task assigned to a Project can derive its Center.
- Derived ancestors must not be written as direct Task relationships merely to duplicate ownership.
- Any directly selected relationships must be consistent with actual ownership.
- Do not force Task `project_id` or `category_id` to NOT NULL.

Filtering multiple Centers or Projects does not change the cardinality of an individual Task relationship.

## 4. Database integrity and SQL-only architecture

Audit the actual SQLite/Drift schema before changing it. The canonical schema must support:
- Nullable Task relationship columns.
- Mandatory Project → Center and Category → Project ownership.
- Foreign-key integrity and cross-parent consistency.
- Independent Tag relations.
- Real Person and relationship persistence.
- Safe parent reassignment, archival, deletion and restore.
- Historical relationship preservation.
- Incremental migration, rollback, retry and recovery.

Use ordinary foreign keys where sufficient. Where SQLite foreign keys cannot enforce the complete ownership contract, use tested triggers or an equivalent transaction-safe mechanism.

Prove invalid relationship combinations directly against SQLite with foreign keys enabled; UI validation alone is insufficient. Test both positive and negative cases against file-backed databases.

No parallel permanent database or independent JSON persistence may be introduced. Existing compatibility facades and legacy stores must remain until all consumers, migration paths and parity requirements are proven safe to retire.

## 5. Arvin Entity Management Center

**APPROVED PRODUCT REQUIREMENT:** provide one coherent management environment for:
1. Center
2. Project
3. Category
4. Tag
5. Person

This is a unified management experience, not a merged database table or loss of independent entity identity.

For each entity, inspect and implement the applicable operations:
- Create, read, edit.
- Archive and restore.
- Delete only when safe.
- Search and filter.
- View dependencies and references.
- Prevent duplicates where the domain contract requires it.
- Preserve historical references and auditability.

The hierarchy must be understandable as Center → Projects → Categories → Tasks. Tags remain independent and reusable across Tasks. People remain independent and reusable across Task and Follow-up relationships.

Before destructive operations:
- Inspect dependent records.
- Explain consequences.
- Offer safe alternatives, especially archive.
- Preserve history.
- Use transactions.
- Provide recovery where technically supported.

Never silently orphan or destroy dependent data. Entity-specific uniqueness, merge and permanent-delete rules remain UNRESOLVED where no approved contract exists.

## 6. Global filter contract

The official global filter order is:
1. Time
2. Center
3. Project
4. Category
5. Tag

This is the required order across Home, Calendar, Reports, Task lists, Project views, Follow-up Office and other relevant filter surfaces. The fifth filter is Center, not Branch.

Home layout:
- All five filters appear in one horizontal row.
- Right-to-left reading order follows the approved sequence.
- Horizontal scrolling on narrow screens.
- No wrapping into multiple rows and no clipping.
- Clear selected-state feedback.
- Individual clear and Clear All.
- Selection counts where applicable.

Filter logic:
- OR within one filter group.
- AND between different filter groups.
- Hierarchical filters constrain descendants: Center constrains Projects and Categories; Project constrains Categories.
- Contradictory combinations must not be produced.
- Filter multi-selection does not change Task relationship cardinality.

The older four-dimension Home filter rule is SUPERSEDED by REV10.

## 7. Task Details and editing UX

**APPROVED DESIGN PATTERN:** Single-Column Focus Detail View, using:
- Actionable Linear List.
- Contextual Quick Presets.
- Unified Bottom Sheets.
- Reliable Auto-Save.

Task Details must remain a vertical, single-column experience. Do not apply the five-filter horizontal Home layout to Task Details.

Organizational field order:
1. Center
2. Project
3. Category
4. Tag

Selection behavior:
- Center, Project and Category: single-select, optional, searchable, clearable, auto-save, shared Bottom Sheet and create-new action.
- Tags: multi-select, optional, checkboxes, searchable, create-new action and auto-save.
- Person: real Person entity, real SQLite relationship, searchable selection and creation. Static text is not a persisted relationship.
- Reuse shared selection components where practical.

The independent Edit Mode must not return. Supported Task fields save directly when changed.

Auto-Save protections:
- Prevent concurrent-write overwrite and lost updates.
- Show saving and saved states.
- Give clear error feedback and retry.
- Preserve confirmed changes after navigation and process restart.
- Never silently swallow persistence failures.
- Persist through the canonical SQL-backed services only.

## 8. Cross-Center activity identity and reporting

A common activity must be reusable across Centers without merging their execution records.

Example: the activity “Cleaning Windows” may be instantiated independently for Isfahan, Shiraz and other Centers.

Inspect existing Templates and Task models before introducing a stable shared activity identity. Task titles alone are not a permanent identity. Do not create a parallel Task database.

Each Center's execution must retain independent:
- Task ID and status.
- Due date and reminders.
- Follow-up history.
- Responsible people.
- Completion history.
- Evidence and attachments where supported.

The shared activity identity supports aggregation only; it must not share mutable execution state.

Required report dimensions:
- Activity, Center, Project, Category and Task.
- Completion status and responsible Person.
- Due date, completion date and delay.
- Follow-up history and last activity.

Required outputs:
- Completed, not-started, in-progress and overdue Centers.
- Completion percentage with explicit numerator, denominator and definition.
- Remaining work.
- Last activity.
- Responsible Person.

Reports must be reproducible after closing and reopening SQLite. Do not count a Task twice when it appears in more than one reporting projection. Unresolved status definitions and denominator rules must be documented before presenting percentages.

## 9. Templates Engine and Deep Clone

Audit the actual existing ProjectTemplateStore, TaskTemplateStore, ProjectTemplateService, TaskTemplate, ProjectTemplateTask and related persistence/migration code. Reuse canonical infrastructure; do not assume it is complete.

Templates must support the approved selection scope for:
- Centers, Projects and Categories.
- Tasks and checklists.
- Tags and priority.
- Default People where supported.

Template scope must not duplicate canonical entity ownership.

Deep Clone requirements:
- Generate new IDs for every instantiated record.
- Preserve the intended selected hierarchy.
- Create independent Center/Project/Category/Task instances as required by the selected scope.
- Create fresh unchecked checklist items.
- Preserve intended Tags and default relationships.
- Never copy old execution history or completed states.
- Never reuse historical Follow-up IDs or Reminder execution IDs.
- Preserve independence after editing and reopening SQLite.
- Never share mutable records between the original template and an instance.

Due dates and reminders must follow the approved relative-date contract and historical Option A rule only after those decisions are verified against canonical decision records. Do not infer missing date behavior.

Acceptance must cover multiple Centers, Projects, Categories and Tasks; multiple independent instances; editing isolation; close/reopen; Reminder and recurrence handling; Person relations; and history isolation.

## 10. SQLite migration and recovery acceptance

D01–D05 are independent acceptance gates. Each needs its own exact-SHA evidence.

- **D01 — Schema Compatibility and Migration:** supported old schemas migrate; new canonical schema, constraints, indexes, triggers and relationships match the approved contract.
- **D02 — Missing / NULL / FALSE / TRUE:** preserve all four states distinctly wherever semantically applicable.
- **D03 — Follow-up Metadata and Person Relationships:** preserve identities, order, metadata, Person records and relation links.
- **D04 — Independent Backup and Restore:** back up to one physical SQLite file and restore into a different physical SQLite file; compare data and relationship parity; close/reopen the restored database.
- **D05 — Atomicity, Rollback and Recovery:** inject failures, prove transaction rollback, source preservation, retry and recovery.

Required scenarios include:
- Legacy and new canonical schema.
- Empty values, missing columns and explicit NULL.
- FALSE and TRUE.
- Duplicate records and orphan relationships.
- Invalid JSON and invalid foreign keys.
- Interrupted migration, rollback and retry.
- Multiple close/reopen cycles.

Preserve historical identifiers and valid relationships. Verify indexes, triggers, foreign keys, `PRAGMA foreign_key_check`, `PRAGMA integrity_check`, relationship parity and the restored database itself.

Copying JSON is not proof of SQLite Backup/Restore. A snapshot or serialization test alone does not establish D01–D05 acceptance.

## 11. Product regression recovery

Continue historical regression recovery without assuming older failure counts remain current.

For every relevant failure:
1. Identify the exact test and exact failing assertion.
2. Inspect the production implementation.
3. Reproduce the behavior.
4. Classify the cause.
5. Implement a root-cause correction.
6. Run targeted and related regression tests.
7. Record the resulting exact SHA and evidence.

Allowed classifications:
- Production Defect.
- Test Contract Defect.
- Test Fixture Defect.
- Environment Failure.
- Infrastructure Failure.
- Unresolved.

Never weaken, delete, skip or bypass a valid test merely to obtain a green build. Correct a test contract only when source behavior and an approved product decision prove the original expectation incorrect.

The historical 49-failure Candidate and newer 12-failure report are investigation inputs, not current failure counts. Rebuild the live inventory from current exact-SHA evidence.

## 12. Typography, Persian UX and PDF

**APPROVED FONT DECISION:** Vazirmatn is the sole official and default Arvin font.

System Default may remain an optional user preference if supported by the settings contract; it is not a second official brand font. VazirHarf as an official/default product font is SUPERSEDED. Historical assets and provenance remain historical evidence and must not be treated as active branding.

Verify:
- Five required weights: 300, 400, 500, 600 and 700.
- One centralized Theme typography source.
- Global rendering behavior.
- Offline font availability and APK packaging.
- No unintended VazirHarf default or active registration.
- Persistent user font preference.
- RTL, Persian numerals, mixed Persian/English text and half-spaces.
- Small-screen readability and accessibility.

PDF acceptance requires inspection of the actual generated PDF:
- Vazirmatn embedding.
- Persian connected-letter shaping.
- RTL ordering.
- Mixed Persian/English text and digits.
- Correct tables and no clipping.

A font-loading unit test or successful build is not proof of actual PDF rendering.

All valid non-conflicting REV9 design requirements remain in force, including its approved brand/color and accessibility contracts, unless a later explicit owner decision supersedes them.

## 13. Repository, documentation and workflow consolidation

Audit the actual repositories before consolidation. Inspect:
- Duplicate implementations and taxonomy services.
- Legacy Tag storage.
- Project and Center ownership.
- Person persistence.
- Duplicate workflows and old branches.
- Draft PRs and historical test artifacts.
- Documentation duplication and conflicting authorities.
- Unused code and compatibility layers.

Maintain an ownership matrix with:
- CANONICAL
- ACTIVE COMPATIBILITY
- LEGACY
- DUPLICATE
- UNUSED
- HISTORICAL
- UNRESOLVED

Do not delete anything until consumers, data ownership, migration, tests, historical evidence and safe removal are established.

Do not rewrite Git history. Do not automatically merge or close historical PRs.

### AI Code Worker

Audit `.github/workflows/arvin-agent-worker.yml` for:
- Correct source branch and exact expected-SHA validation.
- Safe output branch and correct PR destination.
- Lease/fence protection.
- No accidental push to main.
- No unintended branch replacement.

Preserve current worker behavior until a safe replacement is validated. NIRA automation is a factory mechanism only; it does not replace Arvin product evidence or product ownership.

## 14. Execution autonomy and protected operations

Authorized ordinary development work includes:
- Repository inspection.
- Production code changes and ordinary refactoring.
- Tests and corrections.
- Approved product features.
- Controlled schema migrations with safety tests.
- Development commits and PR creation/update.
- Targeted tests, CI/build and documentation updates.

Stop only the operation that needs additional approval; continue independent authorized work.

Restricted operations:
- Merge to main.
- Release, publication or deployment.
- Irreversible production data deletion.
- Destructive production migration.
- Git history rewriting.
- Sensitive permission and secret changes.
- Irreversible removal of historical records.

No restricted action is authorized by this charter. Development commits and draft PRs are not product acceptance.

## 15. Development waves

Execute in dependency order while independent lanes proceed in parallel.

- **WAVE 0 — Governance and Live Baseline:** verify Main, execution branch, PRs, CI/jobs, canonical documents and REV9/newer decisions; reconcile REV10.
- **WAVE 1 — Data Architecture:** Center/Project/Category ownership, optional Task links, Tags, People, SQL integrity, migration and recovery tests.
- **WAVE 2 — Entity Management:** unified management for five entity types, CRUD, archive/restore, safe deletion, search/filter and legacy migration.
- **WAVE 3 — Home and Task Details:** five filters, RTL horizontal Home row, single-column Task Details, actionable rows, shared sheets and reliable Auto-Save.
- **WAVE 4 — Templates Engine:** scope selection, Deep Clone, independent instances, checklist reset, Person and Reminder handling.
- **WAVE 5 — Cross-Center Reporting:** stable activity identity, independent execution, accurate aggregate projections and reproducible reports.
- **WAVE 6 — Product Regression and UX:** Home, Quick Capture, Task Editor, Calendar, Checklist, People, Follow-up, Notebook, Reports, navigation, visual tests and accessibility.
- **WAVE 7 — Typography, PDF and Device:** Vazirmatn contract, APK packaging, real PDF rendering, seven Device Smoke scenarios and Debug/Staging build evidence.
- **WAVE 8 — Final Consolidation:** repository/workflow audit, documentation reconciliation, REV10 completion, final acceptance matrix and Single SHA acceptance.

Independent waves must continue without waiting for unrelated blocked work.

## 16. Acceptance, evidence and reporting

Every accepted result must identify:
- Acceptance SHA and actual checkout SHA.
- Workflow Run ID and Job ID.
- Exact test/control name and result.
- Artifact ID and SHA256 digest where relevant.
- Failure details and remaining risk.
- Device/OS/build information for device evidence.

No historical PASS transfers to a new SHA. Missing, queued, cancelled, skipped or unavailable results are never PASS.

Final acceptance matrix:
- REV10 governance conflicts resolved.
- Data hierarchy and ownership valid.
- Every permitted optional Task relationship works.
- Five entity types managed coherently.
- Tags and People use canonical SQL relations.
- Five global filters correct everywhere.
- Task Details follows the approved interaction model.
- Templates Deep Clone independently.
- Cross-Center reporting is accurate and reproducible.
- D01, D02, D03, D04 and D05 independently accepted.
- Relevant regression failures resolved or explicitly blocked.
- Vazirmatn verified.
- Actual Persian PDF rendering verified.
- APK packaging/build evidence verified.
- Seven Device Smoke scenarios accepted.
- Canonical documentation synchronized.
- GitHub branch protection and authorized PR workflow verified.

Reports must be Persian, clear and product-first. Separate facts, implementation, verification, proposals, unresolved decisions and risks. Use GREEN only for proven success, YELLOW for partial/waiting evidence, RED for failure/blocker and GRAY for not executed/unknown.

After each wave report:
1. What was inspected.
2. What was implemented.
3. What was committed and exact SHA.
4. Tests passed and failed.
5. What was not executed.
6. Incomplete product capabilities.
7. Data-integrity risks.
8. Available evidence.
9. Next execution target.

Maintain a current handoff so continuation never depends on conversation memory.

## 17. Explicit unresolved decisions

Do not invent answers for:
- Any Template relative-date edge case not proven by the canonical Option A decision record.
- Exact permanent-delete and merge/duplicate policy for each entity where dependencies/history vary.
- Person-role cardinality and role semantics beyond already-approved real Person relationships.
- Activity identity lifecycle, equivalence and deprecation rules not yet approved.
- Reporting status definitions and denominators where the domain model does not define them.
- Category naming normalization and Persian/Arabic character equivalence.
- Project reassignment rules after Template instantiation.
- Any legacy ambiguous or contradictory relationship whose source evidence is insufficient.

Record each question, its source, affected schema/UX/tests, safe interim behavior and owner decision requirement.

## 18. Revision history and supersession

- **REV8:** preserved historical master; no longer active authority.
- **REV9:** previous unified master; preserved verbatim at `MASTER_GOVERNANCE_REV9_ARCHIVE.md`. It remains the historical starting point and source of non-conflicting inherited requirements.
- **REV10 (2026-11-13):** current owner-authorized master. Adds Center → Project → Category → Task ownership, optional Task links, five-entity management, five global filters, single-column Auto-Save Task Details, Cross-Center activity identity/reporting, Deep Clone, independent D01–D05 acceptance, current regression policy, Vazirmatn-only official typography and continuous development governance.

**Final directive:** Build the complete product. Preserve every valid decision and historical record. Make the data model consistent. Make every module work together. Prove every important result. Never confuse implementation with acceptance.

**ARVIN — COMPLETE, CONSISTENT, LOCAL-FIRST, ENTERPRISE-READY.**

**Merge: NOT AUTHORIZED. Release: NOT AUTHORIZED. Deployment: NOT AUTHORIZED.**


## 19. Product Owner supersession addendum — 2026-11-14

**Status: APPROVED by Product Owner.** This addendum supersedes the REV10 single-parent hierarchy statements only for the relationships explicitly listed below. Historical text remains preserved as history and must not be treated as current authority where it conflicts.

- Center ↔ Project: MANY-TO-MANY.
- Project ↔ Category: MANY-TO-MANY.
- Task → Center: OPTIONAL, 0..1.
- Task → Project: OPTIONAL, 0..1.
- Task → Category: OPTIONAL, 0..1.
- Task ↔ Tag: MANY-TO-MANY.
- A Task may remain fully standalone.
- Use one canonical normalized SQL junction relation for each many-to-many relationship, with endpoint foreign keys, unique pairs, bidirectional indexes and transactional writes.
- Do not infer Project↔Category edges from names, labels, display order or Task text.
- Removing a relationship must preserve both endpoints. Archive, restore, deletion and dependency inspection must account for all join edges and direct Task assignments.

**Implementation authority:** ADR `ADR-2026-11-14-CENTER-PROJECT-CATEGORY-M2M.md`, Issue #3458 and PR #3463. PR #3463 is an implementation candidate, not accepted product integration. Main merge, release and deployment remain unauthorized.
