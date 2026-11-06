# Arvin Parallel Evidence Checkpoint — 2026-11-06

- Evidence target SHA: `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b`
- Authorized branch: `fix/recovery-calendar-device-smoke-2026-10-31`
- PR #3052: OPEN / DRAFT / UNMERGED; observed base SHA for main: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Release: **BLOCKED — RELEASE: NO-GO**.
- Evidence is tied to each exact workflow SHA; no PASS is inferred from a pending job or historical SHA.

## Commit audit

Commit `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b` changed exactly three files: `test/ci_concurrency_contract_test.dart`, `CHANGELOG.md`, and `docs/project-continuity/CI_CONCURRENCY_CONTRACT_2026-11-06.md`. The test diff changes only the two Device Smoke expected values to `cancel-in-progress: false` and `max-parallel: 1`. No assertion/test was removed, skipped, weakened, or bypassed. `.github/workflows/device-smoke.yml` was not changed; its blob SHA is `030aa62801e8885994b997975bfbfc1a4e910dab`.

## Exact-SHA CI — target `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b`

| Workflow / Run | Observed result |
|---|---|
| ARVIN Production Loop / `42209856056` | SUCCESS |
| ARVIN Orchestrator / `42209855911` | SUCCESS |
| Orchestrator PR Wakeup / `42209855944` | SUCCESS |
| Parallel Wave / `42209855856` | SUCCESS |
| G1 lock sync / `42209855749` | SUCCESS |
| Follow-up File Persistence / `42209856031` | SUCCESS |
| Calendar Provider Acceptance / `42209855984` | IN PROGRESS |
| Arvin Build / `42209855954` | IN PROGRESS |
| Device Smoke / `42209855748` | PENDING; no jobs/artifacts at checkpoint |
| Draft Review APK / `42209856090` | SUCCESS |

Build `42209855954`: Analyze SUCCESS; test shards 0–5 SUCCESS; standalone visual job SUCCESS. APK Debug and Staging jobs remain IN PROGRESS. APK Release job completed SUCCESS and produced artifact `13498617943` (artifact digest `sha256:b78d24c1a6a841a452a95c32e13ee455b9c4108687f592244296203ad34ae021`). Extracted Release APK SHA-256: `34c7c7a0d326c63ecee5852c99595466c3b7a302a8a088a41f2a9a76247acad6`. Independent signature/production-key verification was not completed; this is not release acceptance.

## Review APK — exact target SHA

Draft Review APK run `42209856090` completed SUCCESS. Artifact `13498418932`; GitHub artifact digest `sha256:68c61ecfd1cb25eb23fba697dbe5ffb0213b3150a4e7c36758f4e9f814c1da2a`.

Inspected manifest and signature log:
- APK SHA-256: `a4040ef1939b42c82b7565484f32108727faa89f107636fd4a9832c7e4132fc5`
- APK size: 78,956,462 bytes
- Application ID: `com.example.arvin.staging`; Android debuggable: `false`
- Signature Scheme v2 and v3: verified
- Vazirmatn Regular, Medium and Bold assets: present
- Signing key: ephemeral review-only test key; `publishable=false`; `release_created=false`

Valid review/install-test evidence only, not a production-signed release APK.

## Device Smoke — strict SHA separation

Old run `42205465399` belongs to SHA `59a321d333bd867049cf7f5b87be82ad9cb8e68e`, not the target SHA:
- Boot SUCCESS; artifact `13498760412`, digest `sha256:1a936cd5f0ab8b53846d580294161f0beda3472f93bd4bfa59fca24c29f04b92`.
- Navigation SUCCESS; artifact `13497798480`, digest `sha256:62596a34da7323e82a879d4e331337b8d11bba4da56ff0fdb86fcb36abe1c929`.
- Calendar IN PROGRESS.
- Reminder/Vazirmatn, Quick Capture, Follow-up Persistence and Task Lifecycle QUEUED.
- No Quick Capture or Calendar acceptance artifact available at checkpoint.

New run `42209855748` is associated with target SHA `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b`; it was PENDING with no jobs or artifacts. No Device Smoke lane on the target SHA is accepted yet.

## Open gates

Continue polling Build `42209855954`, Calendar Provider `42209855984`, new Device Smoke `42209855748`, and old Device Smoke `42205465399` separately. Record each completed run's SHA, lane conclusions, artifact IDs and digests. Independently audit Release APK signing/provenance and inspect Debug/Staging artifacts when available. Keep PR #3052 OPEN / DRAFT / UNMERGED; do not merge or edit `main`. Release remains **BLOCKED — RELEASE: NO-GO**.

## Documentation synchronization

This checkpoint, its changelog entry, and the appended product-ledger section are documentation-only updates. Their resulting commit SHA is a new branch head. The workflow results above remain evidence for `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b` only; fresh exact-head workflows are required for the resulting documentation HEAD.


## Live parallel checkpoint — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Audited code SHA:** `e81862cbcd723dd0740411de0526aac5e1771e36`  
**PR #3052:** OPEN / DRAFT / UNMERGED. **main:** `45e4202b03a434459e4c021a04efa7e8396359db`. **Release:** BLOCKED — RELEASE: NO-GO.

### Exact-SHA workflow evidence
- Build `42212225056`: IN_PROGRESS. Analyze job `127874147349` PASS (log: `No issues found!`); Visual job `127874146662` SUCCESS; test shards 4 and 5 SUCCESS; shards 0–3 IN_PROGRESS; Debug, Staging and Release APK jobs IN_PROGRESS. No artifact listed at this checkpoint.
- Device Smoke `42212224923`: PENDING; no jobs and no artifacts exposed. No device lane is accepted.
- Follow-up File Persistence `42212224806`: SUCCESS; job `127873397879`; log reports one test passed and records SQLite executor close plus temporary-directory cleanup. This is focused file-backed persistence evidence, not full Device Smoke acceptance.
- Calendar Provider `42212224989`: IN_PROGRESS; job `127873398173`; log endpoint returned BlobNotFound while active, so detailed stage evidence is unavailable. No artifact.
- Draft Review APK `42212224924`: IN_PROGRESS; job `127873400021`; log endpoint returned BlobNotFound while active. No artifact.
- Production Loop `42212224920`, G1 lock sync `42212225294`, Orchestrator `42212224894`, Parallel Wave `42212225472`, and PR Wakeup `42212224907`: workflow-level SUCCESS; these do not replace product acceptance gates.
- Combined commit status endpoint returned no individual status entries at audit time.

### Previous-head runs — SHA `2c2594e4663b243932620e250b4586e564996461`
- Build `42210948715`: workflow conclusion CANCELLED, although the returned job list showed the visible Analyze, six shard and APK jobs completed SUCCESS. Treat the overall run as CANCELLED / not an accepted completed Build gate; do not promote child results into a workflow PASS.
- Device Smoke `42210947981`: CANCELLED; no jobs or artifacts returned. No device acceptance.
- No previous-head result is carried forward as evidence for `e81862c`.

### Branding diff audit
- Commit `e81862cbcd723dd0740411de0526aac5e1771e36` changes exactly one file: `assets/images/branding/tafweez.svg`.
- Parent blob `98203032b9c3ea9a257ed15a7763828bf66ac877`; new blob `dd5db5b401eceef981b417dd7f781d9994ac4e10`.
- The only diff removes the SVG `title` element. Removing that line from the parent content yields byte-for-byte equality with the new content; path geometry is unchanged.
- New SVG contains one `path`, no other drawable/metadata elements, no background element, and one fill value `#1A2B4C`; root viewBox remains `0 0 1792 1024`. Source-level Path-Only/vector contract is satisfied. Runtime rendering and accessibility acceptance still require exact-head CI/device evidence.

### Issue triage
- #823 OPEN: release-scope freeze remains binding; no feature or UX expansion authorized by this audit.
- #2102 OPEN: main remains at the PR base SHA; exact-main release evidence and physical-device/data-integrity gates remain open. No main change made.
- #2299 OPEN: remaining-work ledger remains the tracking authority; this checkpoint records evidence without closing product gates.

This checkpoint is documentation-only. All run results above belong only to the exact SHA stated for each run. The documentation commits require their own exact-head validation. No workflow, test, product feature, main branch, merge, or release configuration was changed.
