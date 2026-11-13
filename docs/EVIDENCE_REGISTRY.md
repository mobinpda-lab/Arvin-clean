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


---

## COMMAND 07-A.2.80 — continuous development checkpoint

**Reconciled:** 2026-11-14 (Iran time, UTC+03:30)  
**Starting SHA:** `77cd2102615126044dfcfe85182f437ad188ed03`  
**Pre-registry current HEAD:** `9c4d775cbff18305d2335c5ad8963e4658ac11ed`  
**PR #3384:** OPEN / DRAFT / UNMERGED  
**PR base:** `fix/wave3-cycle3-calendar-product-repair` @ `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` — unchanged.

### Branch and commit ledger

The following commits were added after the starting SHA on the existing execution branch; no parallel branch or PR was created:

| Commit | Scope | Product source changed? | Exact-SHA validation |
|---|---|---:|---|
| `bd717570cba214f9d77150810d21deb82969b5e1` | Person persistence test scrolls lazy Task Details row into view | No | Pending on later HEAD |
| `e95672dfbd240406b0c9c373a63f77ab15050880` | Home category filter test uses stable option key | No | Pending on later HEAD |
| `bb55c3434949e52da3a7008cccc2f636fad9fb08` | Checklist CRUD test explicitly exits inline edit mode before delete | No | Pending on later HEAD |
| `df384ba5acbed3b3e4ae125a65706c5ff2fe5e5e` | Home tests scroll lazy task groups before visibility assertions | No | Pending on later HEAD |
| `82fefc0796de07d1b9b5583ef2e88d4953ee0990` | Adds persisted Task status selector to Task Details summary card | **Yes** | Pending on later HEAD |
| `208e1d498be05c7d09844ddcde2df43356ffb073` | Initializes canonical stores in Home injected-Iran-clock contract test | No | Pending on later HEAD |
| `486bbbbf3339eab8e4bbb8087eb1c4d67778722c` | Adds dependency-safe Center deletion to Center Management UI | **Yes** | Pending on later HEAD |
| `61eb0ce498d3cd0027586868972973bec440a52a` | Adds Center Management deletion UI tests | No | Pending on later HEAD |
| `9c4d775cbff18305d2335c5ad8963e4658ac11ed` | Corrects Center dependency-block feedback assertion | No | Pending on later HEAD |

Concurrent Notebook audit commits `52a88ee9c49c522e6cc3e88b1685e63aca451f26` and `6fc3392a33bd5c2a7e436301117a97a2f8852d7c` were detected on the same branch and preserved. The audit is source-level only and does not claim Notebook implementation acceptance.

### Historical regression baseline

- Run `43504251431` remains the historical 47-failure reference on SHA `2a4ec37b33136fdf697b73fc275ef8b36792e6f5`.
- This historical count is not re-labelled as the remaining failure count for later candidates.

### Full Build evidence

Run `43511675412` on exact SHA `77cd2102615126044dfcfe85182f437ad188ed03` completed **FAILURE**.

| Job | Job ID | Result |
|---|---:|---|
| quality test-0 | 132194093978 | FAILURE |
| quality test-1 | 132194093894 | SUCCESS |
| quality test-2 | 132194094087 | FAILURE |
| quality test-3 | 132194093848 | FAILURE |
| quality test-4 | 132194093905 | FAILURE |
| quality test-5 | 132194094097 | FAILURE |
| Analyze | 132194094044 | SUCCESS |
| Visual / PDF | 132194093993 | SUCCESS |
| APK Debug | 132194093980 | SUCCESS |
| APK Staging | 132194093881 | SUCCESS |
| APK Release | 132194093547 | SUCCESS |

The three earlier test-contract corrections (`0777a9fc`, `f91add6d`, `77cd2102`) had their relevant contract tests observed passing in this run. This confirms only those individual test contracts on SHA `77cd...`; it does not validate later commits or the product as a whole.

### File-backed SQLite and hierarchy evidence

| Workstream | Run / Job | Exact SHA | Result | Artifact / SHA256 |
|---|---|---|---|---|
| SQLite A-D snapshots, five reopen cycles | Run 43529638618 / Job 132243844263 | `df384ba5acbed3b3e4ae125a65706c5ff2fe5e5e` | SUCCESS; A-D snapshots match for Task compatibility metadata, Reminder rows, Follow-up rows/order, Person links/identities, schema catalog, columns and FK integrity | Artifact 14085714865; snapshot JSON SHA256 `40eb3efbfb3a4d0b48a4f1a9409e328d137756b970dfb1780b0b37fd73c5e85c` |
| G1 optional Task links / database integrity | Run 43529638674 / Job 132243844261 | `df384ba5acbed3b3e4ae125a65706c5ff2fe5e5e` | SUCCESS; 19 diagnostic tests and 13 hierarchy schema tests passed; includes clear-all/NULL reopen and five schema reopen cycles | Artifact 14086812313; ZIP SHA256 `e5a2915c7a670d3c5b68d576bf5b29dd05db1ab53ca823d472f61f6e7158f28e` |
| Follow-up file-backed persistence | Run 43529638840 / Job 132243946709 | `df384ba5acbed3b3e4ae125a65706c5ff2fe5e5e` | SUCCESS; file-backed reopen scenario passed | No standalone artifact produced |

These are bounded diagnostics, not proof of D01-D05 acceptance. D05 atomicity/rollback/recovery remains NOT VERIFIED. No user database was migrated.

### Vazirmatn / PDF / APK evidence

On SHA `77cd2102615126044dfcfe85182f437ad188ed03`:

- Vazirmatn Light, Regular, Medium, SemiBold and Bold source font SHA256 values matched their embedded APK font contents.
- Persian PDF test reported font embedding, Unicode extraction and PDF rendering PASS.
- PDF file SHA256: `073d3f036aafb4b056ec5b09406cd9a17ea3ce2a166d13333ccf7689d6532351`.
- PDF artifact ID `14081645674`; ZIP SHA256 `0e07ac2df5504ceeda6b45a6768b6a6e41461d7f1471e039aaf9ddfa0e9d45d0`.
- Staging APK file SHA256: `5491b4b307f8b4a36c0d4f68d7c7a162c380c1918632cebd17358137cdf69f52`.
- Release APK ZIP artifact `14080552748`; ZIP SHA256 `6d6f8f778011ed4a65d6b3ffb48c5daebc20a1d1f92cc46829cac18256d5615b`.
- Debug APK ZIP artifact `14080004907`; ZIP SHA256 `11e8613b3530dca9cddb1a8dded55bd3ec45849e4aa0f3bac67d3a48994c358e`.
- Staging APK ZIP artifact `14079884715`; ZIP SHA256 `5f2de9412d2ddf11abf506c422d916e1fbb29d9c29c3ef1cbb22b1b1d5da811b`.
- Staging verification ZIP artifact `14080204475`; ZIP SHA256 `efa819f222373e26ce07f18b1a7c9f3821e4e3aa19e26d734795cfbbb1eed0bf`.
- Release and Debug APK file-level SHA256 were not independently recorded. Staging signer certificate SHA256 output was `NOT_AVAILABLE`; no signer value is inferred.

These artifacts are tied only to SHA `77cd...`, not the current branch head.

### Current candidate workflow status

Current pre-registry HEAD `9c4d775cbff18305d2335c5ad8963e4658ac11ed` has fresh runs:

| Workflow | Run ID | Status at reconciliation |
|---|---:|---|
| Full Build | 43530142322 | PENDING; no jobs started |
| Device Smoke | 43530142162 | QUEUED |
| SQLite A-D Snapshot | 43530142199 | QUEUED |
| G1 Hierarchy | 43530142157 | QUEUED |
| Follow-up Persistence | 43530142224 | IN_PROGRESS |
| Orchestrator | 43530142214 | QUEUED |
| Production Loop | 43530142153 | QUEUED |

No PASS is attributed to SHA `9c4d...` yet. The registry update itself advances the branch; the registry commit SHA and its exact-SHA CI remain pending.

### Product recovery and remaining scope

- Task Details: a status selector now exists in the summary card and uses the existing completion callback or canonical Task update path. Exact-SHA behavior is pending.
- Center Management: create, rename, archive/restore and dependency-safe delete are available through the existing CenterStore. UI deletion tests are pending exact-SHA execution.
- Home: several test harness defects involving lazy list construction and ambiguous text finders were corrected. Home filter behavior, RTL ordering, boolean semantics, Iran clock and calendar grouping remain subject to exact-SHA behavioral tests.
- Person/Follow-up: persistence diagnostic passed on `df384...`; full Person UI lifecycle, atomicity and identity behavior remain partially verified.
- Calendar, Task Details Auto-Save/Checklist, Templates Deep Clone, Cross-Center Reporting, unified five-entity management and D01-D05 remain PARTIAL / NOT VERIFIED as applicable.
- Device Smoke has not passed on the current candidate.

### Security and governance

- Repository `allow_auto_merge=true`.
- Active ruleset `20952260` (`main-protection`) has required approving review count 0 and no required status-check rule.
- This remains a governance risk. No protection or Auto-Merge setting was changed.
- Main remained read-only. PR #3384 remains Draft. Merge, release and deployment are not authorized.

**Disposition:** PRODUCT ACCEPTANCE BLOCKED. RELEASE NO-GO. This registry records evidence and gaps; it does not authorize merge, release, deployment or production migration.
