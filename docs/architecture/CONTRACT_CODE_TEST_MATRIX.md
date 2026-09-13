# Arvin Contract ↔ Code ↔ Test Matrix

Purpose: maintain traceability between approved behavior, implementation and validation.

| Contract Area | Code Location | Test/Evidence | Status |
|---|---|---|---|
| Home Dashboard | `lib/main.dart` and Home related widgets | Home widget/regression tests + device validation | Migration required |
| Unified Task Entry | Quick Capture + canonical Task editor | persistence and duplicate-path regression | Preserve |
| Task Storage Authority | `TaskStore/arvin.tasks` | storage path checks | Protected |
| Task Detail | `lib/task_detail_page.dart` | navigation regression | Existing |
| FollowUp Flow | FollowUp services/pages | timeline and append tests | Existing |
| Notebook | notebook pages + canonical repository | same-ID persistence tests | Existing |

## Phase 2 Home Final Migration Tracking

- [ ] Home contract audited against implementation
- [ ] Header/navigation hierarchy reconciled
- [ ] Quick entry convergence verified
- [ ] No duplicate storage path introduced
- [ ] Missing interactions mapped to owner matrix
- [ ] Tests updated
- [ ] Device evidence collected

## Rule

A contract cannot be marked complete without matching code and validation evidence.
