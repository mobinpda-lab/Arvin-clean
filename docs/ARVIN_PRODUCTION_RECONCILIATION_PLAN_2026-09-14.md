# Arvin Production Reconciliation Plan

## Authority
The installed real Arvin application screenshots are the primary UX reference. Future UI work must match real product behavior, not old assumptions or incomplete mockups.

## Scope
This reference covers:
- Home dashboard
- Quick task entry
- Follow-up workflow
- Notebook and notes
- Calendar and date selection
- Projects, categories and labels
- Icons, colors, spacing and RTL behavior
- Bottom navigation and action placement

## Conflict Prevention
1. Inventory all existing documentation.
2. Mark obsolete UI specifications as superseded.
3. Keep one canonical design authority document.
4. Do not implement features that contradict the installed product behavior.

## Production Roadmap

### Phase 1: Documentation Reconciliation
- Audit all docs.
- Create authority index.
- Remove ambiguity between old and new UI contracts.

### Phase 2: Code Alignment
- Map every screen to implementation files.
- Compare current widgets with canonical screens.
- Fix layout, colors, typography, icons and interaction flows.

### Phase 3: Functional Completion
Priority flows:
- Fast task creation
- Task tracking/follow-up
- Notebook
- Calendar
- Projects
- Categories
- Labels
- Search and filtering

### Phase 4: Quality Gate
Required before release:
- Flutter analyze clean
- Build verification
- Android installation test
- Screen-by-screen comparison
- Regression testing

## Rule
Arvin is a product, not a prototype. All changes must preserve usability, maintainability and release readiness.