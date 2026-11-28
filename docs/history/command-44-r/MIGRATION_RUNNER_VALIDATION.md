# MIGRATION RUNNER VALIDATION — COMMAND 44-R

**Status:** WORKFLOW COMMITTED / ACTIONS EXECUTION NOT YET VERIFIED

## Runner

Workflow: `.github/workflows/arvin-historical-migration.yml`  
Workflow commit: `bfa7b46b3a2c4ed27657024217d3a0b329a73517`  
Execution branch: `recovery-02/main-based-integration`  
PR #3495 head at verification: `bfa7b46b3a2c4ed27657024217d3a0b329a73517`  
Reference fixture source: `f211326e7615f1c907494232dd3aec8d4732c83c`  
Fixture archive: `test/fixtures/database/historical/main_v7_fixture.sqlite.gz`  
Expected uncompressed SHA-256: `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`

## Checks performed by the runner

1. Checkout exact historical v19 and v20 source revisions in separate matrix lanes.
2. Record Flutter version, bundled Dart version and Flutter Doctor output.
3. Resolve each historical dependency graph using the committed lockfile only.
4. Extract the committed v7 gzip fixture to a disposable runner-local file.
5. Verify the uncompressed fixture SHA-256 before opening it.
6. Open the file with Drift NativeDatabase and a read-only v7 fixture user; do not pass the v19/v20 schema user to the executor.
7. Verify the 12-table v7 inventory, stable baseline Task IDs, SQLite integrity and FK state.
8. Generate complete table/row snapshots and record SQLite runtime version and PRAGMA user_version.
9. Upload logs, versions and snapshots as a GitHub Actions artifact, including on failure.

## No migration in this phase

The generated smoke test imports the exact historical `G1DriftSchema` to prove source compilation and checks the declared installer version. It does not invoke `G1DriftSchema.install`, `ensureOpen(G1DriftSchema())`, or the v20 hierarchy migration. v20 is not run against v7.

## Trigger limitation

The workflow includes `workflow_dispatch` as requested and a branch-scoped push trigger so the bootstrap can be exercised without modifying protected Main. GitHub requires a `workflow_dispatch` workflow file to exist on the default branch before it can be manually dispatched from the Actions UI/API. Main is intentionally unchanged and PR #3495 is not merged; therefore manual dispatch availability is not claimed. The branch push trigger is the safe immediate execution path.

## Current validation

- Workflow file committed: PASS — blob `1e7fae8184cc71d4102b064537b858330db5eb1f`.
- Workflow commit: `bfa7b46b3a2c4ed27657024217d3a0b329a73517`.
- GitHub Actions runtime run and artifact: NOT VERIFIED by the available run-read result.
- Flutter Doctor / Dart version: PENDING.
- Dependency resolution: PENDING.
- Fixture SHA verification and file open: PENDING.
- Snapshot artifact: PENDING.

No runtime PASS is claimed before the Actions run and artifact are inspected.
