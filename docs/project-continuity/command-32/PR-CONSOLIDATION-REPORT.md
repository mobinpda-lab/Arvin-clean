# COMMAND 32 — PR Consolidation Report
Code checkpoint: `687341469152035053f6325b671c4bad9dab8c96`
Main: `45e4202b03a434459e4c021a04efa7e8396359db`

## Canonical state
- PR #3495 — OPEN / DRAFT / UNMERGED.
- Branch: recovery-02/main-based-integration.
- HEAD: `687341469152035053f6325b671c4bad9dab8c96`.
- Compare: 149 commits ahead, 0 behind; 134 changed files.
- Main unchanged.
- Current canonical is the only approved development destination.

## Consolidated implementation
### A01
Task JSON explicitly serializes allDay true and false. The editor caches the selected hour/minute before All-Day and restores it when toggled off. Model and widget tests passed on this checkpoint.

### A02
FollowUp preserves unknown fields in extensionData. Schema v8 adds nullable follow_ups.extension_json additively; TaskStore reads and writes it on the same row. JSON round-trip and file-backed close/reopen tests passed on this checkpoint.

### A03
Restore accepts stable historical Follow-up Person IDs absent from active peopleDirectory. Existing history projection displays a deleted-person placeholder. No same-name merge or ID rewrite introduced. Historical orphan restore test passed.

### W01
Escaped GitHub expressions removed, KVM chmod removed, fixed direct-parent assumption replaced with Main merge-base check. However the Zero-Dollar workflow did not obtain a successful executable run; see TEST-ACCEPTANCE. Trigger/branch-base mechanics remain a blocker.

### H01
Commit `6873414` adds a three-second SharedPreferences disk-flush wait and captures app-private XML before force-stop. COMMAND 20-E reached the real SharedPreferences restart stage after Analyze and ProjectStore file-backed test passed. Stage B result is pending.

## PRs closed after source comparison
- #3365
- #3348
- #3341
All branches retained.

## Not consolidated
- #3463 M2M v19/v20 dependency stack.
- #3470 typography contract.
- #3366/#3346 editor changes with incompatible fields.
- #3364/#3356 SQL envelope / migration-writer residuals.
- #3376/#3380/#3382 diagnostic evidence.
- Full 113-open / 521-closed-unmerged PR audit.

NO-GO for final repository consolidation or release.
