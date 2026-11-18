# V20 / V21 Version Ownership Decision

**Status:** AUDIT RECOMMENDATION — PRODUCT OWNER DECISION REQUIRED

## Evidence
- Main is schema v7.
- PR #3384 proposes V19.
- PR #3463 proposes V20 from V19 and implements REV10 many-to-many hierarchy.
- V20 candidate migration source explicitly accepts only schema 19 and targets schema 20.
- The Occurrence repair identified in COMMAND 55-R has no independent version slot once #3463 owns V20.

## Options
| Option | Advantages | Risks / compatibility | Decision |
|---|---|---|---|
| Put Occurrence repair in V20 | One release train if fully coordinated | Conflicts with #3463 ownership; independent second version bump impossible; current V20 lifecycle already runs M2M; ordering with V19's destructive Occurrence handling is unresolved | Not recommended as a separate V20 migration |
| Add Occurrence repair in V21 | Clean additive version after M2M; no schema-number collision | Too late if V19 has already deleted legacy Occurrence keys; V19 retry/NULL/unknown defects must be bypassed or safely intercepted; V19 DB without receipt may be unrecoverable from SQL alone | Not safe as a standalone post-V20 patch |
| One coordinated migration route | Can classify V7, intermediate, V19 and V20 states; can protect Occurrence source before any destructive conversion; can include M2M exactly once and define one terminal schema version | Highest design/review cost; requires explicit predecessor fingerprints, source-preserving adapter, no duplicate M2M execution, and an approved policy for ambiguous already-V19 DBs | **RECOMMENDED** |

## Recommendation
Reserve V20 for the M2M hierarchy migration already present in #3463; do not add a competing V20 Occurrence migration.

Design one coordinated, versioned forward-upgrade route with a single terminal target after the M2M step (provisionally V21 only if the Product Owner confirms the V20 reservation). The coordinator must classify each database before any write and must protect / snapshot V7 Occurrence source before invoking any V19-era logic that removes those keys. It must not blindly execute the current V19 installer for a non-empty or ambiguous Occurrence source. The V20 M2M operation must execute once and its exact marker/relationship results must be verified.

For already-V19 databases:
- if Legacy Occurrence source and destination both exist, reconcile record-by-record;
- if a trusted source snapshot / occurrence receipt proves completion, verify it;
- if Legacy keys are absent and no trusted receipt/snapshot exists, stop and require backup/source recovery;
- never infer “empty history” from missing keys or SQL row presence alone.

This is a design recommendation, not approval to implement. It does not declare V21 a final approved number. The Product Owner must approve the target number and the coordinated route before Phase A.
