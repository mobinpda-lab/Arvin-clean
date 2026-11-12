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

The repository currently does not record a pinned upstream release/tag or source commit for its Vazirmatn binary set. That provenance must be established before the asset migration is accepted. Do not infer a release version from filenames.

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
- a separate unmerged SQLite branch changes runtime references and tests to VazirHarf, conflicting with this approved decision and requiring remediation.

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
| 300 Light | `Vazirmatn-Light.ttf` | 124,971 | `2dfd5c35ed4c26f7ce9f3ba753f11d9a38356c42` | `c33eb953aaa07b69cb5b97c9926f54e5f57fb95207b64eb2f2639f6289075366` |
| 400 Regular | `Vazirmatn-Regular.ttf` | 124,800 | `64e4a8189557a17b63fd7a77794207483e592972` | `447d349f593b58dedb25f17afe0ec25c3cfc428aaf031e8a4e6c101b7b4f78a9` |
| 500 Medium | `Vazirmatn-Medium.ttf` | 124,702 | `1e08dd54d90a4879451ef0f80fe0d8068fb7462f` | `fcb0a3b08c6fe26e0316e7bbb32b907e1336efa5db05ee735cca7109bf28cbc6` |
| 600 SemiBold | `Vazirmatn-SemiBold.ttf` | 124,971 | `6b3842aca6055c8258404b1758133b81c961a13f` | `f50b7587fa62356c09bdbfe24fb70e66eea882502c92efe243df4d5b6ea8c61a` |
| 700 Bold | `Vazirmatn-Bold.ttf` | 125,087 | `efa9b095da01d299310bdcae293e24e657fe6da9` | `dad307bfe9baf4d92326183f743ecfc091576224cb8f6a4a0623bfc48eb24c13` |

The implementation branch retains a separate `assets/fonts/ui/vazirharf/` directory from its historical work. Its files are not registered by the current `pubspec.yaml` family declaration. Runtime and packaged-APK exclusion still require exact-head tests and artifact inspection.

**Still pending:** pin the upstream Vazirmatn release/tag or source commit; verify the bundled license against that source; inspect actual Debug/Release APK contents; inspect actual generated PDF font resources and Persian shaping; validate on Android. Do not promote these candidate-branch checksums to a main/release claim.


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

The SHA-256 values previously recorded in §16 remain historical checksum records; this command's independent provenance proof is the exact Git blob identity comparison above. Recalculation from downloaded binary bytes remains a separate integrity step if the SHA-256 records are to be re-certified.
