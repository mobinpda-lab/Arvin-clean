# ASF Operational Checkpoint — 2026-09-02

The autonomous factory remains governed by ASF-MOC v9.0.

Operational contract:
- no direct writes to `main`
- issue-scoped worker execution
- current-main validation before promotion
- bounded self-fix (maximum 3 attempts)
- exact-head CI/security/build evidence
- Production Orchestrator is the merge authority
- fail closed when required credentials or evidence are unavailable
- after successful promotion, immediately continue with the next queued task

This checkpoint is evidence-oriented and does not claim Level 10 until an end-to-end autonomous production cycle is proven with real worker execution, promotion, post-merge validation, release, monitoring and recovery evidence.
