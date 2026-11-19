# Arvin — CI, Device Smoke and Staging APK checkpoint
Date: 2026-11-07
Repository: `mobinpda-lab/Arvin-clean`
Authorized branch: `fix/recovery-calendar-device-smoke-2026-10-31`
Source SHA: `abecec1ec895e6c7df83913247c1cc9ecc083d02`

## Source and test result
Commit `abecec1ec895e6c7df83913247c1cc9ecc083d02` fixes the tag roll-box test finder by locating the concrete `HomeFilterPill` and asserting the visible label; multi-select/apply/cancel assertions remain active.
Build run: `42370095017` — SUCCESS.
Analyze: SUCCESS. Visual: SUCCESS.
Six shard totals from job logs:

| Shard | Passed | Result |
|---:|---:|---|
| 0 | 224 | SUCCESS |
| 1 | 185 | SUCCESS |
| 2 | 308 | SUCCESS |
| 3 | 145 | SUCCESS |
| 4 | 236 | SUCCESS |
| 5 | 173 | SUCCESS |
| Total | 1,271 / 1,271 | ALL SHARDS PASSED: YES |

Shard 4's `issue 1891 tag roll box supports multi-select with apply/cancel` passed.

## Staging APK identity
Staging review run: `42370095057`; artifact ID: `13573433210`.
APK file: `Arvin-review-staging-abecec1ec895e6c7df83913247c1cc9ecc083d02.apk`
SHA-256 (computed on the extracted APK file): `6e259567386481fa14621bd35d133a4d7f1959bb9ff6a0820ac4a994c583cbc2`
Size: 79,120,215 bytes; 75.455 MiB; 79.120 MB decimal.
Package: `com.example.arvin.staging`; debuggable: false; APK signature V2 and V3 verification: PASS.
Signing is ephemeral and review-only; publishable=false. Not a release APK.

## Device Smoke status and diagnosis
Run `42370095088` targets source SHA `abecec1ec895e6c7df83913247c1cc9ecc083d02`, status PENDING, zero jobs returned.
Workflow supports PR triggers and `workflow_dispatch` with required `target_sha`. Jobs use GitHub-hosted `ubuntu-latest`; Android API 35 emulator is provisioned inside each job by the emulator-runner action. Current evidence does not support a claim that a dedicated self-hosted emulator runner is awaited. Since no jobs have been created, the exact queue/scheduler/approval/concurrency cause remains UNKNOWN.
No manual dispatch or rerun was performed. Available GitHub actions permit rerunning failed jobs or an individual existing job; there are no jobs in this run to rerun. A workflow-level `workflow_dispatch` targeting this exact SHA requires an Actions dispatch capability not exposed by the current connector.

## Governance
PR #3052: OPEN / DRAFT / UNMERGED.
main SHA: `45e4202b03a434459e4c021a04efa7e8396359db`; unchanged from PR base.
No merge, release or publication.
Release gate: **BLOCKED — RELEASE: NO-GO** until Device Smoke and all other required acceptance gates are successful on one exact candidate SHA.
