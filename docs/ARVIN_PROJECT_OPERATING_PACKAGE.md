# ARVIN PROJECT OPERATING PACKAGE v49.0
## Unified Canonical Software Production Standard

**Project:** Arvin-clean
**Repository:** mobinpda-lab/Arvin-clean
**Status:** Canonical operational reference
**Reality authority:** GitHub Repository State
**Assumed execution environment:** AI has GitHub Read + Write + Actions access
**Purpose:** One practical, permanent reference for producing professional working software quickly, safely, in parallel and with continuity.

## 0. Non-Negotiable Principles
1. GitHub is the operational source of truth for code, branches, commits, issues, PRs, workflows, CI, builds and repository documents.
2. This document is the single active governance and software-production reference. Other active governance documents must point here; historical documents remain historical evidence and are not competing authorities.
3. The target is validated working software in hours rather than days.
4. Independent work is executed in parallel by default. Sequential work is used only when a real dependency requires it.
5. Speed never removes quality, security, architecture, validation, evidence, documentation or recovery controls.
6. No AI may claim that a change, test, build, workflow, PR or merge succeeded without direct evidence from the exact repository state involved.
7. Existing capability must be reused. Duplicate models, repositories, storage paths, workflows or documentation layers require explicit justification.
8. «بسم الله الرحمن الرحیم» is an inseparable project principle and must remain present in project identity and continuity documentation.

## 1. Authority Model
**GitHub Reality > Approved ADR/Architecture Decision > This Canonical Standard > Implementation/CI Procedures > Conversation/Memory.**

When sources disagree, do not guess. Verify GitHub and the real implementation, identify the discrepancy, then update the appropriate current-state document while preserving historical records.

Architecture documents describe intended direction. GitHub code describes actual implementation. CI describes validation of a specific ref. Evidence proves what happened. Conversation is continuity context only.

## 2. AI Starting Protocol
Every new session and every meaningful continuation starts with:
`Observe → Audit → Understand → Plan → Parallelize → Execute → Validate → Document → Report`

Before changing anything, AI must check:
- Repository and Read/Write/Actions access
- Current `main` and the working ref
- Recent commits
- Open PRs and their exact heads
- Workflow/CI results for the exact refs
- Relevant documentation and ADRs
- Existing implementation and capability
- Active workstreams and ownership
- Dependencies, conflicts and risks
- Required validation and evidence

The AI must not start from memory alone.

## 3. User Communication Standard
The project owner is not a programmer. Therefore every management answer and project report must:
- Be short, clear, practical and non-technical unless a technical detail is necessary for a decision.
- Explain the result, not the internal process.
- Say plainly: where we are, what was done, current status, blocker if any, and next step.
- Use compact formatting with **no unnecessary blank lines between report items**.
- Be presented as copyable text when it is a response/report intended for reuse or transfer.
- Never bury the important result under technical detail.

Standard report content:
`CURRENT STATE → DONE → STATUS → EVIDENCE → BLOCKER/RISK → NEXT ACTION`

Evidence labels:
- **واقعیت:** directly verified
- **برنامه:** intended next action
- **مسدود:** blocked by a real dependency
- **نیاز به تصمیم:** requires owner decision

Never present an inference as a verified fact.

## 4. Continuation Command
The user command `ادامه` is an execution trigger.

When `ادامه` is received, AI must audit the live repository, compare it with the canonical document and current project state, identify the nearest real unfinished work, and continue safely where possible.

The command does not authorize unsafe, destructive or unvalidated work.

At the end of every Arvin-related response, create a separate copyable text block containing exactly:
`ادامه`

Nothing else belongs inside that final block.

## 5. Hours-Not-Days Execution Model
Arvin is a software factory, not a linear queue.

The preferred production loop is:
`Understand → Audit Reality → Decompose → Identify Dependencies → Create Workstreams → Parallel Execute → Fast Feedback → Evidence → Controlled Integration → Document → Deliver`

Speed comes from removing idle time, duplicate work and unnecessary serialization.

Speed must never come from:
- skipping tests
- bypassing architecture review
- ignoring conflicts
- merging unverified work
- hiding failures
- weakening security
- destroying historical evidence

## 6. Parallel Workstream Governance
Every independent lane must have:
- Objective
- Scope
- Owner/AI
- Input
- Output
- Target branch
- File/foundation boundary
- Dependencies
- Validation method
- Evidence requirement
- Integration point
- Status

Before parallel execution check shared files, shared interfaces, database/migrations, Sync contracts, architecture boundaries and existing work.

If two lanes can safely proceed independently, they should proceed concurrently. A blocked lane must not block unrelated lanes.

Parallel conflict is prohibited.

## 7. Change Paths
### Fast Path
For small, low-risk changes:
`Change → Focused Validation → CI as applicable → Evidence → PR/Review → Merge`

### Parallel Feature Path
`Decompose → Assign → Execute Concurrently → Validate Independently → Review → Controlled Integration`

### Foundation Path
For architecture, database, migration, Sync, security-sensitive or cross-feature changes:
`Audit → Impact Review → Design/ADR → Implement → Migration/Recovery Plan → Validate → CI → Review → Merge → Document`

Always choose the fastest safe path, not the fastest unsafe path.

## 8. Definition of Ready
Work starts when the following are clear:
- What must be produced
- Why it is needed
- What already exists
- Scope and boundary
- Dependencies
- Target branch
- Validation method
- Evidence required
- Integration point

Missing information should be resolved quickly; it must not become a needless multi-day gate.

## 9. Definition of Done
A task is done only when applicable requirements, implementation, validation, evidence, documentation and safe integration are complete.

For product work, completion normally means:
`Working Software + Tests + CI/Build Evidence + Documentation + Review + Safe Integration`

Code completion alone is not delivery.

## 10. Architecture Governance
Target architecture:
- Clean Architecture
- Feature-Based Architecture
- Domain independence from infrastructure
- Controlled dependencies
- Clear repository boundaries
- Stable shared foundation

Target areas include Task, Reminder, FollowUp, Jalali Calendar, Notification, Backup/Restore, Cloud/Dropbox, Google Calendar, PDF/Print, Security, Widget and Lock Screen, subject to verified roadmap and implementation state.

Unified Item/Task remains the shared product foundation. Do not create competing models or persistence systems without an approved architectural reason.

## 11. Sync Engine Governance
Sync Engine is **Foundation Core**, not an ordinary feature.

Its responsibilities include:
- device synchronization
- conflict resolution
- version management
- offline queue
- data consistency
- recovery

It must not own UI logic, feature business rules or independent feature storage.

No feature may create its own Sync source of truth.

Any Sync contract change must address, as applicable:
`Schema Version + Migration Path + Backward Compatibility + Conflict Strategy + Offline Behavior + Recovery + Validation + Rollback`

Sync design is not considered valid until it is reconciled with the real GitHub implementation.

## 12. Data and Migration Safety
Database/storage changes must be incremental, reversible and backward-compatible unless an approved migration explicitly changes that contract.

Never perform destructive migration without:
`Backup Consideration + Migration Plan + Validation + Recovery/Rollback Plan`

Existing user data must not be deleted or rewritten merely to simplify implementation.

Preserve established storage contracts unless an approved migration changes them.

## 13. UI and Product Contract
The approved Arvin UI is a protected product requirement.

Required principles:
- Persian RTL-first presentation
- calm hierarchy and low visual noise
- stable approved navigation and layout
- approved typography, spacing and component behavior
- Jalali calendar support where applicable
- Golden/visual validation for meaningful UI changes

Canonical UI areas include AppShell, Dashboard Timeline, Reminder Card, FollowUp Card, Jalali Calendar, Report Widget and Notification Widget.

The approved Reminder concept remains protected: `یادآور` with the smaller time beside it, title below, expandable details/actions, no fabricated time for all-day reminders, and consistent Lock Screen/widget behavior.

No UI redesign is allowed merely because another design looks newer.

## 14. Quality and Validation
The applicable validation chain is:
`flutter pub get → flutter analyze → flutter test → Integration Validation → flutter build apk → Artifact/Release Validation`

Use additional validation when applicable:
- Unit tests
- Widget tests
- Integration tests
- Golden tests
- RTL checks
- Security checks
- Performance measurements
- Migration tests
- Sync/conflict tests

GitHub Actions is the official repository validation evidence. Local checks are fast feedback and must not be presented as official CI evidence.

A workflow result is valid only for the exact commit/ref it tested.

## 15. Security, Reliability and Recovery
Dependencies require purpose, maintenance, compatibility, security and license consideration.

Reliability includes:
- code recovery
- data recovery
- configuration recovery
- documentation recovery
- environment recovery
- monitoring
- incident response
- rollback

Failure handling:
`Detect → Classify → Assess → Contain → Recover → Validate → Document → Improve`

A backup that has never been recovery-tested is not sufficient proof of reliability.

## 16. Release Governance
Release flow:
`Development → Validation → Release Candidate → Approval → Production → Monitoring`

A release requires, as applicable:
- version/tag
- exact commit
- release notes
- validation evidence
- rollback/recovery plan

## 17. Documentation Governance
Documentation is an engineering artifact, not an optional afterthought.

This file is the **single active canonical operating reference**.

Other documents are classified as:
1. **Current-State Records:** factual status snapshots.
2. **Architecture/ADR Records:** approved decisions and detailed technical references.
3. **Product/Feature Records:** feature-specific requirements and implementation evidence.
4. **Historical Records:** changelogs, dated audits, prior versions and transfer history.

No secondary governance document may contradict this document. If a rule changes, update this canonical document first and then update affected secondary documents.

Historical documents must not be rewritten simply to erase history.

## 18. Knowledge Continuity and AI Handoff
Project knowledge must survive a person, AI session or conversation ending.

Continuity sources:
- this canonical standard
- current-state documentation
- ADRs
- GitHub commits
- PR history
- CI evidence
- implementation
- session/handoff records

Handoff sequence:
`Read Canonical Standard → Read Current State → Audit GitHub → Check Active Workstreams → Check Decisions/Risks → Continue`

If knowledge exists only in conversation, it is not operationally safe.

## 19. Evidence and Reporting
Every meaningful change must leave a trace:
`Requirement → Change → Commit → Validation → Evidence → Documentation → Integration`

Reports must state only what is verified.

For management reporting, prefer one compact block with:
`کجا هستیم | چه انجام شد | وضعیت | مدرک | مانع | قدم بعد`

Technical logs may remain detailed in GitHub, but management reports must remain simple.

## 20. AI Decision Boundaries
AI may execute routine, low-risk, reversible work when the scope is clear and the canonical rules are satisfied.

AI must stop for owner decision when the change materially alters:
- product direction
- approved UI design
- architecture boundaries
- security posture
- data-loss risk
- migration strategy
- major Sync contract
- irreversible production behavior

For major architecture, migration, storage, CI or other high-risk decisions, DeepSeek may be used as an independent second reviewer. It never replaces GitHub evidence or the project owner's decision.

## 21. Conflict and Failure Prevention
Before any concurrent change:
`Detect → Classify → Assign Ownership → Execute Without Overlap → Validate → Integrate`

Prohibited:
- duplicate implementation
- conflicting parallel edits
- direct normal development on `main`
- unreviewed Foundation changes
- claims without evidence
- fabricated CI status
- unnecessary workflow/documentation proliferation
- sequentializing independent work without technical reason
- allowing governance to become an unnecessary bottleneck

## 22. Project Continuation and Status
When continuing work, the AI must select the nearest real unfinished gap from GitHub reality, not invent a new task.

Current project state must be refreshed after meaningful changes and must not contain stale claims about old PRs, branches, commits or tests.

Historical status remains historical; current status must identify its exact ref/date.

## 23. Final Operating Formula
**Fast Delivery = Parallel Independent Work + Automation + Fast Feedback + Controlled Integration + Evidence + Documentation.**

**Professional Delivery = Speed + Quality + Security + Architecture + Recovery + Traceability.**

**Final objective: produce validated working software in hours rather than days without losing control.**

## 24. Canonical Document Rule
This file is the single operational reference for future Arvin software production.

When another governance document conflicts with this file, this file governs unless an approved newer version explicitly replaces it.

When the repository and this document disagree about implementation state, GitHub wins and this document must be updated.

**Canonical path:** `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`
**Current version:** v49.0

## 25. Owner Communication Contract
All AI answers/reports for the project must be:
- copyable
- compact
- understandable without programming knowledge
- free of unnecessary blank lines
- focused on result and next action
- explicit about what is verified versus planned

The final continuation marker is always separate from the main answer/report and contains exactly the word `ادامه`.

## Version Lineage
v47.x/v48.0 = governance foundation.
v48.1 = execution optimization and parallel-speed enhancement.
v48.2 = approved integrated/editorial operational reference.
v49.0 = unified canonical software-production standard incorporating governance, execution, architecture, Sync, UI, quality, recovery, documentation, continuity and communication rules.

Historical v48.x documents remain evidence of evolution; they are not competing active authorities.
