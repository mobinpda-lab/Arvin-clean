# COMMAND 55-R Architecture Review

**Review basis:** COMMAND 55-R documents at branch `investigation/command-55-r-safe-forward-migration-design`, head `e55403ae00dca4ba37f040d6de60a174191904b8`.  
**Reviewed source:** V19 commit `310c0e20e3447c488c1e1c102c38bea5040708ca`; V20 candidate `812082964c649be7660c41213209ec34aea7167b`.

## Review results
| Area | Review |
|---|---|
| Idempotency | Correctly identifies V19 second-run false mismatch. Still requires a receipt/fingerprint contract and proof that source retirement never precedes complete readback. |
| Explicit NULL | Correctly distinguishes absent / explicit null / concrete value. V19 codec does not preserve all occurrence nullable key presence. |
| Unknown fields | Correctly requires opaque preservation. V19 Occurrence SQL schema has no dedicated unknown-field payload representation. |
| IDs and relations | Identity and FK preservation requirements are sound; require exact snapshot comparisons for all dependent tables. |
| Migration receipt | Necessary. V19 historical installer does not supply an Occurrence-specific receipt, so V19 target rows alone are insufficient proof. |
| Transaction / rollback | Required, but real failure injection and post-commit/pre-version registration need separate verification. |
| Backup / restore | Design is appropriate; no production backup is to be used. Restore must be tested on an independent copy. |
| Older users | COMMAND 55 initially assumed a V19 base too broadly; current Main is V7 and actual installed population is unknown. |

## Newly identified version collision
COMMAND 55 proposed a V20 repair substep, but PR #3463 already changes schema to V20 for the M2M hierarchy. A second independent V20 schema migration is not valid. A coordinated migration train is required.

## Additional V20 candidate concern
The M2M candidate source uses `INSERT OR IGNORE` for copying Center↔Project edges and recording migration exceptions. This conflicts with COMMAND 55's no-silent-ignore rule unless each ignored conflict is explicitly classified, compared and proven identical. The candidate must not be treated as fully accepted based only on its focused workflow.

## Critical sequencing concern
A standalone V21 Occurrence repair may be too late: V19 can remove the source Occurrence keys before V21 runs. The repair route must preserve/capture source data before the V19 destructive boundary, or stop on V19 databases that lack a trusted receipt/snapshot. A missing source key is not evidence of an empty history.

## Disposition
COMMAND 55-R remains DESIGN PARTIALLY ACCEPTED. Its core preservation principles remain valid, but its proposed version slot and assumed migration base must be superseded by this COMMAND 56-R audit. No implementation or migration is authorized.
