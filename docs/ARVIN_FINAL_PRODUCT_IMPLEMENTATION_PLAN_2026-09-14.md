# Arvin Final Product Implementation Plan

## Authority
The real installed Arvin application screenshots are the product behavior reference. This document extends the UI reference contract and must be used with existing canonical governance documents.

## Product Target
Arvin final output must match the installed application vision, including:
- Persian RTL experience
- colors and visual hierarchy
- icon system
- button placement
- navigation behavior
- task management flows
- notebook and notes experience
- quick entry
- follow-up tracking
- projects, categories and labels

## Do Not Regress
Old documents, old mockups, abandoned UI concepts and conflicting assumptions must not override the current product contract.

Before changing UI or architecture:
1. Identify existing authority document.
2. Check conflict with real installed behavior.
3. Mark obsolete content as superseded.
4. Update traceability matrix.

## Implementation Phases

### Phase 1 - Documentation Reconciliation
- Audit all docs.
- Create authority map.
- Remove ambiguity between old and new UI rules.
- Link every screen to acceptance evidence.

### Phase 2 - UI Implementation Alignment
Validate:
- Home dashboard
- Time view
- Projects view
- Categories view
- Labels view
- Quick add sheet
- Task detail
- Follow-up timeline
- Notebook
- Checklist
- Calendar/date picker

### Phase 3 - Functional Completion
Implement and verify:
- task lifecycle
- reminders
- follow-ups
- filtering
- grouping
- search
- offline data behavior

### Phase 4 - Production Gate
Required evidence:
- flutter analyze
- tests
- Android build
- installed APK validation
- screenshots compared against reference
- release checklist

## Definition of Done
Arvin is complete only when the installed product behavior, documentation, architecture and code all agree.