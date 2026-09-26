# Arvin Contract → Code → Test Matrix

| Contract Area | Current Code Boundary | Test Boundary | Status |
|---|---|---|---|
| Home Unified Item | HomePage + TaskStore migration boundaries | Home widget/service tests | In migration |
| Task persistence | TaskStore / arvin.tasks | TaskStore regression tests | Canonical |
| FollowUps | FollowUp repository over TaskStore | FollowUp tests | Canonical |
| Projects | ProjectStore references canonical Task ids | Project tests | Active |
| UI contracts | New canonical UI authority | Contract compliance tests | Started |

## Rule

No feature is considered complete until all four points exist:

Contract → Implementation → Test → Evidence

## Phase 2 Target

Home Final Migration will remove remaining UI compatibility layers only after:

- rendering uses canonical Task directly
- save paths are verified
- backup/restore impact is audited
- regression coverage passes
