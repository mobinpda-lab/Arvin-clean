# Arvin — Canonical Project State

**Updated:** 2026-08-16
**Repository:** https://github.com/mobinpda-lab/Arvin-clean
**Default branch:** `main`

## Purpose
Arvin is a Flutter/Dart Persian, RTL-first Personal Assistant / Life & Work Organizer.

## Source of truth
- GitHub `main` is the source of truth for code.
- This file is the canonical compact project-state handoff for future chats and AI reviewers.
- When this file conflicts with current repository code or CI, verify the repository and update this document.

## Architecture invariant
The primary product/data flow is:

`Unified Item → Reminder → FollowUps[] → History`

Do not create parallel repositories, storage layers, or competing models for Task, Note, CRM, Voice, Memory, or FollowUp without an explicit architecture decision.

## UI/UX governance
Visual quality is a first-class product requirement and must be protected from accidental drift.
- Approved direction is defined in `docs/contracts/UI_VISUAL_ACCEPTANCE.md`.
- Governance rules are defined in `docs/UI_UX_GOVERNANCE.md`.
- Persian RTL-first, clean, fast, modern and task-focused UI is mandatory.
- Right-side navigation/drawer is the approved navigation direction.
- ChatGPT-like simplicity and clarity is a UX reference.
- Future AI agents/developers must review these documents before material UI changes.
- Material UI changes require small isolated changes, relevant CI validation, and real-device visual acceptance when appropriate.
- No UI change may introduce a parallel data/storage/model architecture or be made merely to make CI green.
- Significant design decisions should receive independent DeepSeek cross-review.

## Current development state
- Overall project progress: approximately **62%** (management estimate, not a CI metric).
- Core architecture: approximately **80%**.
- Unified Item migration: **active / progressing**.
- FollowUp: approximately **70%**.
- Calendar foundation: approximately **70%**.
- UI: approximately **60%**; final visual acceptance is not complete.
- Real Iran calendar providers: approximately **35%**.
- Native Widget foundation: approximately **40%**.
- E2E / real APK release readiness: approximately **45%**.
- Documentation: active and required for significant changes.

## Latest verified development history
Recent commits on `main` include the temporary debug APK artifact build, followed by the UI/UX governance documentation commit.
- `e77093f6` — `ci: add temporary debug apk artifact build`
- `6237f6b1` — `docs: establish UI/UX governance to prevent visual drift`

## Current gates / bottlenecks
1. Unified Item migration / Save Migration.
2. Real Iran calendar providers.
3. Native Widget foundation.
4. UI Visual Acceptance and visual-direction protection.
5. E2E validation on a real APK.
6. Confirm GitHub Actions trigger/permission behavior with actual workflow runs.

## Product extension roadmap
The following capabilities are approved as a product-development roadmap, not as permission to implement them all immediately:

1. Next Action intelligence
2. Automatic FollowUp
3. Full topic Timeline
4. Persian Voice Capture
5. Arvin intelligent assistant
6. People / Contacts
7. Semantic Search
8. Smart Weekly Review
9. Arvin Memory
10. Waiting-for-response state
11. Quick Capture
12. Smart Calendar Assistant
13. Conflict detection / smart scheduling
14. Smart Rescheduling
15. Goal → Project → Item
16. Location Reminder
17. Privacy / Encryption
18. Multi-device Sync / Backup
19. Iran-focused Personal Assistant capabilities

All extensions should reuse the existing Unified Item architecture wherever possible.

## Product differentiation target
Arvin should not become a feature-count clone of Todoist/TickTick/Any.do.
Target identity: **"Arvin — don't lose any topic."**

Core differentiation:
- Topic state and history
- FollowUp engine
- Next Action
- Waiting-for-response tracking
- People/context
- Persian/RTL and Iran-focused experience
- Future Memory / semantic intelligence

## GPT + DeepSeek collaboration protocol
- GPT: architecture, product strategy, prioritization, final audit and change coordination.
- DeepSeek: independent code review, bug/regression finding, Flutter/Dart review, test/CI/performance review and alternative implementation suggestions.
- DeepSeek must not independently modify the main branch without review/coordination.
- Preferred flow: Audit → independent review → decision → small change → tests → workflow/CI → commit → audit.

## Mandatory change protocol
Before every meaningful change:
1. Inspect the whole relevant architecture and recent commits.
2. Check whether the capability already exists.
3. Identify dependencies and regression risks.
4. Check UI/UX governance when the change can affect appearance or interaction.
5. Avoid parallel architecture and duplicate storage/models.
6. Make the smallest coherent change.
7. Update relevant documentation/history.
8. Run tests.
9. Verify the actual GitHub Actions workflow result; never assume green.
10. Commit with a clear message.
11. Re-audit the resulting state.

## Immediate next-action rule
Before starting new feature work, re-audit `main`, recent commits, open gates, and CI status. Prioritize stabilization of Unified Item Save Migration, Calendar, Widget foundation, UI acceptance, and APK/E2E before broad feature expansion.

## Handoff instruction
For a new chat or AI reviewer: treat this file and `docs/UI_UX_GOVERNANCE.md` as project constraints, then verify them against the current GitHub repository before making any change. Do not rely on an old chat transcript when the repository can answer the question.