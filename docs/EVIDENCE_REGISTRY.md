# Arvin — Single Evidence Registry

Last reconciled: 2026-11-13
Repository: `mobinpda-lab/Arvin-clean`
Execution branch: `feature/command-07-a-sqlite-contract-remediation`

## Rules

- A row is valid only for its exact Commit SHA.
- Run, Job, Artifact and file SHA256 are separate identifiers and must not be substituted for one another.
- A missing Artifact ID or SHA256 is recorded as `NOT PRODUCED`, never inferred.
- Historical evidence remains immutable; later candidates do not inherit PASS status.
- Acceptance status is independent of a successful individual job.

## Candidate snapshot — historical, not accepted

| Field | Value |
|---|---|
| Candidate SHA | `660f67eebce446cfae62932c8ce6729f2baf2ea4` |
| Run date | 2026-11-13 |
| Acceptance SHA | NOT ESTABLISHED |
| Product acceptance | BLOCKED |
| Release | NO-GO |

## Workflow evidence

| Workstream | Run ID | Job ID | Artifact ID | Artifact SHA256 | Test/result | Acceptance |
|---|---:|---:|---:|---|---|---|
| Quality / Analyze | 43469466686 | 132037403672 | NOT PRODUCED | NOT PRODUCED | SUCCESS | Evidence only |
| Visual / PDF | 43469466686 | 132037403025 | 14059886474 | `c5594c0bd4919548026aa66007d35b37ec259f1ff21bfbe0e453d3a53a8af0fe` | SUCCESS | Partial; visual artifact only |
| APK Release | 43469466686 | 132037403422 | 14061650950 | `5dd44c5d6c599578fed14d287edbe2a6fe60289af7401c37f724d4624230a3c2` | SUCCESS | Artifact only; Build failed |
| APK Debug | 43469466686 | 132037403484 | 14060307478 | `33897e19d47f0daf92b36cd8d5d842d098c6b62a0de8498ebc1f98ef48b217ca` | SUCCESS | Artifact only; Build failed |
| APK Staging | 43469466686 | 132037403590 | 14063256663 | `eae7ceca04bc376105b3ce13a39eba3ef0108c00a61813f49b193ab5edb31b88` | SUCCESS | Artifact only; Build failed |
| Staging verification | 43469466686 | 132037403590 | 14063146865 | `7a75f7ebc4ebaa916261d7a48504c08a29e40718cdc2f570fe3503f0fa9ac4f5` | SUCCESS | Verification artifact only |
| SQLite D01–D02 snapshot | 43469466854 | 132037232282 | 14059728659 | `4f4e713c9a78590995a53d6ac0fb529b720d4a2eaf543dab6599e62a9c0736fc` | SUCCESS; five file-backed reopen cycles | Partial; not full D01–D05 |
| G1 hierarchy / SQLite integrity | 43469466893 | 132037231822 | 14059463856 | `755f6857662e1f3deab72cfe7164ee04b61c6a63da479bfda4d329c13b19d035` | SUCCESS | Partial; limited G1 scope |
| Follow-up SQLite persistence | 43469466844 | 132037232764 | NOT PRODUCED | NOT PRODUCED | SUCCESS; file-backed persistence/reopen | Partial; no standalone artifact |
| Device Smoke | 43469466816 | 132037232780 | NOT PRODUCED | NOT PRODUCED | QUEUED | NOT VERIFIED |

## APK file SHA256

These are hashes of the APK files inside the downloaded Release/Debug ZIP artifacts, not the ZIP hashes above.

| File | Candidate SHA | Artifact ID | File size | APK SHA256 |
|---|---|---:|---:|---|
| `app-release.apk` | `660f67eebce446cfae62932c8ce6729f2baf2ea4` | 14061650950 | 78,788,330 bytes | `ce9af4cf8188d49eff7e89a2b1601b544d5089a45dd28a1667970638f7952b29` |
| `app-debug.apk` | `660f67eebce446cfae62932c8ce6729f2baf2ea4` | 14060307478 | 177,151,620 bytes | `1f9945a14135c6f1a6e2ba94e326ed936930405332d5dfb45505d21db04aa2d5` |
| Staging APK | `660f67eebce446cfae62932c8ce6729f2baf2ea4` | 14063256663 | NOT RECORDED | NOT INDEPENDENTLY VERIFIED |

## Full Build outcome

Run `43469466686` completed with `FAILURE` on `660f67eebce446cfae62932c8ce6729f2baf2ea4`.

| Job | Job ID | Result | Tests |
|---|---:|---|---:|
| quality test-0 | 132037403490 | FAILURE | 246 passed / 9 failed |
| quality test-1 | 132037403455 | SUCCESS | 212 passed / 0 failed |
| quality test-2 | 132037403682 | FAILURE | 323 passed / 16 failed |
| quality test-3 | 132037403814 | FAILURE | 163 passed / 7 failed |
| quality test-4 | 132037403852 | FAILURE | 254 passed / 9 failed |
| quality test-5 | 132037403691 | FAILURE | 194 passed / 10 failed |

Total across six shards: **1,392 passed / 51 failed**. The 51 failures remain open regression cases; see the exact job logs attached to the Run above. No assertions are waived by this registry.

## SHA-boundary

The Build and Device Smoke evidence above belongs only to `660f67eebce446cfae62932c8ce6729f2baf2ea4`. Any subsequent commit is a new candidate and must obtain its own evidence. This file does not authorize merge, release, deployment, production migration, or any Main modification.
