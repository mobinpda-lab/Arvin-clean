# Arvin — Canonical Project State
## State Rule
GitHub Repository State is the source of truth for executable status. `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 is the single active governance and software-production reference.
## Repository
- Repository: `mobinpda-lab/Arvin-clean`
- Platform: Flutter / Dart
- Default branch: `main`
- Active documentation work: PR #135 on `docs/arvin-operating-package-v48-2-final-operational`
## Documentation Consolidation
- v48.0 governance is preserved as lineage.
- v48.1 execution optimization is preserved as lineage.
- Approved v48.2 integrated/editorial revision is preserved as the approved source record.
- v49.0 now unifies active governance, execution, architecture, Sync, UI, quality, recovery, documentation, continuity and communication rules in `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`.
- Historical documents are evidence, not competing active authorities.
## Mandatory Start Audit
Before meaningful work: verify access, `main`, working ref, recent commits, open PRs, exact CI results, relevant documentation, existing implementation, dependencies, conflicts and risks.
## Execution Model
Independent work is parallel by default. Dependent work is sequential only when technically necessary. Shared foundation work requires explicit coordination. A blocked lane must not unnecessarily block unrelated work.
## Architecture Invariants
- Clean Architecture + Feature-Based Architecture.
- Domain remains independent of infrastructure.
- Unified Item/Task remains the shared product foundation unless an approved architectural decision changes it.
- Existing storage/data must remain backward compatible unless an approved tested migration changes the contract.
- Sync Engine is Foundation Core and no feature may create an independent Sync source of truth.
## UI Invariants
Approved Arvin UI is protected. Persian RTL-first behavior, canonical hierarchy, Reminder behavior and Lock Screen/widget expectations may not be changed without explicit approval and validation.
## Validation
Exact-commit GitHub Actions evidence is authoritative. Local checks are fast feedback. A delivery is complete only when implementation, applicable tests/builds, evidence, documentation and safe integration are complete.
## Communication
Reports and answers are compact, simple and understandable without programming knowledge. They are copyable, contain no unnecessary blank lines, distinguish verified facts from plans/blockers, and end with a separate copyable `ادامه` marker.
## High-Risk Review
DeepSeek may be used as an independent second reviewer for major architecture, migration, storage, CI or other high-risk decisions. It does not replace GitHub evidence or owner approval.
## Historical State
Older status files and dated reports remain historical records. They must not be interpreted as current status when they conflict with verified GitHub reality.