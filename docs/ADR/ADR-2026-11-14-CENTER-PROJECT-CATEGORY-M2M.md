# ADR-2026-11-14 — Center–Project and Project–Category Many-to-Many Relations

- **Status:** APPROVED — explicit Product Owner confirmation, 2026-11-14.
- **Decision owner:** Mobin.
- **Repository:** mobinpda-lab/Arvin-clean.
- **Architecture:** Local-First / SQL-Only / REV10.
- **Supersedes:** REV10 single-parent Center→Project and Project→Category rules; unresolved Category↔Project scoping in ADR-2026-10-10-PCTADP.
- **Implementation status:** NOT VERIFIED. This ADR authorizes implementation and does not claim code/schema acceptance.
- **Merge / Release / Deployment:** NOT AUTHORIZED.

## 1. Context

The previous REV10 hierarchy required each Project to belong to exactly one Center and each Category to exactly one Project. The Product Owner has explicitly confirmed that both relationships must instead be many-to-many. This changes the organizational model from a mandatory single-parent tree to a relationship graph. Task assignment cardinalities remain optional and single-valued.

## 2. Decision

### 2.1 Canonical relationships

| Relationship | Cardinality |
|---|---|
| Center ↔ Project | Many-to-Many |
| Project ↔ Category | Many-to-Many |
| Task → Center | Optional, zero or one |
| Task → Project | Optional, zero or one |
| Task → Category | Optional, zero or one |
| Task ↔ Tag | Many-to-Many |

Each Center may be associated with zero or many Projects, and each Project with zero or many Centers. Each Project may be associated with zero or many Categories, and each Category with zero or many Projects.

### 2.2 Task assignment semantics
- A Task may be fully standalone.
- Center, Project and Category are independently optional direct Task assignments, each with a maximum cardinality of one.
- Tags remain zero-to-many.
- If a Task directly selects both a Center and Project, that pair must exist in Center↔Project.
- If a Task directly selects both a Project and Category, that pair must exist in Project↔Category.
- If a Task selects Center and Category without Project, the pair is valid only if at least one associated Project provides a path between them.
- Do not derive and persist duplicate ancestor assignments.

### 2.3 SQL model requirements
- One canonical normalized join relation for Center↔Project.
- One canonical normalized join relation for Project↔Category.
- Foreign keys to canonical entity IDs, unique pair constraints and indexes for lookup from both directions.
- Relationship writes and cross-field Task validation are transaction-safe.
- Removing a join edge does not delete either endpoint.
- Archive, restore, safe deletion and dependency inspection account for every join edge and direct Task assignment.
- No parallel entity catalogs, relationship stores or secondary databases.

### 2.4 Migration and data preservation
- Preserve all existing Center, Project, Category, Task, Tag, Person, Follow-up and Reminder identities and historical metadata.
- Convert each existing valid single-parent Center→Project assignment into one CenterProject edge.
- Do not infer Project↔Category edges from names, titles, display order or unrelated Task text.
- Existing Categories with no proven Project association must remain preserved and visibly unresolved/unassigned until a safe mapping rule is available; do not drop, merge or silently attach them.
- Preserve existing Task optional assignments and validate pair compatibility before commit.
- Use an additive, versioned migration with an independent backup, rollback, retry and recovery path.
- Validate exact row and pair parity before and after close/reopen cycles.

### 2.5 Backup and restore
Backup and restore must include both join relations, endpoint catalogs, IDs, timestamps and all existing metadata. Restore into an independent database file and prove exact pair parity, foreign-key integrity and successful reopen. Failure injection must prove rollback leaves the prior database usable.

## 3. Required acceptance tests
1. Multiple Centers linked to one Project and multiple Projects linked to one Center.
2. Multiple Projects linked to one Category and multiple Categories linked to one Project.
3. Duplicate edge rejection and idempotent link/unlink behavior.
4. Bidirectional lookup parity for every join relation.
5. Standalone Task creation and each optional Task assignment combination.
6. Valid and invalid cross-field Task relation combinations.
7. Remove one edge while preserving both endpoint entities and unrelated edges.
8. Archive/restore and safe deletion with dependency inspection.
9. Versioned migration from current schema using realistic fixtures, including NULL/missing/false/true legacy values.
10. Exact identity and history preservation, independent physical backup/restore, five close/reopen cycles, foreign-key checks, failure injection, rollback and retry.
11. Search, Home filters, Entity Management, Calendar, Reports, Notebook, Templates and Backup/Restore use the same canonical SQL relationships.
12. All required evidence is tied to one exact acceptance SHA; no PASS transfers from older commits.

## 4. Explicit non-goals and safety
- Do not merge historical PRs blindly or delete their evidence.
- Do not rewrite shared history, force-push or reset branches.
- Do not alter Main or repository security settings without explicit authorization.
- Do not delete production data or run migrations against real user data.
- Do not merge, release or deploy.

## 5. Consequences
All architecture docs, schema contracts, migration plans, UI selection logic, query/filter paths and tests must follow this ADR. Conflicting single-parent language must be marked SUPERSEDED while retaining historical context. Implementation, migration and verification remain separate statuses.

## 6. Related records
- `docs/project-continuity/MASTER_GOVERNANCE.md`
- `docs/project-continuity/PRODUCT_DECISIONS.md`
- `docs/project-continuity/ARCHITECTURE_NOTEBOOK.md`
- `docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md`
- PR #3448 — REV10 governance documentation stream.
- PR #3384 — SQLite implementation stream.