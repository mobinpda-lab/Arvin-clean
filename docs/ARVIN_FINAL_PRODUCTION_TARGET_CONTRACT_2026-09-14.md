# Arvin Final Production Target Contract — 2026-09-14

## Purpose
This document defines the final product target based on the real installed Arvin application evidence supplied by the owner and prevents older UI assumptions from redirecting implementation.

The target is not only visual. Acceptance includes layout, information architecture, interactions, colors, icon language, navigation, persistence behavior and workflow completion.

## Authority Rules

1. Real installed application behavior and owner-approved screenshots are the visual/product reference.
2. Existing canonical architecture documents remain valid unless this contract explicitly changes a surface.
3. Historical documents are evidence only and must not introduce conflicting behavior.
4. Any missing requirement discovered during implementation must be recorded, not silently removed.

## Product Surfaces To Match

### Home Dashboard
- Header structure, RTL layout, title placement, search behavior.
- Summary counters and status presentation.
- Category/project/time/tag entry cards.
- Bottom navigation placement and icon style.
- Quick access behavior.

### Quick Entry
- Fast task creation flow.
- Project, category, date, tag and follow-up selection.
- Minimal friction entry while preserving full task capability.

### Task / Follow-up Workflow
- Task details page.
- Follow-up history timeline.
- Status chips, reminders and completion actions.
- Clear separation between task, note and follow-up concepts.

### Notebook
- Real notebook behavior from installed application reference.
- Notes, checklists and editor interactions.
- Correct relationship with canonical Task-backed persistence.

### Calendar
- Date selection behavior.
- Today/future organization.
- Calendar integration direction must follow current canonical provider architecture.

### Categories, Projects, Tags
- Visual identity from reference screens.
- Color coding.
- Icons.
- Filtering and grouping behavior.
- No duplicate competing models.

## Design System Requirements

- Preserve Arvin color language.
- Preserve RTL-first layout.
- Preserve spacing hierarchy.
- Preserve icon meaning and placement.
- Avoid replacing real product identity with generic templates.

## Implementation Plan

Phase 1 — Reconciliation
- Audit all docs against current main.
- Mark stale/conflicting requirements.
- Update authority indexes.

Phase 2 — UI Contract Validation
- Map every screen to implementation files.
- Create screen acceptance checklist.
- Validate navigation and state behavior.

Phase 3 — Production Hardening
- Complete missing workflows.
- Remove duplicate implementations.
- Run analysis, tests and Android validation.
- Produce release candidate evidence.

Phase 4 — Release
- Final QA against installed-app reference.
- Build production package.
- Publish readiness review.

## Non-negotiable
Arvin is considered complete only when the built product matches the approved user experience, not merely when code classes or documents exist.
