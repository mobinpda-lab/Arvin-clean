# ARVIN Code Change Plan Phase 7 — Module Execution

## Purpose

Convert the approved Arvin UI and product contracts into controlled implementation work.

## Execution order

1. Home convergence
- Match final reference layout.
- Keep real Task data.
- Implement grouping without duplicating records.
- Remove deprecated UI assumptions.

2. Quick Entry
- Use the canonical save path.
- Preserve selected metadata after successful consecutive saves.
- Protect drafts on back and close actions.

3. Task Detail and FollowUp
- Preserve history.
- Add follow-ups as records, not replacements.
- Keep dates, reminders and due dates independent.

4. Notebook
- Preserve existing storage.
- Support note and checklist flows.
- Keep editor content focused.

5. Calendar and Settings
- Connect actions to real data.
- Avoid placeholder controls.

## Change rules

- No parallel data models for visual similarity.
- Existing repositories and services are preferred.
- Every change requires analysis, tests and Android verification where applicable.

## Completion states

Documented → Coded → Data Connected → Tested → Android Verified
