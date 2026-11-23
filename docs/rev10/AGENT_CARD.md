# REV10 Agent Card — mandatory
Read this card, [STATE](STATE.md), [Constitution](CONSTITUTION.md) and [permanent Requirement Ledger](../project-continuity/REV10-MASTER-REQUIREMENT-LEDGER.md) before execution.
1. SQLite is the source of truth.
2. Task organizational relationships are optional and independent.
3. Preserve historical data, IDs, explicit NULL and absent-field semantics.
4. No destructive action or production-data migration without owner approval.
5. Never weaken, remove or skip valid tests.
6. Never claim PASS without exact-SHA evidence.
7. Reuse existing canonical implementations; do not duplicate Stores, schedulers or backup formats.
8. Preserve Persian RTL and owner-approved typography/design decisions.
9. Meet measurable accessibility: TalkBack, contrast, 200% scaling, no clipping, touch targets and RTL focus order.
10. Main untouched; Merge/Release/Deployment unauthorized.
Execution loop: inspect live branch/PR → read source and decisions → isolate root cause → focused patch + regression → exact-SHA CI → update ledger/STATE. Keep IMPLEMENTED / TESTED / ACCEPTED separate.
