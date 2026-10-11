# Arvin Decision Log
**Checkpoint:** 2026-10-11  
**Authority:** owner-approved product contracts and live GitHub evidence. This log records decisions; it does not imply implementation acceptance.

## D-001 — Task is canonical
- **Problem:** Calendar, Home, Reports and recurrence could drift into independent ownership.
- **Decision:** Task remains the canonical source of truth; Calendar is a projection; reports are read-only; Checklist and Repeat belong to Task; repeat occurrences must not become copied Tasks.
- **Reason:** Preserve identity, history and consistency across screens.
- **Impact:** New work must reuse canonical IDs, repositories and persistence.
- **Status:** Product contract; continue regression validation.

## D-002 — Persian-first date/time UI
- **Problem:** User-facing date/time controls can fall back to generic Gregorian/clock dialogs.
- **Decision:** Use Persian/Jalali date presentation and Persian digits, and reuse the shared Universal Arvin Time Picker instead of duplicating time-picker implementations.
- **Reason:** Consistent RTL product experience.
- **Impact:** Report filter's generic time picker remains a tracked gap until the overlapping PRs are reconciled.
- **Status:** Accepted direction; implementation/Android acceptance pending.

## D-003 — Task Editor progressive disclosure
- **Problem:** Full form is crowded, but hiding advanced fields can break established test paths.
- **Decision:** Keep title/description/taxonomy as the simple first path and collapse advanced details by default; tests interacting with advanced fields must explicitly expand the section.
- **Reason:** Lower friction without removing advanced capability.
- **Impact:** PR #2602 test updates are in progress after exact-head CI exposed failures.
- **Status:** In progress; do not accept until full test shards pass.

## D-004 — Release evidence discipline
- **Problem:** Build success or orchestration success can be mistaken for release readiness.
- **Decision:** Require exact-head code/tests/build and relevant device/owner acceptance; skipped Device Smoke is not device proof.
- **Reason:** Prevent unsupported completion claims.
- **Impact:** Draft PRs and skipped device checks remain open gates.
- **Status:** Active rule.
