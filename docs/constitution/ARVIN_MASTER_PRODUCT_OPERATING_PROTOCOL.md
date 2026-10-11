# ARVIN MASTER PRODUCT OPERATING PROTOCOL (AMPOP)
**Version:** 5.0  
**Project:** Arvin (آروین)  
**Status:** Proposed in open draft PR; not active on main until reviewed and merged.

## Mission
Turn Arvin into a real, complete, trustworthy, beautiful, fast, stable, extensible product for daily use. This is the highest product-operating command. All development, architecture, UI/UX, database, automation, AI-agent, factory, CI/CD and release work must follow it. Important changes outside this framework are not valid project decisions until properly reviewed and recorded.

## 1. Project authority
GitHub is Arvin's official permanent memory. Use this evidence hierarchy:
1. GitHub reality — exact code, refs, issues, PRs, workflows and artifacts
2. Existing implementation
3. Tests
4. Documentation
5. Decision records
6. Evidence reports
Conversation memory and undocumented verbal proposals are not official project records. Every important decision must record: Problem, Context, Decision, Reason, Impact, Implementation, Validation, Evidence and Status. Actual repository state establishes what exists; documentation or a passing workflow alone does not prove product acceptance.

## 2. Product identity
Arvin is a **Personal Work Management System**, not merely a Todo list. Its identity is **Task + Time + Organization + Tracking + Follow-up + Trust**. It helps users know what they need to do, what matters, what is overdue and what the next action is.

## 3. Startup protocol
Before acting, inspect latest main and commit history; Issues and PRs; repository structure; documentation and architecture; tests; CI/CD and automation; current status and decision log. Do not change anything before understanding the actual state.

## 4. Required execution loop
**READ → UNDERSTAND → CHECK EXISTING → CHECK ARCHITECTURE → REGISTER DECISION → IMPLEMENT → TEST → VALIDATE → CREATE EVIDENCE → UPDATE PROJECT RECORDS.**

## 5. No rebuild
**FIX EXISTING, NOT REBUILD.** Search code, model, service, component, test, issue, PR and documentation before creating anything. Improve existing capabilities, complete incomplete paths and repair defects. New components require a recorded reason. Duplicate entities, storage, workflows, engines and parallel architecture are prohibited unless explicitly approved by an evidence-backed decision.

## 6. Core architecture
Task is Arvin's single source of truth. Its canonical capability set includes Title, Description, Date, Time, Project, Category, Tags, Priority, Checklist, Repeat, Tracking, Follow-up, Next Action, History and Calendar Link. Every system must consume or project canonical Task data rather than create a parallel task-management system.

## 7. Domain rules
- **Project:** main work domain.
- **Category = Group:** one concept only; a separate Group domain entity/model/store is prohibited.
- **Tag:** independent, multi-valued label. Task-to-Tag is many-to-many (N:M).
- Do not infer that a rule is implemented; verify the real model, storage, UI, tests and backup paths.

## 8. Quick Add
Quick Add and Full Form are two experiences for one Task. Flow: **Quick Add → same Task/draft → Full Detail**. Preserve draft and Task identity through transition, cancel, retry and save. No premature save, duplicate Task or parallel persistence path.

## 9. Checklist contract
Checklist belongs to Task; no independent checklist app, database or workflow. Model: **Task → Checklist Definition → Checklist Execution State**. For repeated work, each occurrence has independent execution state. Changing one occurrence must not alter another or corrupt history.

## 10. Repeat contract
Repeat is a Task capability, not a separate system. Model: **Task → Repeat Definition → Occurrence → Execution State → History**. Definition includes Pattern, Interval, Start Date, End Date, Count and Active Status. Preserve the canonical Task; do not create Task copies. Past history is immutable under the accepted contract; future changes must not rewrite past execution.

## 11. Tracking and follow-up
Tracking and Follow-up are core Arvin capabilities. Tracking represents work still needing attention; Follow-up defines the next step toward an outcome. Model: **Task → Tracking State → Follow-up → Next Action**. Do not turn Tracking into a separate CRM or task store.

## 12. Calendar contract
Calendar does not own Task; Task remains canonical. Calendar is a projection and external-event bridge. Each link uses Task ID, External Calendar ID and External Event ID. Identify sync by stable IDs. First sync creates; later sync updates the same event. Never create a duplicate event on every sync.

## 13. Home experience
Home is the daily management center and should answer: What do I have now? What matters? What is overdue? What comes next? Primary dimensions are Time, Project, Category and Tag. Home has no independent task storage and does not create a separate Task system.

## 14. UX and visual contract
Arvin should feel like a Personal Assistant: Simple, Clear, Calm, Hierarchical, Consistent, Progressive Disclosure and Low Friction. Preserve Persian-first experience, RTL, typography, spacing, cards, empty states, feedback and error handling. Beauty must not reduce speed or clarity. Respect approved product UI decisions unless a reasoned change is reviewed.

## 15. Search and reports
Search consumes canonical data; Reports do not own data. Reports derive from Task, Occurrence and History. Do not create a parallel report store or duplicate task model.

## 16. Data safety
Backup must preserve the entire Task universe: Tasks, relations, Checklist, Repeat, Tracking, Follow-up, History and Calendar Links. Before any migration or risky persistence change: take/verify a backup, define rollback/recovery, validate compatibility and run a restore test. Do not perform destructive changes without approved recovery and integrity checks.

## 17. AI and developer governance
AI and developers follow **Analyze → Compare → Recommend → Approve → Implement → Validate**. No guessing without inspection, architecture change without a record, Done without evidence or parallel replacement systems. AI acts as Guardian of Architecture. Approval is required for high-risk/destructive work and release; continuation is not blanket approval.

## 18. Factory and CI
Factories must Build, Test, Validate, Produce Evidence and Report. Do not create another factory merely to repair a factory. Automation must be repeatable, trustworthy and observable. A green workflow proves only its own checks, not device behavior or product readiness.

## 19. Evidence rule
Nothing is Done without applicable **Code + Test + Build + Validation + Evidence**. Evidence may include exact commit, test results, screenshots, device results and validation reports. Mark missing checks UNKNOWN/BLOCKED, not PASS. For documentation-only changes, state that app behavior was not validated rather than pretending code/build evidence applies.

## 20. Release gate
Release requires evidence for core capabilities: Task, Time, Project, Category, Tag, Checklist, Repeat, Tracking, Follow-up and Calendar; data safety: Backup, Restore, Migration and Integrity; quality: Build, Test, Device Validation and Evidence. Release readiness also requires explicit product-owner approval. No release or merge may bypass required review and approval.

## 21. Golden user flow
Create Task → Set Date/Time → Assign Project → Assign Category → Add Tags → Create Checklist → Enable Repeat → Set Follow-up → View Calendar → Sync → Edit same Task → Update same Event → Complete → Backup → Restore → Verify Integrity. Record results for the exact tested version; do not imply the flow passed unless it actually did.

## 22. Scope control
Every new capability must answer: Is this a real user problem? Does it align with Task Core? Does it bring release closer? Does it introduce new risk? If it fails those tests, move it to Future Scope unless the owner explicitly prioritizes it.

## 23. Knowledge transfer
Every new AI/developer must read this protocol, check current Status, read Decision Log, inspect the repository and understand architecture before changing anything.

## 24. Continuous maintenance
Periodically inspect architecture drift, data risk, broken flows, test health, evidence status and release readiness. Agents may monitor, analyze and report; risky changes require approval.

## Final command
Before any change: inspect. Before creating: search. Before deciding: record. Before executing: obtain required approval. Before release: prove.

**Goal:** a trustworthy, simple, beautiful, stable, extensible work/time/follow-up system that remains maintainable independently of any one person.

**Related detailed execution standard:** [Arvin Project Operating Package](../ARVIN_PROJECT_OPERATING_PACKAGE.md)  
**This document states governing requirements; it does not assert that the requirements have all been implemented or accepted.**
