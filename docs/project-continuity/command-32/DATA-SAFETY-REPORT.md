# COMMAND 32 — Data Safety Report
Checkpoint SHA: `ed93d6ad30bfe4e75199f297efda0a2b8099ce49`

## Safety boundaries
- No Main write, merge, release or deployment.
- No real-user database opened or mutated.
- No migration executed against production or user data.
- Schema v8 is code-only and additive; file-backed test is added but not yet executed in CI at this checkpoint.
- No existing SQL columns or tables dropped.
- No user records deleted by this command.

## A01 — All-Day
Risk addressed: toggling All-Day previously zeroed due time without retaining it. Change: preserve selected time in editor state and restore it when All-Day is disabled; serialize false explicitly. Remaining risk: tests must pass on exact SHA; timezone/DST edge cases need coverage when due dates cross DST transitions.

## A02 — Follow-up extension metadata
Risk addressed: unknown future Follow-up JSON fields were discarded by model decoding and SQL reconstruction. Change: opaque extensionData is carried by FollowUp; SQL stores it in nullable extension_json on the same row; old rows remain readable because the column is nullable and added only if absent. Required proof: file-backed close/reopen, repeated save cycles, Backup/Restore, null/unknown-key parity and injected rollback.

## A03 — Historical Person identity
Risk addressed: Restore rejected an ID referenced by historical Follow-up when the person was absent from the active directory. Change: preserve stable ID in Follow-up; absence from active directory is not treated as corrupt backup data. Identity matching is by ID only; no same-name matching or automatic merge. Report projection supplies a deleted-person placeholder. Remaining risk: file-backed save → backup → restore → report round trip and local-only directory preservation.

## W01 — Workflow
Risk addressed: escaped expressions, stale fixed direct-parent assumption, broad KVM permission mutation. Change: correct expressions, validate merge base against expected Main SHA, and require existing KVM read/write access without chmod. Remaining risk: execute on authorized labeled PR event and confirm no permission change.

## H01 — Calendar Restart
The previously audited baseline had a fixed 90-second PID wait and did not complete Stage B. The later canonical branch extended polling to 1,800 seconds and retains Stage A, force-stop, Stage B fresh read, eight-value comparison and test-key cleanup. This is an improvement, not proof of success. COMMAND 20-E on current exact SHA is still in progress/pending.

No-loss acceptance is NOT ACCEPTED until file-backed, migration, Backup/Restore, Restart and regression tests pass on one exact SHA.
