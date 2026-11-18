# COMMAND 54-R — Implementation Location Decision

**Decision: Do not modify historical V19. Do not implement against the current schema-v9 investigation tree. Reserve the repair for a separately versioned forward migration, with a compatibility adapter for legacy envelopes.**
**Status:** DESIGN ONLY — no implementation authorized.

## Option A — Patch V19 migration code in place
**Advantages**
- The defect is physically located in the V19 installer/codec.
- It could repair first-run behavior for a user whose application executes that exact code.

**Risks / compatibility**
- Existing installed V19 binaries and databases do not retroactively receive a source-code patch.
- Rewriting the historical installer/codec violates the preservation boundary and makes historical reproduction ambiguous.
- A patched V19 implementation alone does not define safe behavior for databases already normalized by the old V19 code.
- It risks changing historical fixture outcomes and migration provenance.

**Decision:** REJECTED for this project command.

## Option B — Add a forward, versioned migration
**Advantages**
- Preserves the historical V19 source and immutable fixture.
- Can inspect both legacy envelope state and already-normalized V19 rows.
- Can introduce a durable receipt and opaque/key-presence metadata transactionally.
- Can be independently tested against pristine V7-derived copies and already-V19 databases.

**Risks**
- Requires an authorized later schema release/version; COMMAND 54-R does not authorize V20 or any release.
- Must not assume every deployed database is at the same intermediate shape.
- A forward migration cannot reconstruct unknown or explicit-null values that were already irreversibly retired by an earlier successful migration. It can preserve and repair only data still present in the legacy envelope or otherwise retained in a trusted source.
- It must validate existing destination rows rather than treating absence of source keys as an empty expected dataset.

**Decision:** PREFERRED LOCATION, but design only. No version number is assigned in this command.

## Option C — Independent legacy compatibility layer
**Advantages**
- Separates old JSON interpretation from normalized SQL persistence.
- Can centralize key-presence semantics, unknown-field payload handling, and source-version decoding.
- Can support both legacy-source-present and normalized-destination-present database states.

**Risks**
- A standalone compatibility layer alone does not guarantee it is called transactionally during installation.
- If it becomes a second store, duplicate authority and divergent state are possible.
- It cannot recover information no longer present in either source envelope or destination.

**Decision:** USE AS AN INTERNAL COMPONENT OF OPTION B, not as an independent persistence system.

## Recommended target architecture
A future authorized forward migration should call a pure/isolated legacy decoder and a single SQL writer inside the owning schema transaction:
1. Inspect source-key presence with `containsKey`; distinguish absent, explicit NULL, and populated maps.
2. Inspect destination rows by Task ID + scheduled timestamp. If source keys are absent and rows exist, validate ownership, deterministic ID, uniqueness, status, ordinal and checklist relations as previously migrated; do not compare with empty maps.
3. If both source keys and destination rows are absent, record a validated no-history outcome only if the migration's defined scope requires a per-Task receipt.
4. If source exists, preserve the exact original state map, including explicit NULL and nested unknown fields, in an opaque JSON representation or equivalent key-presence payload.
5. Transfer known columns without discarding the opaque remainder. Avoid `INSERT OR IGNORE` for occurrence conflicts; fail closed on identity/content conflict.
6. Compare full logical snapshots, including presence metadata and unknown payload.
7. Write a versioned receipt only after parity, in the same transaction as rows and payload.
8. Retire legacy source keys only after durable destination and receipt parity; retaining the source until a separately accepted retirement gate is safer for rollback.

## Rollback model
- Transaction rollback must revert occurrence rows, checklist rows, metadata/payload and receipt together.
- A forward migration should avoid destructive source retirement in its first accepted phase.
- Backup/restore tests must compare complete logical snapshots, including receipt and opaque payload.
- If an explicit reverse migration is required, it must restore the legacy envelope byte/logically exactly from the preserved opaque payload. No reverse procedure is proven by this trace.

## Existing V19 database compatibility matrix

| Existing state | Required future behavior |
|---|---|
| Legacy keys present; no destination rows | Transfer, parity-check, receipt |
| Legacy keys present; destination rows already match | Validate parity; attach receipt without duplicates |
| Legacy keys absent; valid destination rows exist | Validate as already migrated; record receipt if appropriate |
| Legacy keys absent; no destination rows | Valid no-history only if source evidence supports it; otherwise classify as ambiguous, not silently empty |
| Legacy keys present; conflicting destination rows | Fail closed; preserve source and report conflict |
| Explicit NULL / unknown fields still in legacy envelope | Preserve in opaque payload and key-presence representation |
| Explicit NULL / unknown fields absent from both source and destination | Irrecoverable from available database state; do not fabricate |

**No code changes, migration execution, merge, release, deployment or V20 work is authorized.**
