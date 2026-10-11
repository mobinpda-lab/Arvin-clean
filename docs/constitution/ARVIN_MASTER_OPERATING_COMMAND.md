# ARVIN MASTER OPERATING COMMAND (AMOC)
**Version:** 1.0  
**Repository:** mobinpda-lab/Arvin-clean  
**Role:** Governing product and architecture command

## Authority
GitHub is the permanent operational source of truth for code, issues, decisions, branches, pull requests, workflows, evidence and status. This command defines product-wide invariants. The [Arvin Project Operating Package](../ARVIN_PROJECT_OPERATING_PACKAGE.md) is the detailed execution standard subordinate to AMOC. Actual implementation and exact-ref validation determine what exists; documentation alone never proves implementation. Preserve historical evidence and do not maintain competing active governance documents.

## Mission — PRODUCT FIRST
Arvin must become complete, beautiful, fast, stable, reliable and useful every day. GitHub, CI, automation and factories are tools; user outcomes are the goal. Product identity is **Task + Time + Organization + Follow-up + Trust**. Release readiness requires evidence and explicit owner approval.

## Required execution loop
1. Inspect live repository, current main/ref and commit, open issues/PRs and exact heads, CI evidence, decisions, docs, implementation and tests.
2. Search and reuse existing models, services, storage, UI, workflows and tests before creating anything.
3. Compare the requested change with current architecture and accepted decisions.
4. Record important decisions before implementation, including rationale, impact, data risks and required owner approval.
5. Implement the smallest safe change. Run independent workstreams in parallel only when boundaries and dependencies are safe.
6. Validate the exact changed ref with applicable tests, builds, integration, device and data checks.
7. Record evidence, update status/decision/evidence docs and report verified facts, unknowns, blockers and next steps.
8. Never claim success without exact-ref evidence. Continuation does not authorize unsafe, destructive or unvalidated work.

## Canonical Task and product contracts
- Task is the single canonical identity for work. Home, Calendar, Search, Notifications, Reports, Backup and Restore consume or project Task data; none owns a parallel task system.
- **Project** is the main work domain; **Category** is grouping/classification; Category and Group are one concept; **Tag** is a free, multi-valued label. Follow accepted ADRs and verify implementation.
- Quick Add and Full Task Editor are two entry paths for the same Task and must preserve draft/task identity through edit, save, cancel and retry.
- Checklist is an optional Task capability, not an independent app/store/workflow. For repeatable work, each occurrence has its own execution state.
- Repeat follows **Task → Repeat Definition → Occurrence → Execution State → History**. Do not create duplicate canonical Tasks per occurrence. Past history is immutable under the accepted contract; future changes must not corrupt past execution.
- Tracking, Follow-up and Next Action remain capabilities attached to Task, not a parallel CRM.
- Calendar is a projection/external-event bridge. Reuse Task ID + external Calendar ID + external Event ID. Editing a linked Task must update the same event, not create a duplicate.
- Home is a daily view with Time, Project, Category and Tag dimensions. Search reads Task data. Reports derive from Task/Occurrence/History.

## Data safety
Before storage, schema, migration, Sync, backup or restore changes, inspect all affected and legacy paths. Establish backup, compatibility, validation, rollback/recovery and restore-test plans before destructive operations. Preserve user data, identifiers, relations, checklist, repeat, tracking, follow-up, history and calendar links. A backup is not proven reliable until a restore round-trip and integrity comparison succeed.

## UI, validation and parallelism
Protect the approved Persian RTL Arvin identity. Do not redesign approved UI without a clear product reason and review. Meaningful UI changes need focused tests, screenshots/visual review and real-device validation where applicable. Parallelize independent Core, UX, Test, Build/Release and Documentation work when file boundaries, interfaces, migrations and dependencies permit; never run conflicting edits or unsafe parallel migrations.

## Release gate
Applicable core flows must be validated: Task, Time, Project, Category, Tag, Checklist, Repeat, Tracking, Follow-up and Calendar; plus Backup/Restore, Migration and Integrity; plus Analyze, tests, builds, integration and Android-device validation. Golden Flow: create Task → date/time → organize → checklist → repeat → follow-up → calendar/sync → edit same Task → update same event → complete occurrence → backup → restore → compare integrity. Missing, skipped or unknown evidence is not PASS. Never bypass explicit product-owner release approval.

## Decisions and evidence
Important changes must be traceable: **Need/Issue → Decision/ADR when required → Change → Commit → Test/Control → Evidence → Status**. Record rationale, impact, protected behavior, data risk, approval, related issue/PR and remaining gaps. Use evidence-bounded statuses such as PASS, PARTIAL, FAIL, BLOCKED or UNKNOWN; unknown is not PASS.

## Continuation
The user command **ادامه آروین** triggers a live GitHub audit and safe continuation of the nearest feasible unfinished product work. It is not merely a report footer. If one lane is blocked, continue independent safe work. Do not merge, release, alter data destructively or bypass approval without required authority.

## Final rules
Before changing: inspect. Before creating: search and reuse. Before deciding: record. Before declaring done: prove. Before release: validate and obtain approval. Keep reports concise, product-focused and understandable to a non-programmer. Preserve the project principle: «بسم الله الرحمن الرحیم».

**Related execution standard:** [Arvin Project Operating Package](../ARVIN_PROJECT_OPERATING_PACKAGE.md)  
**Status:** This document records requirements; it does not assert every requirement is implemented or release-accepted.
