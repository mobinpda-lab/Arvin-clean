# P0 Remaining Risks — COMMAND 56-R

| ID | Risk | Evidence | Severity | Required closure |
|---|---|---|---|---|
| R56-01 | Actual installed schema population unknown | No Play Console / telemetry / device census | CRITICAL | Privacy-safe production inventory |
| R56-02 | V19 delivery cannot be proven or disproven externally | Only draft GitHub releases reviewed | CRITICAL | Store tracks + signed artifact provenance |
| R56-03 | V19 second-run parity mismatch | COMMAND 50-R acceptance; run 44368276255 | CRITICAL | Approved repair path and repeatability evidence |
| R56-04 | Explicit NULL / unknown Occurrence fields not faithfully represented | COMMAND 50-R physical negative cases | CRITICAL | Presence-aware schema and opaque payload with round-trip tests |
| R56-05 | V20 slot already owned by M2M migration | PR #3463, schema v20 | HIGH | Owner-approved coordinated version plan |
| R56-06 | V20 candidate contains INSERT OR IGNORE | Migration blob a2c768... | HIGH | Explicit conflict detection and exception ledger; no silent skip |
| R56-07 | V20 exact-head Build failed and Device Smoke cancelled | Runs 43629839831 / 43629839877 | HIGH | Green exact-head build and device evidence |
| R56-08 | V19 exact-head Build failed | Run 43575749904 | HIGH | Reproducible full CI on approved candidate |
| R56-09 | Main V7 SharedPreferences → SQL migration population is not measured | Main TaskStore and migration writer source | HIGH | Census of marker + source presence + SQL counts |
| R56-10 | Intermediate schema lineage may vary | No installed DB samples | HIGH | Fingerprint catalog and sequential adapters |
| R56-11 | Existing V19 SQL without source receipt may be unrecoverable for unknown/null data | Legacy keys deleted; no occurrence-specific receipt | CRITICAL | Trusted backup/source required; fail closed |
| R56-12 | PR #3495 integration lineage is separate from V19/V20 chain | PR metadata | MEDIUM | Explicit integration/merge-base decision |

## Global stop conditions
- Unknown schema fingerprint or migration marker conflict.
- Missing Legacy Occurrence keys without trusted receipt/snapshot.
- SQL/Legacy identity or payload mismatch.
- FK violations introduced by migration.
- Any unexpected data mutation in protected entities.
- Backup cannot be restored and compared.
- Build/test/device evidence is absent, stale or bound to a different SHA.

**No unresolved CRITICAL risk may be waived by changing `user_version`, ignoring rows, deleting source JSON or treating a warning as success.**
