# Arvin-clean — Project Documentation Principles

**Date:** 2026-08-20

## Purpose
This document establishes the documentation contract for Arvin-clean so that project status, decisions and development continuity remain synchronized with reality.

## Four-source alignment
Every meaningful decision should be aligned across:

1. **Live GitHub state** — repository, code, branches, commits, PRs, workflows, tests, builds and merges.
2. **Project documentation** — architecture, governance, roadmap, contracts, audits and changelogs.
3. **Established project memory/decisions** — prior agreements and constraints carried between conversations.
4. **Real code** — inspected whenever implementation behavior or architecture is in question.

GitHub is authoritative for what actually happened. Documentation is authoritative for the agreed architecture, governance and roadmap. Conversation memory provides continuity but never overrides current repository evidence.

## Required workflow
`Audit → documentation/code comparison → real gap → smallest change → focused test → commit → workflow/CI → validation → documentation update → next task`

## Discrepancy rule
If sources disagree:
- identify the discrepancy;
- verify current GitHub and code;
- determine whether the difference is historical, documentary or executable;
- update the appropriate current-state/handoff document;
- preserve historical records rather than rewriting history without reason.

## No duplicate work
Before creating work, inspect existing branches, PRs, commits, workflows and relevant documentation. Do not rebuild an existing capability or start a parallel implementation when an existing one can be extended safely.

## Parallel + simultaneous + fast
The project goal is software delivery in **hours rather than days** through controlled parallel execution.

Independent work should proceed simultaneously whenever safe. Shared foundations and shared files require explicit coordination so parallel work does not create conflicting implementations or merge conflicts.

Speed must not mean skipping tests, review or validation.

## Documentation update triggers
Update the appropriate current-state, handoff, audit or changelog documentation when there is a meaningful change to:
- architecture or migration strategy;
- storage/model boundaries;
- CI/CD or workflow behavior;
- roadmap or wave ownership;
- important product decisions;
- validation status;
- major implementation milestones;
- development governance.

## Reporting rule
A project report must distinguish between:
- verified facts;
- current work;
- remaining work;
- assumptions or unresolved questions.

Never report an unrun workflow as green. Never present a historical CI result as validation of a newer commit.

## Continuation command
When the user says `ادامه آروین`, the assistant should:
1. verify live GitHub access and repository state;
2. inspect current branches, commits, PRs and workflows;
3. review relevant project documentation;
4. identify the nearest real unfinished task;
5. avoid duplicate work;
6. act on the repository when write access permits;
7. validate the exact resulting commit/ref;
8. update relevant documentation when the change is meaningful;
9. report the result in simple management language.
