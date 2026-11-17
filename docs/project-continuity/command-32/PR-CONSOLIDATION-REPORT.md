# COMMAND 32 — PR Consolidation Report
Checkpoint: 2026-11-18
Canonical PR: #3495
Canonical HEAD: `ed93d6ad30bfe4e75199f297efda0a2b8099ce49`
Main: `45e4202b03a434459e4c021a04efa7e8396359db`

## Canonical state
- PR #3495: OPEN / DRAFT / UNMERGED.
- Base: main. Head: recovery-02/main-based-integration.
- 143 commits; 143 ahead / 0 behind; 127 changed files.
- Main was not changed.

## Commits added by COMMAND 32
- `8dee3947939b941a48be4a5882b10fcf3ec20ab4` — preserve All-Day due time and harden Zero-Dollar workflow.
- `ed93d6ad30bfe4e75199f297efda0a2b8099ce49` — preserve Follow-up extensions and historical Person IDs.

## Consolidated code changes
### A01 — All-Day
Task JSON serializes allDay explicitly, including false. Task editor caches the selected time before switching to All-Day and restores it when switching back. Model and widget regression assertions were added.

### A02 — Follow-up Metadata
FollowUp carries opaque extensionData. Unknown JSON fields are decoded/serialized without overriding canonical fields. SQLite schema v8 adds nullable follow_ups.extension_json additively. TaskStore reads/writes the payload in the same row. File-backed close/reopen and JSON round-trip tests were added.

### A03 — Person Identity
Restore no longer rejects a historical Follow-up person ID merely because its person is absent from the active directory. Follow-up IDs remain stable; report projection already renders a missing directory person as a placeholder. No same-name merge or destructive ID rewrite was introduced.

### W01 — Zero-Dollar Workflow
GitHub expression escapes removed. KVM permission mutation removed. Fixed direct-parent SHA equality replaced with an immutable Main merge-base check, permitting ordinary subsequent commits while proving expected base ancestry. PR #3495, canonical branch, label, Main SHA and read-only permissions remain guarded.

## Not yet consolidated
- M2M v19/v20 from #3463: not copied; depends on #3384 dependency closure and lacks accepted sequential file-backed v7→v20 proof.
- Typography #3470: not copied wholesale pending visual/RTL review.
- #3346/#3366 editor patches: not copied wholesale because some referenced fields are absent from canonical Task.
- #3376/#3380/#3382: evidence sources, not production code.
- Full unique-commit transfer audit across all PRs remains incomplete.

## Current CI
For exact SHA `ed93d6ad30bfe4e75199f297efda0a2b8099ce49`:
- COMMAND 20-E run 44191698513: IN PROGRESS at last check.
- Device Smoke run 44191698618: preparation SUCCESS; selected lanes queued or in progress.
- No Build / full test / Analyze PASS is claimed.
