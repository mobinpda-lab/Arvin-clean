# ASF Control Plane Foundation

This directory defines the machine-readable contract for autonomous execution. GitHub Actions remains the execution fabric; the contract separates queue/state/worker identity from individual workflows.

## Rules
- `main` is never modified directly by workers.
- State transitions are evidence-driven and fail closed.
- A lease is required before execution.
- A worker is selected by capability and scope; duplicate active leases are forbidden.
- Self-fix is bounded to three attempts.
- Production Orchestrator is the only merge authority.
- L10 is not claimed until end-to-end autonomous completion evidence exists.

`FACTORY_MANIFEST.json` defines policy, `state.schema.json` defines persistent execution state, and `workers.json` defines the worker contract.
