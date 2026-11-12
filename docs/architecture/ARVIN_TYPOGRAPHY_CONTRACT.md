# ARVIN TYPOGRAPHY CONTRACT

**Status:** CANONICAL  
**Authority:** PRODUCT OWNER  
**Decision:** APPROVED  
**Product Owner:** Mobin  
**Change Policy:** OWNER CONTROLLED  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Canonical path:** `docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md`

## 1. Binding product decision

Vazirmatn is the sole official and default application font of Arvin. This decision is explicitly approved by Product Owner Mobin in COMMAND 07-A.2.24.

VazirHarf is not an official, default, or fallback brand font. Existing VazirHarf assets, registrations, references, tests, PDF loaders, and historical documentation must be inventoried and classified. They must not be silently treated as the active product contract.

The only user-selectable choices are:

1. **Vazirmatn — Official Default**
2. **System Default — Optional User Preference**

System Default is an accessibility/user preference, not an alternative Arvin brand font. No third font option is permitted without written Product Owner approval.

Any change to the official font family, approved weights, or this contract requires Mobin's explicit written approval. A code change, review, CI pass, or documentation edit by itself cannot amend the product decision.

## 2. Approval and precedence

This contract records the latest explicit Product Owner decision and supersedes conflicting earlier font decisions, including historical VazirHarf decisions in project continuity records. Historical entries remain preserved as history; they must be marked superseded rather than deleted.

Operational evidence is SHA-specific. The repository's live code, workflows, artifacts, and GitHub settings determine implementation status; this contract determines the approved product direction.

## 3. Source and licensing

The checked-in Vazirmatn license identifies The Vazirmatn Project Authors and the upstream project at https://github.com/rastikerdar/vazirmatn. The checked-in license is SIL Open Font License 1.1 and permits embedding and redistribution subject to its terms. The complete license must remain bundled with the font assets.

The upstream source commit is pinned as `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7`; all five font Git blob identities and the bundled OFL license match that source tree byte-for-byte as recorded in §18. Do not infer a release version from filenames.

## 4. Asset inventory and integrity

### Inventory at main HEAD `45e4202b03a434459e4c021a04efa7e8396359db`

| Weight | File | Present | Git blob SHA |
|---|---|---:|---|
| 400 Regular | `Vazirmatn-Regular.ttf` | Yes | `64e4a8189557a17b63fd7a77794207483e592972` |
| 500 Medium | `Vazirmatn-Medium.ttf` | Yes | `1e08dd54d90a4879451ef0f80fe0d8068fb7462f` |
| 700 Bold | `Vazirmatn-Bold.ttf` | Yes | `efa9b095da01d299310bdcae293e24e657fe6da9` |
| 300 Light | `Vazirmatn-Light.ttf` | No | Pending |
| 600 SemiBold | `Vazirmatn-SemiBold.ttf` | No | Pending |
| License | `LICENSE.txt` | Yes | `be66b3824e9772e75141e631695c5256f105fb57` |

Git blob identities above are not SHA-256 file checksums. SHA-256 values for each font and license remain **NOT YET VERIFIED** and must be recorded from downloaded binary bytes in the implementation validation.

A later unmerged development tree contains five Vazirmatn weight files, but their presence on an unmerged branch is not proof that the main branch or an APK contains them.

## 5. Weight contract

| Weight | Name | Required usage |
|---:|---|---|
| 700 | Bold | Page and major section titles |
| 600 | SemiBold | Card and task titles |
| 500 | Medium | Buttons, labels, controls |
| 400 | Regular | Body, minor text, calendar micro-text |
| 300 | Light | Optional lightweight typography where justified |

All five weights must be locally bundled and registered under exactly one Flutter family name: `Vazirmatn`.

## 6. Centralized Theme architecture

The application must have one centralized typography definition used by light and dark themes. It must define the official family and explicit weight mapping. Widget-level `fontFamily` overrides are prohibited unless a documented third-party integration boundary makes them unavoidable.

The architecture must not introduce parallel font registries or duplicate style systems. Existing theme construction must be inspected before modification.

## 7. Global rendering guard

The application root must establish a global default typography policy covering MaterialApp descendants, DefaultTextStyle, dialogs, menus, overlays, and controllable third-party components.

The guard must preserve system and user text scaling, accessibility semantics, explicit accessibility preferences, and legitimate component-specific styles. It must not blindly replace every TextStyle or clamp accessibility scaling.

## 8. APK packaging

The official font files must be bundled locally; rendering Persian text must not require network access.

An automated packaging audit must:
- verify all five expected repository files;
- verify the exact `Vazirmatn` family registration in `pubspec.yaml`;
- build or inspect the actual APK;
- verify the expected files under `assets/flutter_assets/`;
- fail with an actionable error if a required file is missing;
- record the tested commit SHA and artifact SHA-256.

A source-tree check alone is not APK packaging evidence.

## 9. PDF output

Every exported PDF path must be inspected. Where supported by the PDF library and output format, the PDF must embed Vazirmatn font programs rather than rely on device fonts.

Validation must inspect actual generated PDF bytes and font resources, not merely test that the UI family is registered. Regular and Bold are the minimum PDF styles; additional weights may be used where the renderer supports them.

## 10. RTL and Persian acceptance

Deterministic tests and rendered samples must cover:
- Persian glyph coverage and connected shaping;
- half-space/zero-width non-joiner;
- Persian and Latin mixed runs;
- Persian and Latin digits and punctuation;
- Jalali dates and times;
- long titles and paragraphs;
- calendar micro-text and small-screen readability;
- tables and RTL alignment;
- dialogs, menus, overlays, and notifications;
- light and dark themes;
- accessibility text scaling.

Widget tests are necessary but do not replace Android device screenshots and visual inspection.

## 11. User font preference

Persist exactly two choices: Vazirmatn (default) and System Default (optional). The default must be Vazirmatn when no preference exists. A selected preference must survive app restart. The System Default choice must use the platform's normal font resolution and must not be described as an official Arvin font.

Preference migration must be non-destructive and must not discard unrelated settings.

## 12. Change control and repository protection

The following are protected product surfaces:
- this canonical document;
- `assets/fonts/ui/vazirmatn/**` and its license;
- `pubspec.yaml` font registration;
- centralized typography/theme configuration;
- typography packaging and acceptance tests;
- PDF font loading.

CODEOWNERS and GitHub Rulesets should require review by the verified repository owner account `@mobinpda-lab` for these paths. Ruleset effectiveness, bypass actors, branch restrictions, and required review counts must be verified through live GitHub settings. CODEOWNERS alone does not enforce approval.

The observed existing main ruleset at audit time does not yet require CODEOWNER approval and allows zero required approving reviews. This is a known protection gap, not an accepted final state.

## 13. Current implementation baseline (main HEAD above)

At the audited main HEAD:
- `lib/theme/app_fonts.dart` declares the Vazirmatn family constant.
- `lib/theme/font_registry.dart` exposes Vazirmatn as the sole current font option.
- `pubspec.yaml` registers only Regular, Medium, and Bold.
- the PDF renderer loads Vazirmatn Regular and Bold.
- no verified persisted System Default font preference was established in this audit.
- no verified APK packaging audit for all five weights was established.
- the unmerged SQLite execution branch previously contained explicit VazirHarf widget overrides; COMMAND 07-A.2.28 removed those overrides from Task Details, Home filter UI and Quick Capture. Exact-head Build and APK audit remain pending.

These are source inspections, not acceptance passes. Global render guard, all-surface coverage, complete five-weight packaging, PDF output inspection, preference restart persistence, and device validation remain pending.

## 14. Validation history

| Date | SHA | Evidence | Status |
|---|---|---|---|
| 2026-11-12 | `45e4202b03a434459e4c021a04efa7e8396359db` | Main source inventory and license inspected | Partial baseline only |
| 2026-11-12 | `cbf7d241e588c6b4b6051dea5bb3d309a8c3cb05` | Unmerged branch uses VazirHarf in pubspec, theme, registry, PDF, and tests | Conflict confirmed |

No validation result transfers between different SHAs. No APK, PDF, device, or runtime acceptance is claimed by this document.

## 15. Acceptance checklist

- [ ] Five local Vazirmatn weights and license present with verified SHA-256.
- [ ] One centralized Theme family and weight mapping.
- [ ] Global rendering guard verified without accessibility regression.
- [ ] Exactly two font preference choices.
- [ ] Preference persistence verified after process restart.
- [ ] APK contains all required Vazirmatn assets.
- [ ] PDF embeds and renders Vazirmatn correctly.
- [ ] Persian/RTL test matrix passes.
- [ ] Device visual validation passes.
- [ ] CODEOWNERS and effective Ruleset require owner review.
- [ ] All conflicting VazirHarf runtime references classified and retired safely.
- [ ] Canonical governance and handoff documents updated.

**Final authority:** Vazirmatn is the only official/default Arvin font. Any change requires Mobin's explicit written approval.


## 16. Candidate asset integrity — COMMAND 07-A.2.25

The following binary files were fetched from the exact PR #3384 implementation branch and SHA-256 was calculated over the decoded file bytes. This is a candidate-branch inventory, not evidence that these assets are present on `main` or packaged in an APK.

**Source ref:** `feature/command-07-a-sqlite-contract-remediation`  
**Observed implementation HEAD at audit:** `2ac3580985a23e6ac5342d49c33343c8b4f01816`  
**Flutter registration:** `pubspec.yaml` declares one family, `Vazirmatn`, with weights 300/400/500/600/700.

| Weight | File | Bytes | Git blob SHA | SHA-256 |
|---:|---|---:|---|---|
| 300 Light | `Vazirmatn-Light.ttf` | 122,920 | `2dfd5c35ed4c26f7ce9f3ba753f11d9a38356c42` | `9ab4f094b861b7d4e318f01953b9771ddeb189d7c79bbb3989d5a95a4b07ff60` |
| 400 Regular | `Vazirmatn-Regular.ttf` | 122,752 | `64e4a8189557a17b63fd7a77794207483e592972` | `b69fd4c680b8f3f225feabcc655a2c585d97627b8f5f5c0f9985e894069f3a56` |
| 500 Medium | `Vazirmatn-Medium.ttf` | 122,656 | `1e08dd54d90a4879451ef0f80fe0d8068fb7462f` | `b986623e4ddef10755e04be39f8ea7bcb1dc08bfe8dd0aa6af395736f256ad4a` |
| 600 SemiBold | `Vazirmatn-SemiBold.ttf` | 122,920 | `6b3842aca6055c8258404b1758133b81c961a13f` | `3f239d8364c14ee32c46b6839fa197c28958358b82a9673d2c6acc8506d78bc5` |
| 700 Bold | `Vazirmatn-Bold.ttf` | 123,036 | `efa9b095da01d299310bdcae293e24e657fe6da9` | `f635fdbea28f265de395ba83b4b1570dcf2f58d13c65469e61903b1c2d2ae723` |

The implementation branch retains a separate `assets/fonts/ui/vazirharf/` directory as historical material. Its files are not registered by the current `pubspec.yaml` family declaration. Explicit runtime font-family overrides were removed from Task Details, Home filter UI and Quick Capture on candidate SHA `a6d2d58d87530bfa184c93220cc329b819aca809`; exact-head Build and packaged-APK exclusion still require successful workflow evidence.

**Resolved in §18:** upstream source commit is pinned and all five font blobs plus the bundled OFL license match byte-for-byte. **Still pending:** independently re-certify the historical SHA-256 values from downloaded binary bytes; inspect actual Debug/Staging/Release APK contents; inspect generated PDF font resources and Persian shaping; validate on Android. Do not promote these candidate-branch checksums to a main/release claim.


## 17. Font binary provenance refinement — COMMAND 07-A.2.26

The actual OpenType `name` table was decoded from each of the five checked-in TTF binaries on PR #3384 candidate SHA `b78488c0347e1a97a7a25f56c914a48761d44a25`. All five report **Version 33.003** (name ID 5: `Version 33.003`; name ID 3 includes `33.003`). The source project identified in the bundled license and font asset policy is [rastikerdar/vazirmatn](https://github.com/rastikerdar/vazirmatn), and the bundled license is SIL OFL 1.1.

This establishes the embedded font binary version metadata, not the exact upstream Git commit/tag from which these binaries were copied. The upstream source commit/tag and a reproducible source-to-binary comparison remain PENDING. The five SHA-256 values in §16 remain the actual binary checksums. No claim is made that an APK has yet passed its packaging audit.


## 18. Upstream binary provenance — COMMAND 07-A.2.28

The five Vazirmatn TTF assets in the PR #3384 execution branch were compared against the upstream repository tree at the pinned source commit:

- **Upstream repository:** `rastikerdar/vazirmatn`
- **Pinned source commit:** `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7`
- **Upstream paths:** `fonts/ttf/Vazirmatn-*.ttf`
- **Arvin paths:** `assets/fonts/ui/vazirmatn/Vazirmatn-*.ttf`

Git blob object IDs and byte sizes match exactly for all five files:

| Weight | Git blob SHA (both repositories) | Bytes | Result |
|---:|---|---:|---|
| 300 Light | `2dfd5c35ed4c26f7ce9f3ba753f11d9a38356c42` | 122,920 | IDENTICAL |
| 400 Regular | `64e4a8189557a17b63fd7a77794207483e592972` | 122,752 | IDENTICAL |
| 500 Medium | `1e08dd54d90a4879451ef0f80fe0d8068fb7462f` | 122,656 | IDENTICAL |
| 600 SemiBold | `6b3842aca6055c8258404b1758133b81c961a13f` | 122,920 | IDENTICAL |
| 700 Bold | `efa9b095da01d299310bdcae293e24e657fe6da9` | 123,036 | IDENTICAL |

The upstream `OFL.txt` Git blob is `be66b3824e9772e75141e631695c5256f105fb57`; Arvin's `assets/fonts/ui/vazirmatn/LICENSE.txt` has the same blob ID and byte size (4,391 bytes). This confirms that the bundled license file is byte-for-byte identical to the upstream license at the pinned source tree.

All five binaries report OpenType version metadata `33.003`, consistent with the candidate asset inventory in §16–17. Git blob equality establishes byte-for-byte provenance for the five font files and license at the pinned source commit. It is not an APK packaging or PDF rendering acceptance result.

**Evidence scope:** the comparison was made against the unmerged PR #3384 branch tree at SHA `af2e8a697ed88be8ed924cf0a94ad30023197dec`, and upstream tree commit `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7`. It does not claim that the assets are present on `main`, packaged in a verified APK, or accepted for release.

The SHA-256 values in §16 were independently recalculated from the source files and rechecked against the embedded APK bytes on candidate 46f7b28e6631310b4617da5e717565470f7ecdbe. The corrected values are authoritative; the earlier incorrect values are retained in the COMMAND 07-A.2.30 correction note for audit traceability.


## 19. Candidate implementation update — COMMAND 07-A.2.28

**Observed product candidate:** 0aa1645999e38e32506bf3d3c15f900865428f90 (PR #3384, unmerged).

The code-level font family source is lib/theme/app_fonts.dart:
- AppFonts.vazirmatnFamily is the single canonical family constant.
- ArvinTheme.fontFamily and font_registry.dart alias that constant rather than declaring duplicate family literals.
- Flutter's required asset-family declaration remains in pubspec.yaml.

Both root themes now map the contract weights consistently:
- body/minor/calendar text: 400;
- card/task title styles: 600;
- page title: 700;
- labels and controls: 500.

The Android Reminder + Persian Typography smoke now uses the real Android SharedPreferences plugin to store System Default, recreate the app root and verify neither theme forces a family, then store Vazirmatn and recreate the root again to verify both themes and the inherited Alarm Overlay use the official family. This is app-root reinitialization; OS-level force-stop/process-kill persistence remains NOT VERIFIED.

The PDF artifact from Run 43224808961 (prior candidate 75737f4...) was downloaded and independently inspected:
- PDF bytes: 18,334; PDF SHA-256: 9cd1f26a4e565be2b8e1e29b67aedaaa0266e73c5ec7a3fb439b4a817d3147cb.
- Poppler reports Vazirmatn-Bold and Vazirmatn-Regular as embedded with Unicode maps.
- The rendered PNG was visually inspected; Persian shaping/connection and RTL layout are legible.
- The first workflow failure was a faulty awk field index, not PDF generation. Subsequent fixes correct the pdffonts column parser, account for Poppler's mixed-direction extraction order, and preserve raw plus NFKC-normalized extracted text. These corrected checks require a successful rerun on the final exact SHA.

The APK font audit now verifies the five expected entries exist in each APK and compares SHA-256 of each extracted APK font entry against its source asset. The audit also checks the pinned upstream Git blob IDs and OFL license. This audit is not yet PASS until Debug, Staging and Release jobs complete on one exact SHA and publish verifiable artifacts.

**Current acceptance state:** implementation and audit coverage expanded; exact-head CI, APK packaging, all seven device smoke jobs, D01-D05 complete acceptance, and OS-level process restart remain pending. This section records candidate implementation progress and does not alter the binding product decision in §1–2.


## 20. Exact candidate evidence update — COMMAND 07-A.2.28 execution

This section is append-only evidence and supersedes the pending statements in §19 where the same candidate SHA is concerned. It does not claim final acceptance.

### Candidate SHA and Build Run

- **Product candidate SHA:** `0aa1645999e38e32506bf3d3c15f900865428f90`
- **Build workflow:** `43232240534`
- **Run conclusion:** FAILURE (Analyze and Regression Shards 0–5 failed)
- **Visual job:** PASS
- **Debug, Staging and Release APK build jobs:** PASS
- **Font Packaging Audit:** PASS for all three APK variants.
- **APK asset integrity:** all five embedded Vazirmatn font entries were found and their SHA-256 values matched their corresponding source files.
- **Runtime legacy-font scan:** PASS; no VazirHarf runtime references remained in `lib/` or `pubspec.yaml`.
- **OFL 1.1 and family declaration checks:** PASS.

The Build run is not a full product acceptance because Analyze and all six regression shards failed. The APKs below are verified candidate artifacts for this SHA only; they must not be represented as artifacts of a later SHA.

### APK artifact evidence — candidate SHA `0aa1645...`

| Variant | Artifact ID | Artifact ZIP digest (SHA-256) | APK filename | APK bytes | APK SHA-256 |
|---|---:|---|---|---:|---|
| Debug | `13952591224` | `08068a724956971a7fb83e3750bd0e0645b519ec87c1cd93ddd3c80daa1565d9` | `app-debug.apk` | 177,130,600 | `382d975a2a12a24913b7813a652313367312266a79f9afe542ad02048830f08d` |
| Staging | `13952377083` | `169f97436cc8c0cdabb179bd13cf28af269a66295eb2b4026f0cf9c929a6ae17` | `app-staging.apk` | 80,373,625 | `9716c353cc5a7c1f070c4f46f27c1b73927897ced50f661649d8649a06ac7820` |
| Release | `13952466733` | `c4f3ab2766fc650804a6c1cc9e05ef3945bf446890968668ce8f3e8f33fa1f0b` | `app-release.apk` | 78,673,590 | `eb3b681fa1e7030eeb6a09ef74c1aacb7527f1170cdafa76f1d94e289a2d16c3` |

The APK archives were downloaded and inspected. Each APK contains:
- `Vazirmatn-Light.ttf`
- `Vazirmatn-Regular.ttf`
- `Vazirmatn-Medium.ttf`
- `Vazirmatn-SemiBold.ttf`
- `Vazirmatn-Bold.ttf`

All five embedded asset hashes matched source hashes in the Build job log. The Staging audit-candidate artifact is a duplicate verification copy and is not a separate APK variant.

### PDF artifact evidence — candidate SHA `0aa1645...`

- **Workflow Run:** `43232240534`
- **Artifact ID:** `13951483274`
- **Artifact ZIP SHA-256:** `5c2dc77f9e83d137a63d47c1aca83ac99b67a5a58761240e697e9398a43e1eb1`
- **PDF filename:** `vazirmatn-persian-acceptance.pdf`
- **PDF size:** 18,334 bytes
- **PDF SHA-256:** `18e9a9dd0471cca5d3ea60149d2ad973772938f11641babf04e45ccc34f4d24a`

Independent artifact inspection established:
- Poppler `pdffonts` identifies `Vazirmatn-Bold` and `Vazirmatn-Regular` as embedded CID TrueType fonts with Unicode maps.
- `pdftotext -layout` extraction contains Persian connected text, ZWNJ, Persian digits, Latin digits, Jalali date, mixed Persian/English, and long text.
- The generated PDF opens and renders to a PNG page.
- The rendered page was visually inspected; Persian glyphs are connected, RTL alignment is legible, and mixed-direction text is readable.

**PDF result:** PASS for the deterministic sample on candidate SHA `0aa1645...`. This does not replace full report-template coverage or device-level PDF acceptance.

### Regression and Analyze defects

The same candidate Build failed Analyze because `integration_test/alarm_overlay_smoke_test.dart` attempted to read a nonexistent `ThemeData.fontFamily` getter. The test has been corrected to inspect the effective family through `ThemeData.textTheme.bodyLarge.fontFamily`, preserving the assertions for System Default and Vazirmatn.

The registry contract test also contained stale string-literal expectations despite the implementation correctly using the centralized `AppFonts.vazirmatnFamily` constant. Its assertions now target the centralized token rather than a duplicated literal.

These two test-only corrections were committed to the execution branch:
- `0babdf3a32ee05a1aa47e7a0932190a15f6e8349`
- `46f7b28e6631310b4617da5e717565470f7ecdbe`

### Current exact-head rerun

**Current PR #3384 head:** `46f7b28e6631310b4617da5e717565470f7ecdbe`

New exact-head workflows were created automatically and are queued/in progress:
- Build: `43238200093`
- Device Smoke: `43238200496`
- SQLite Snapshot A-D: `43238200490`
- Follow-up File Persistence: `43238200586`

No result from candidate SHA `0aa1645...` transfers to `46f7b28...`. The new exact-head jobs must finish before their gates can be assessed.

### Remaining acceptance

- Analyze and Regression Shards 0–5 on `46f7b28...`: PENDING.
- Seven Device Smoke scenarios on `46f7b28...`: PENDING.
- D01–D05 full acceptance: PARTIAL; snapshot and file-backed persistence workflows alone do not prove all migration, semantic, backup/restore, atomicity and recovery requirements.
- Font preference after OS-level process termination/restart: PENDING.
- CODEOWNERS file exists on the documentation PR branch, but effective GitHub Ruleset enforcement and bypass restrictions are not verified by this evidence.
- PR #3384 and PR #3388 remain Draft and unmerged.
