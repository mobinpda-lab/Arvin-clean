# Entity Relationships Specification
Approved contract: Center↔Project M2M; Project↔Category M2M; Task→Center/Project/Category each independently optional 0..1; Task↔Tag M2M. Person/activity contracts follow their owner-approved ADRs and ledger.
Join tables require composite uniqueness, FKs, bidirectional indexes and transactional writes. Removing an edge must not delete endpoints or unrelated edges. Task may be standalone. Never infer Project↔Category edges from names, labels, ordering or Task text. Preserve relation parity across migration, archive/restore, reports and backup. ProjectExecution versus direct Task assignment requires explicit reconciliation before ownership semantics change.
Acceptance: M2M cardinality, idempotency, invalid-FK rejection, rollback, reopen and A→B parity.
