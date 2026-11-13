# COMMAND 07-A.2.81 — Notebook Recovery Audit

**Repository:** mobinpda-lab/Arvin-clean  
**Audited branch:** feature/command-07-a-sqlite-contract-remediation  
**Exact audited HEAD:** df384ba5acbed3b3e4ae125a65706c5ff2fe5e5e  
**PR:** #3384 — OPEN / DRAFT / UNMERGED  
**PR base:** fix/wave3-cycle3-calendar-product-repair @ 8c4c23f0c2a4f9b2374a2092c931782c4455fd41  
**Main:** READ-ONLY. No merge/release/deployment.

## Executive result

Notebook is an existing feature, not an empty area. It currently reuses the canonical Task model, TaskStore, G1 Drift schema, Project membership and taxonomy. Do not create a second Note model, repository, database or storage key.

However, the current implementation is not the approved Notebook Connected Knowledge System. The most important missing capability is a durable, explicit Note↔Task relationship with independent identities. Current Simple Notes are themselves Task records. Task Details' “یادداشت” field is Task.description, and Follow-up notes are FollowUpRecord.note values. Neither is currently projected into the public Notebook as a distinct linked note.

No product code was changed in this audit. This is intentional: the missing relation and deletion semantics are data-model decisions, and current evidence does not justify a speculative schema migration on a branch whose primary scope is SQLite contract remediation. No test was run by this audit; the exact audited SHA has no reported commit status checks or PR workflow runs through the available GitHub evidence.

## Live GitHub identity and state

- PR #3384: OPEN, DRAFT, not merged.
- Head branch: feature/command-07-a-sqlite-contract-remediation.
- Head SHA: df384ba5acbed3b3e4ae125a65706c5ff2fe5e5e.
- Base branch: fix/wave3-cycle3-calendar-product-repair.
- Base SHA: 8c4c23f0c2a4f9b2374a2092c931782c4455fd41.
- Exact-head combined status: no status entries returned.
- Exact-head PR workflow runs: none returned.
- Therefore CI/test status is UNKNOWN, not PASS.

## Current architecture map

| Layer | Current implementation | Evidence |
|---|---|---|
| Domain model | Task is the canonical unified item; NotebookItemKind has note/checklist; Task.isSimpleNote and Task.isNotebookItem define Notebook membership | lib/models/task.dart |
| Persistence boundary | CanonicalNotebookRepository delegates to TaskStore; no Notebook-owned key/store | lib/services/canonical_notebook_repository.dart |
| SQL schema | G1DriftSchema v19; tasks table stores notebook_kind and description; follow_up_records stores historical Follow-up notes | lib/services/g1_drift_schema.dart |
| Project membership | ProjectPlan.itemIds via TaskProjectAssignmentService; no parallel projectId on Note | lib/services/canonical_notebook_repository.dart; test/notebook_project_membership_test.dart |
| Category / Tag | Category is Task.category; tags use Task.tags and canonical taxonomy catalog | lib/services/task_store.dart |
| Notebook UI | NotebookPage and NotebookEditorPage in one file | lib/notebook_page.dart |
| Task Details | Task.description is exposed as “یادداشت این کار” | lib/task_detail_page.dart |
| Follow-up | FollowUpRepository reads/writes Task.followUps; FollowUpEntryPage stores FollowUp.note | lib/follow_up_repository.dart; lib/follow_up_entry_page.dart |
| Tests | Notebook page, canonical repository, project membership, Task Details Follow-up flow, Drift schema and migration tests exist | test/notebook_page_test.dart; test/canonical_notebook_repository_test.dart; test/notebook_project_membership_test.dart; test/task_detail_followup_flow_test.dart; test/services/g1_drift_schema_test.dart |

## Gap analysis

| Capability | Status | Evidence / reason |
|---|---|---|
| Existing Notebook page and editor | IMPLEMENTED AND VERIFIED (source/test coverage) | lib/notebook_page.dart; test/notebook_page_test.dart |
| Canonical TaskStore persistence | IMPLEMENTED AND VERIFIED (repository test coverage) | lib/services/canonical_notebook_repository.dart; test/canonical_notebook_repository_test.dart |
| Simple Note and Checklist distinction | IMPLEMENTED AND VERIFIED (model/test coverage) | lib/models/task.dart; test/notebook_page_test.dart |
| Center / Project / Category / Tag filters | PARTIALLY IMPLEMENTED | Present in lib/notebook_page.dart; Time filter absent; no single five-dimension filter strip verified |
| Immediate text search | IMPLEMENTED AND VERIFIED for title/body substring | NotebookPage._visibleNotes; test/notebook_page_test.dart |
| Phone-number search normalization / contact-phone indexing | UNKNOWN | Search checks title and description only; no dedicated phone normalization or phone metadata projection verified |
| Note type filters: all / ideas / instructions / task notes | NOT IMPLEMENTED | No corresponding type discriminator or filter controls; current kind is note/checklist |
| Fast Capture FAB | PARTIALLY IMPLEMENTED | FAB exists, but _create creates “یادداشت جدید” and opens editor; test expects that placeholder |
| Fast Capture keyboard focus on body | NOT IMPLEMENTED | _load does not request description focus; no autofocus/focus test found |
| Optional title + first-line title derivation | NOT IMPLEMENTED | createNote/updateNote normalize blank titles to placeholder / “بدون عنوان”; no first-line derivation |
| Independent Note↔Task link | NOT IMPLEMENTED | No Note-Link table/model/foreign key; Note is currently the Task itself |
| Task Details → Notebook distinct note projection | NOT IMPLEMENTED | Task Details writes Task.description; Notebook lists only isNotebookItem records |
| Follow-up note → Notebook projection | NOT IMPLEMENTED | Follow-up notes live in Task.followUps / follow_up_records and are not Notebook items |
| Notebook card shows linked Task title | NOT IMPLEMENTED | No explicit link field or linked Task projection in NotebookPage |
| Navigate both directions | NOT IMPLEMENTED | No link navigation controls found in NotebookPage or Task Details |
| Convert note to Task preserving source as separate identity | PARTIALLY IMPLEMENTED | convertNoteToTask mutates same Task ID in place; source body is not removed, but no independent source/destination identity or provenance link |
| Prevent duplicate linked notes | UNKNOWN | No canonical link identity or uniqueness constraint exists |
| Close/Reopen SQL durability for Notebook | IMPLEMENTED BUT NOT VERIFIED | TaskStore/G1 SQL path exists; canonical Notebook tests use NativeDatabase.memory; no Notebook-specific file-backed reopen test identified |
| Stable Note ID | IMPLEMENTED AND VERIFIED for existing canonical Task identity | Task.id and repository tests |
| Task deletion preserving linked-note history | NOT IMPLEMENTED for the requested linked-note model | TaskStore._saveUnlocked deletes and rewrites Task/Follow-up rows from the supplied Task list; no independent Note record or detach policy exists |
| Follow-up persistence | IMPLEMENTED AND VERIFIED at repository/schema test level | follow_up_records and related tests |
| G1 Drift schema | IMPLEMENTED AND VERIFIED at schema test level | G1DriftSchema.version == 19; test/services/g1_drift_schema_test.dart |
| Notebook-specific exact-head CI | UNKNOWN | No status entries or PR workflow runs returned for df384ba5acbed3b3e4ae125a65706c5ff2fe5e5e |

## Fast Capture findings

Current flow:
1. FAB calls NotebookPage._create.
2. _create persists a placeholder Task through CanonicalNotebookRepository.createNote.
3. Editor opens with startEditing=true.
4. _load populates title and body controllers.
5. Autosave is timer-driven after controller changes.
6. No explicit focus request is made for the body editor.

The existing test explicitly expects “یادداشت جدید”, so changing the placeholder behavior requires updating that test and adding focused regression coverage. Correct implementation should preserve the complete body, derive title from the first non-empty line only while title is unset, and never overwrite an explicitly chosen title.

## Bidirectional integration findings

There are three different data concepts today:
- Notebook Simple Note: Task with notebookKind=note.
- Task Details note: Task.description.
- Follow-up note: FollowUp.note inside Task.followUps, normalized to follow_up_records.

They share the TaskStore persistence path but are not the same logical entity and are not joined as Notebook cards. Re-labeling Task.description or FollowUp.note as linked Notes without a stable Note ID would create identity ambiguity and potential duplication.

The existing convertNoteToTask is in-place conversion with the same ID. This differs from the approved contract for a separate destination Task with preserved source Note identity. Do not silently change this behavior until the product owner confirms whether conversion should create a second identity or retain the existing compatibility behavior.

## Data integrity findings

- G1 schema v19 has tasks and follow_up_records, but no notes or note_task_links table.
- TaskStore._saveUnlocked performs a transactional rewrite of Task and Follow-up records from the supplied Task collection. A Task omitted from that collection is not protected as an independent historical Note.
- Existing Notebook trash is soft-delete behavior for Notebook items; it is not a Task↔Note detach policy.
- A future Note-Link design must use independent stable note_id and task_id, uniqueness rules preventing duplicate links, and explicit detach behavior. Task deletion must detach or retain the Note, never cascade-delete the Note.
- Migration must be additive, idempotent, backup-aware and tested with file-backed close/reopen cycles. Existing Task IDs, Follow-up IDs, unknown metadata and backup compatibility must remain intact.

## Known evidence limitations

- docs/project-continuity/ARCHITECTURE_NOTEBOOK.md describes G1 schema version 16 and an older reference branch; live code and schema test show version 19. Treat the document's implementation snapshot as historical until reconciled.
- test/notebook_page_test.dart covers current UI controls, filters, editor and persistence interactions, but does not establish Fast Capture focus, first-line title derivation, phone normalization, Task/Follow-up projection or explicit Note-Link navigation.
- No exact-head test execution result is available. Existing test files are evidence of coverage, not proof that tests passed on this SHA.

## Safe completion plan

1. Reconcile the Notebook architecture document with live HEAD and preserve the current TaskStore/Drift canonical boundary.
2. Implement Fast Capture independently of schema changes: body-first focus, optional title, first-line title derivation, full-body preservation and empty-input handling. Add widget/repository tests.
3. Define the Note-Link contract: independent note_id, task_id, uniqueness, unlink, Task deletion, conversion provenance and recovery semantics.
4. Only after review, add an additive Drift migration and SQL repository operations; add file-backed close/reopen, backup/restore, duplicate prevention, unlink and Task-deletion tests.
5. Add Notebook projections for Task Details and Follow-up records without copying their text into duplicate Note rows. Provide explicit navigation both ways.
6. Add the requested note-type filter and shared Time→Center→Project→Category→Tag filter integration; add phone-format normalization tests.
7. Run targeted Notebook/Task/Follow-up tests, full analyze/test/build and exact-SHA CI. Record failures without suppressing or weakening tests.

**Disposition:** Audit complete at source level. Product implementation remains partially complete. No product code change, no commit to application logic, no merge, no release. Next safe coding slice is Fast Capture; Note-Link schema work remains gated on a reviewed identity/deletion contract.
