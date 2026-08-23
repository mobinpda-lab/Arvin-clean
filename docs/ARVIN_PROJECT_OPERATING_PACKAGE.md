# ARVIN PROJECT OPERATING PACKAGE v48.1

## Enterprise Operational Governance & Parallel AI Software Factory

**Status:** Current Operational Reference  
**Project:** Arvin-clean  
**Repository:** mobinpda-lab/Arvin-clean  
**Primary Reality Authority:** GitHub Repository State  
**Operational Reference:** v48.0 + v48.1 Operational Execution Enhancement Patch

**Core Objective:** Produce real, validated, documented Working Software in **hours instead of days** through **Parallel Execution + Concurrent Workstreams + Automation + Fast Feedback + Controlled Integration**.

---

# Canonical Operating Rules

## 1. Authority
GitHub Repository State is the final authority for source code, branches, commits, issues, pull requests, workflows, CI results, build artifacts and repository documentation.

Documentation preserves project knowledge. ADRs govern approved architecture decisions. CI/CD evidence governs validation. Conversation history is context only.

**Document defines Governance. Repository defines Reality. Implementation defines Current Capability. CI defines Validation Status. Evidence defines Verifiable Result.**

## 2. Speed Model
Arvin is an engineered Software Factory, not a sequential task list.

**FAST + PARALLEL + CONCURRENT + AUTOMATED + CONTROLLED + VALIDATED + DOCUMENTED + SECURE + OBSERVABLE**

The target is **Software Delivery in Hours, not Days**.

**Parallel Execution + Concurrent Workstreams + Automation + Fast Feedback + Controlled Integration = Production Speed**

Speed is achieved by removing idle time and unnecessary serialization — **never by removing quality gates or architectural controls**.

## 3. Parallel Execution
Independent work is the default candidate for concurrent execution. Dependent work uses explicit dependency gates. Shared/Foundation work requires explicit ownership and coordination.

Every workstream defines Objective, Scope, Owner/Agent, Input, Output, Dependencies, Boundary, Target Branch, Validation, Evidence, Integration Point and Status.

Lifecycle:
`Definition → Dependency Check → Assignment → Concurrent Execution → Fast Feedback → Validation → Evidence → Controlled Integration → Documentation → Completion`

**Parallel Conflict is forbidden.**

## 4. Automation
Automate repetitive, predictable, scriptable and safely verifiable work such as repository audit, traceability, dependency checks, analyze, tests, builds, artifact generation, evidence collection and documentation validation.

Automation must never fabricate repository reality or evidence.

## 5. Fast Feedback
Preferred loop:
`Small Change → Immediate Validation → Commit → CI → Evidence → Continue`

Independent workstreams may execute independent feedback loops concurrently.

## 6. Execution Decision Matrix

| Change Class | Execution Path | Required Control |
|---|---|---|
| FAST CHANGE | Fast Path | Test/CI as applicable + Evidence |
| FEATURE CHANGE | Parallel Workstream | Scope + Owner + Validation + Controlled Integration |
| FOUNDATION CHANGE | Controlled Path | Impact Analysis + Review + Migration/Rollback + CI |
| CRITICAL CHANGE | Architecture-Controlled Path | Architecture Review + Migration/Rollback + Full Validation |

**Always select the fastest safe path.** Governance must prevent risk, not create unnecessary serialization.

## 7. AI Execution Control Loop
`Observe → Audit → Understand → Decompose → Parallelize → Execute → Fast Feedback → Evidence → Integrate → Document`

Before action, AI establishes Repository Reality, Existing Capability, Branch/PR/Issue State, Dependencies, Risks, Change Boundary, Validation Method and Evidence Requirements.

AI must not guess repository state, claim unverified success, duplicate existing capability without justification, alter Foundation without control, hide conflicts, fabricate evidence or bypass required validation/review.

## 8. Risk-Proportional Audit
Significant changes are audited for Repository, Branch, Commit, Issue/PR, Workflows, Implementation, Documentation, Architecture Boundary, Dependencies, Duplicate Work, Validation and Rollback implications.

Audit depth is proportional to risk. Low-risk documentation or isolated fixes must not inherit multi-day Foundation-level overhead.

## 9. Conflict Prevention
Before concurrent execution check File Ownership, Branch Ownership, Architecture Boundaries, Shared Components, Database/Migration Impact, Sync Contracts, Shared Interfaces, Active PRs, Existing Implementation, Duplicate Work and Dependency Ordering.

`Detect → Classify → Assign Owner → Resolve → Validate → Document`

## 10. Controlled Integration
Parallel development ends at a controlled integration boundary.

Integration requires correct target branch, scope verification, conflict check, validation/test evidence, CI evidence where applicable, documentation alignment and PR/review traceability.

**Done = Working Software + Validation + Evidence + Documentation + Integration Safety**

## 11. Foundation Protection
Foundation includes Architecture, Core/Shared Infrastructure, Database/Migrations, Sync Engine/Contracts, Security-sensitive Infrastructure and Cross-feature Contracts.

Foundation changes require the Controlled Path with appropriate Impact Analysis, Migration Strategy, Rollback Strategy, Validation Plan, CI Evidence, Documentation and Architecture Review.

The speed objective never authorizes bypassing Foundation protection.

## 12. Architecture and Sync
Architecture direction: **Clean Architecture + Feature-Based Architecture** with Domain Independence, Controlled Dependency, Repository Boundaries and Stable Foundation.

Sync Engine is Foundation Core, not an independent feature. Features must not create independent Sync Sources of Truth.

Sync Contract changes require Schema Version, Migration Path, Backward Compatibility, Conflict Strategy, Validation Evidence and Rollback Strategy as applicable.

## 13. Change Paths
### Fast Path
`Change → Validate → CI as applicable → Evidence → Merge`

### Parallel Feature Path
`Decompose → Assign Workstreams → Execute Concurrently → Validate Independently → Integrate`

### Controlled Foundation Path
`Audit → Design Review → Implementation → Migration/Test → Validation → CI → Review → Merge → Documentation`

## 14. Definition of Ready
Objective, Scope, Owner/Agent, Dependencies, Target Branch, Validation Method, Evidence Requirement and Integration Point must be defined.

Missing information should be established quickly and must not become an unnecessary multi-day waiting gate.

## 15. Definition of Done
Requirement, Scope, Implementation, Repository Registration, Review, Tests, required CI/Build validation, Documentation, Evidence, PROJECT_STATE alignment where required and Integration Safety must be satisfied.

## 16. Quality and CI
Applicable Quality Gate includes Requirement, Acceptance Criteria, Implementation, Code Review, `flutter analyze`, Unit Tests, Widget Tests, Integration Tests, Golden Tests, RTL Validation, Security Validation, CI, Build Verification, Documentation and Evidence.

Standard Flutter pipeline:
`flutter pub get → flutter analyze → flutter test → Integration Validation → flutter build apk → Artifact Generation → Release Validation`

GitHub Actions is the official validation authority. Local validation is Fast Feedback, not official evidence.

## 17. Security, Performance and Release
Dependencies require Purpose, Maintenance, Security, License, Compatibility and Architecture review.

Performance optimization requires before/after measurement evidence.

Release flow:
`Development → Validation → Release Candidate → Approval → Production Release → Monitoring`

Release requires Version Tag, Commit Reference, Release Notes, Validation Evidence and Rollback/Recovery Plan.

## 18. Evidence-Based Reporting
Reports distinguish:
- **FACT:** directly verified
- **INFERRED:** reasoned but not directly verified
- **PLANNED:** intended action
- **BLOCKED:** prevented by a real dependency/control

Unverified work must never be reported as completed.

## 19. Knowledge Continuity
Important decisions are preserved in ADRs, commits, PRs, documentation and AI Session Logs as appropriate. PROJECT_STATE is aligned when it exists and is part of the active documentation set.

## 20. Anti-Patterns
Prohibited:
- Sequentializing independent work without technical reason
- Duplicate implementations
- Uncoordinated changes to shared critical boundaries
- Uncontrolled protected-branch changes
- Claims without evidence
- Skipping Foundation architecture review
- Unnecessary workflows/documentation layers
- Treating conversation as repository reality
- Turning governance into an unnecessary multi-day bottleneck

## 21. Final Operational Loop
**Understand First → Audit Reality → Select Execution Path → Decompose → Create Concurrent Workstreams → Parallel Execute → Fast Feedback → Capture Evidence → Controlled Integration → Documentation Update → Working Software Delivery**

### Final Enterprise Principle
**Governance protects speed. Automation creates speed. Parallel and concurrent execution multiply speed. Fast feedback accelerates speed. Controlled integration preserves speed. Evidence proves success.**

### Final Objective
**Produce real, working, validated, documented software in hours instead of days — by parallelizing independent work aggressively, automating reasonable work, minimizing unnecessary waiting, and integrating changes safely.**

---

# Version Record

**Version:** v48.1  
**Role:** Operational Execution Enhancement  
**Parent Governance:** v48.0  
**Purpose:** Make the existing Parallel + Automation + Fast Feedback + Controlled Integration model explicitly executable for Hours-not-Days delivery without weakening governance.

**Preserved:** GitHub Source of Truth, Architecture Governance, Foundation Protection, Quality Gates, Evidence Requirement, Security, Documentation, Knowledge Continuity, Rollback, Parallel Execution and Automation.

**Canonical Rule:** `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` is the canonical operational entry point. `docs/ARVIN_PROJECT_OPERATING_PACKAGE_v48.1_PATCH.md` remains the detailed v48.1 execution record. v48.0 remains the governing foundation.
