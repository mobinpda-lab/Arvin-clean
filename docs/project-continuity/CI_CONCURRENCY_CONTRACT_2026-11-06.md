# CI Concurrency Contract Alignment — 2026-11-06

- Base commit: `59a321d333bd867049cf7f5b87be82ad9cb8e68e`
- Scope: test contract only; no application runtime changes.

## Failure cause

The CI contract test expected Device Smoke concurrency values `cancel-in-progress: true` and `max-parallel: 2`. The actual workflow intentionally serializes emulator jobs and does not cancel an active emulator run: `cancel-in-progress: false`, `max-parallel: 1`. This mismatch caused the contract test to fail.

## Correction

Only the two Device Smoke expectations in `test/ci_concurrency_contract_test.dart` were aligned with the existing workflow policy. No other assertion was removed, skipped, weakened, or bypassed.

## Policy preservation

`.github/workflows/device-smoke.yml` was not modified. Its serial execution and no-cancellation policy remain unchanged. No application source, feature, data contract, or test coverage was removed.

## Governance

PR #3052 remains OPEN / DRAFT / UNMERGED. The `main` branch must remain unchanged. Release status remains **BLOCKED — RELEASE: NO-GO** pending exact-SHA CI, Device Smoke evidence, and production APK gates.
