# Implementation Plan — Future Authorization Only

No phase below is authorized by COMMAND 55-R. Each requires a separate approval and independent evidence.

## Phase A — Implementation
- Confirm V20 slot reservation with the approved M2M plan; if unavailable, re-sequence to V21.
- Implement strict V19 adapter and duplicate-key JSON validation.
- Implement additive presence/opaque columns and receipt/ledger schema.
- Implement source/destination state machine and insert-only reconciliation.
- Integrate with one serialized database-open coordinator before TaskStore reads/writes.
- Keep historical V19 installer, fixture V7 and Main unchanged.
- Add deterministic fingerprints and structured diagnostics.
- Code review specifically prohibits ignore/replace/upsert and destructive cleanup.

Exit: code review accepted; exact source/target hashes recorded; no physical acceptance implied.

## Phase B — Physical Testing
- Build disposable file-backed V19 fixture variants.
- Run tests T01–T30 on isolated independent files.
- Inject process termination and transactional failures.
- Capture exact-head CI and local runtime evidence.

Exit: all required physical tests pass on the same implementation SHA.

## Phase C — Data Preservation
- Compare every Task, Occurrence, checklist row, nullable presence bit and opaque payload.
- Verify recurrence and all unrelated entity snapshots remain unchanged.
- Verify all IDs and FK relationships.

Exit: zero unexplained differences.

## Phase D — Failure Recovery
- Verify rollback at each failure point.
- Verify receipt atomicity.
- Verify backup restore to a new file.
- Reopen and re-run integrity, FK and TaskStore checks.

Exit: restore is independently proven, not inferred from backup file existence.

## Phase E — Compatibility
- Test V19 databases with source intact, target empty, target matching, target conflicting, source missing, partial installer and unknown schema objects.
- Confirm ambiguous cases halt without mutation.
- Test old app behavior and document downgrade restrictions.

Exit: all supported states have deterministic decisions; ambiguous states are blocked safely.

## Phase F — Acceptance
- Independent reviewer inspects source pins, code diff, fixture definitions, exact-SHA logs, snapshots, receipt and restore artifacts.
- Product Owner reviews unresolved risks and version sequencing.
- Issue a written GO/NO-GO decision.

Exit: explicit acceptance; no automatic phase progression.

## Phase G — V20 Evaluation
Only after Phases A–F are accepted may the owner evaluate V20. This phase is not an execution authorization.

## Stop conditions
Any source SHA drift, unexpected schema object, unknown field loss, mismatch, receipt inconsistency, restore failure, test failure, or unexplained snapshot difference halts the phase. No branch merge, release, deployment, or production-user database operation is implied.
