# Arvin Project Knowledge
**Checkpoint:** 2026-10-11  
**Source of truth:** live GitHub repository and exact-head workflow evidence.

## Stable product/architecture knowledge
- Task is canonical; Calendar is a projection and Reports are read-only consumers.
- Project, Category and Tag are canonical taxonomy concepts; do not create a separate Group entity.
- Quick Add and Full Form must create/update the same canonical Task identity.
- Checklist and recurrence belong to Task. Recurrence preserves the parent Task and history; it must not create independent copied Tasks.
- Calendar synchronization identifies existing events using Task ID and External Event ID, not title/date matching.
- Preserve Persian RTL and VazirHarf v34.003; do not substitute Vazirmatn.
- Preserve user data, stable IDs, backup/restore safety, and existing storage ownership.
- UI work must retain the approved product identity while improving compactness, clarity, empty states, feedback and cross-screen consistency.

## Validation lessons
- Build success does not prove tests or installed-device UX.
- An orchestration workflow marked successful does not replace the relevant build/test/device evidence.
- If progressive disclosure hides advanced controls, widget tests must open that section before interacting with it; a missing widget in the test may be a test setup issue, but behavior must still be verified on the exact PR head.
- Overlapping Draft PRs should be reconciled rather than independently merged when they change shared time/date components.

## Current known follow-up
See `ARVIN_EXECUTION_STATE.md` and the linked PRs/issues for current live status; do not use this static note as a substitute for a fresh audit.
