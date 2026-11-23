# REV10 Constitution
Authority order: Product Owner decisions → this Constitution → permanent Requirement Ledger and ADRs → SPEC documents → implementation. Canonical delivery is PR #3495 / `recovery-02/main-based-integration`; Main is read-only.
## Non-negotiable principles
1. SQLite is the source of truth.
2. Task assignments to Center, Project and Category remain independently optional under the current approved contract.
3. Preserve historical IDs, records, relationships, extension data, explicit NULL and absent-key semantics.
4. No destructive operation, identifier migration, schema retirement or production-data experiment without explicit owner approval.
5. Never weaken, delete, skip or quarantine a valid regression test to obtain green CI.
6. PASS requires exact-SHA evidence for the named acceptance scope.
7. Reuse canonical Stores, repositories, services, schemas and schedulers; do not create duplicate implementations.
8. Preserve Persian RTL and currently owner-locked typography/color decisions in `docs/project-continuity/PRODUCT_DECISIONS.md`.
9. Accessibility must be measurable and tested, not merely visually asserted.
10. Merge, Release and Deployment remain unauthorized until explicit owner approval.
## Data and security
Center↔Project and Project↔Category are M2M; Task→Center/Project/Category are independently optional 0..1. Removing an edge never deletes endpoints. Archive is not delete. Backup/Restore preserves identity and relation parity and destination-only data. Never log secrets, passphrases, private Task content or sensitive database rows.
## Acceptance and supersession
Track IMPLEMENTED, TESTED and ACCEPTED separately. Queued, cancelled, stale, partial or unrelated green checks are not PASS. Preserve historical decisions/matrices; append dated amendments and explicit supersession links rather than rewriting history.
See [AGENT_CARD](AGENT_CARD.md), [STATE](STATE.md), [SPEC index](SPEC/README.md), [Dependency DAG](REV10-WAVE-DEPENDENCY-DAG.md), [Open Decisions](REV10-OPEN-DECISIONS.md).
