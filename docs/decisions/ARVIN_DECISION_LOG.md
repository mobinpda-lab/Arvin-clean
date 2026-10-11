# Arvin Decision Log

**Purpose:** Index of current domain/product decisions. The linked ADRs and GitHub Issues/PRs hold full rationale and implementation evidence. An invariant being recorded here does not imply implementation or release acceptance is complete.

## ADR-001 — Task is Source of Truth
- **Decision:** One canonical Task identity is the source for Home, Calendar, Search, Notifications, Reports and Backup.
- **Reason:** Prevent divergent copies and inconsistent user data.
- **Impact:** All surfaces read/write through existing canonical Task paths; no parallel task store.
- **Evidence:** `lib/models/task.dart`, `lib/services/task_store.dart`; further conformance audit required.
- **Status:** ACCEPTED PRINCIPLE; full surface validation open.

## ADR-002 — Category equals Group
- **Decision:** Category and Group are one concept; use technical name `Category` and Persian UI term «دسته».
- **Reason:** Prevent parallel taxonomy.
- **Impact:** No separate Group entity, catalog, table, store or mapping layer; Tag remains distinct.
- **Evidence:** [Canonical taxonomy ADR](../ADR/ADR-2026-10-10-PCTADP-project-category-tag.md), Issue #2582.
- **Status:** ACCEPTED; conformance audit #2580 remains open.

## ADR-003 — Quick Add and Full Form use Same Task
- **Decision:** Quick Add and Full Editor are entry paths for one canonical Task; retain the same draft identity through transitions/cancel/retry.
- **Reason:** Avoid duplicates and lost drafts.
- **Impact:** Reuse existing Task model, editor and persistence path.
- **Evidence:** Issue #2593; implementation PR #2595 (draft, stacked on #2591).
- **Status:** ACCEPTED PRODUCT DIRECTION; implementation/device acceptance in progress.

## ADR-004 — Repeat does not create Duplicate Tasks
- **Decision:** A repeated schedule must not create a separate canonical Task for each occurrence.
- **Reason:** Keep one identity and protect history.
- **Impact:** Reuse the existing Repeat/Occurrence contract; preserve past execution state while allowing future schedule changes.
- **Evidence:** Existing execution protocol and architecture gate Issue #2254; Calendar acceptance Issue #2535.
- **Status:** ACCEPTED PRINCIPLE; exact occurrence/history and 7-occurrence behavior need validation against the current implementation. Do not change repeat engine semantics without architecture review.

## ADR-005 — Calendar is Projection Layer
- **Decision:** Task owns task identity; Calendar is a projection and external-event bridge.
- **Reason:** Prevent duplicate task/event ownership.
- **Impact:** Reuse Task ID + external Calendar ID + external Event ID mapping; edit must update the same linked event.
- **Evidence:** Calendar issue #2535, provider umbrella #516, PR #2587 (open).
- **Status:** ACCEPTED PRINCIPLE; physical-device Golden Flow remains open.

## ADR-006 — Checklist belongs to Task
- **Decision:** Checklist definition belongs to canonical Task; repeating execution state belongs to its occurrence.
- **Reason:** Avoid an independent checklist system and prevent state leaking between occurrences.
- **Impact:** Reuse Task checklist and existing occurrence/history fields; preserve checklist during backup/restore.
- **Evidence:** Existing execution protocol; Task model/store/tests; full lifecycle and restore acceptance still required.
- **Status:** ACCEPTED PRINCIPLE; implementation conformance in progress.

## ADR-007 — Tracking is not CRM
- **Decision:** Tracking and Follow-up remain Task capabilities; they do not become a separate CRM or independent record system.
- **Reason:** Keep follow-up attached to the work item and preserve a single source of truth.
- **Impact:** Reuse existing follow-up fields/history and next-action behavior; no parallel entity/store.
- **Evidence:** Issue #2593 and PR #2595; detailed counts/history audit remains open.
- **Status:** ACCEPTED PRINCIPLE; implementation/UX acceptance in progress.

## Change control
For each future important decision, record **Decision, Reason, Impact, Implementation, Evidence, Status, Owner approval, Date, and related Issue/PR/ADR**. Amend this log only alongside the canonical record. This index does not supersede accepted ADRs or issue-level architecture gates.
