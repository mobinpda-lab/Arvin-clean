# HISTORICAL RUNTIME REPORT — COMMAND 44-R

**Status:** BOOTSTRAP DEFINED / RUNTIME EXECUTION PENDING  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Canonical branch:** `recovery-02/main-based-integration`  
**Reference checkpoint:** `f211326e7615f1c907494232dd3aec8d4732c83c`  
**PR:** #3495 — OPEN / DRAFT / UNMERGED  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` — protected, unchanged

## Historical source anchors

- Main v7 source: `45e4202b03a434459e4c021a04efa7e8396359db`; schema blob `cd065ff25c680ed064e89068b3d063e737091025`.
- PR #3384 v19 source head: `310c0e20e3447c488c1e1c102c38bea5040708ca`; `G1DriftSchema` blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`; declared schema version 19.
- PR #3463 v20 source head: `812082964c649be7660c41213209ec34aea7167b`; `G1DriftSchema` blob `b03b90efac9f3c5cbef3b1b649385cdf6369ca62`; declared schema version 20.
- v20 hierarchy migration source: `lib/services/g1_many_to_many_hierarchy_migration.dart`; it explicitly accepts source schema version 19 only.

## Fixture provenance

The physical fixture is already tracked at `test/fixtures/database/historical/main_v7_fixture.sqlite.gz` on the reference checkpoint. The uncompressed SHA-256 is `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`; uncompressed size is 106,496 bytes. The baseline snapshot records 12 v7 tables and deterministic Task, Project, Follow-up, Person and Tag identifiers.

## Runtime decision

The historical PR #3384 build workflow itself declares Flutter `3.47.0`. The runner therefore uses that repository-evidenced Flutter release, not a guessed SDK. Dart is supplied by that Flutter SDK; the runner records the actual bundled Dart version and full Flutter Doctor output. No separate Dart version pin was found in the inspected historical project configuration.

The runner checks out the exact v19 and v20 source commits independently, resolves each historical lockfile with `flutter pub get --enforce-lockfile`, and opens a disposable extracted copy of the exact v7 fixture using Drift's NativeDatabase. The smoke test imports the historical `G1DriftSchema` and verifies its declared version, but deliberately does not call either installer. It generates a complete read-only table/row snapshot, SQLite runtime version, PRAGMA user_version, integrity result and FK result.

## Explicit boundary

This command does not run v19 or v20 migration code, alter schema, or change historical source. It only proves SDK/dependency bootstrapping, source compilation and safe physical-fixture opening. COMMAND 43-R remains the separate migration execution gate.

## Execution state

The workflow is registered in this branch. Runtime success, dependency resolution, generated snapshots and a completed Actions run remain PENDING until GitHub Actions executes the workflow on this exact branch revision. No successful run is claimed by this report.
