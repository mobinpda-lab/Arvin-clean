# Font Audit — ARVIN Wave 6.69

## Decision and scope

Current product decision: **Vazirmatn is the canonical public/default font. VazirHarf is a separate font family and is not an approved substitute.** This audit compares the live repository at baseline SHA 18cbeecc95a03a3b301359ca5b96cfef175a3b15, the user-provided vazirmatn-v33.003 (2).zip, Git history, active Flutter/Android/CI references, and a real APK artifact from the baseline build.

## Baseline repository font files

The recursive Git tree at baseline SHA contained exactly these project-owned TTF font assets; no tracked OTF, WOFF, WOFF2, or APK/AAB was found in the repository tree.

| Path | Bytes | Internal family | Internal style / weight | Internal version | SHA-256 |
|---|---:|---|---|---|---|
| assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf | 122,752 | Vazirmatn | Regular / 400 | 33.003 | b69fd4c680b8f3f225feabcc655a2c585d97627b8f5f5c0f9985e894069f3a56 |
| assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf | 122,656 | Vazirmatn | Medium / 500 | 33.003 | b986623e4ddef10755e04be39f8ea7bcb1dc08bfe8dd0aa6af395736f256ad4a |
| assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf | 123,036 | Vazirmatn | Bold / 700 | 33.003 | f635fdbea28f265de395ba83b4b1570dcf2f58d13c65469e61903b1c2d2ae723 |

The three baseline repository files were compared byte-for-byte with the archive's standard static files fonts/ttf/Vazirmatn-Regular.ttf, fonts/ttf/Vazirmatn-Medium.ttf, and fonts/ttf/Vazirmatn-Bold.ttf. Each pair matched both SHA-256 and Git blob SHA. The corrective branch then added the matching standard SemiBold 600 file, also byte-identical to the supplied archive and upstream commit 6e553e33489a8f9dfaccc76860a2e3f3c1e66de7. These are **not** the archive's separately named misc/UI-Farsi-Digits files.

The archive contains 296 font files: 148 TTF and 148 WOFF2, with no OTF or WOFF entries. It includes standard static and variable fonts plus UI, Farsi-Digits, UI-Farsi-Digits, Non-Latin, Farsi-Digits-Non-Latin, and Round-Dots variants. Internal names identify Vazirmatn version 33.003; weights range from 100 through 900 depending on variant. The standard archive's SemiBold 600 file is 122,920 bytes with SHA-256 3f239d8364c14ee32c46b6839fa197c28958358b82a9673d2c6acc8506d78bc5. It was absent at baseline and is now added on the corrective branch after matching the upstream Git blob SHA 6b3842aca6055c8258404b1758133b81c961a13f. No existing font files were deleted or replaced.

## Corrective branch asset set

The corrective branch tracks all four standard static weights. The added SemiBold blob is the same Git blob found at the upstream snapshot commit 6e553e33489a8f9dfaccc76860a2e3f3c1e66de7.

| Path | Bytes | Internal family | Weight | Version | SHA-256 |
|---|---:|---|---:|---|---|
| assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf | 122,752 | Vazirmatn | 400 | 33.003 | b69fd4c680b8f3f225feabcc655a2c585d97627b8f5f5c0f9985e894069f3a56 |
| assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf | 122,656 | Vazirmatn | 500 | 33.003 | b986623e4ddef10755e04be39f8ea7bcb1dc08bfe8dd0aa6af395736f256ad4a |
| assets/fonts/ui/vazirmatn/Vazirmatn-SemiBold.ttf | 122,920 | Vazirmatn | 600 | 33.003 | 3f239d8364c14ee32c46b6839fa197c28958358b82a9673d2c6acc8506d78bc5 |
| assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf | 123,036 | Vazirmatn | 700 | 33.003 | f635fdbea28f265de395ba83b4b1570dcf2f58d13c65469e61903b1c2d2ae723 |

## Baseline runtime references and CI behavior

- pubspec.yaml declared family VazirHarf and four asset paths under assets/fonts/vazirharf/fonts/ttf/, none of which existed in the recursive tracked tree.
- lib/main.dart and lib/settings_page.dart treated vazirharf as the default font id.
- lib/theme/font_registry.dart marked Vazirmatn unavailable and VazirHarf available.
- lib/calendar_page.dart explicitly used AppFonts.vazirharfFamily.
- lib/services/task_report_pdf_renderer.dart loaded missing VazirHarf Regular/Bold paths.
- Tests asserted the VazirHarf paths and the Build/Device Smoke/Release workflows downloaded upstream VazirHarf at commit 3cbc943b9fb9107baa77008b3e96b3c3e40e9ed8, then copied it into the working tree before tests/build. This runtime injection masked missing tracked assets and caused the wrong family to be packaged.

## Fallback and dependency audit

No Android-native font resource directory (android/app/src/main/res/font) or explicit fontFamilyFallback declaration was found. Flutter font registration is through pubspec.yaml. pubspec.lock contains no dedicated Vazirmatn/VazirHarf font package; the canonical assets are local files. The explicit System option intentionally delegates to platform fonts. Unknown or retired font ids converge to Vazirmatn; optional catalog entries without bundled files still delegate to platform fallback and are not treated as the primary font.

## Historical evidence

- c93cd03ea48a91b792fb995537cac3c847920a89 originally introduced Vazirmatn as the default public font and bundled the UI-Farsi-Digits four-weight set.
- 64699b49f1b76ed8ed0bad70e681e0dff1e1bac4 changed the canonical contract to VazirHarf and removed the earlier Vazirmatn assets. This was an explicit historical change, not a filename-only collision.
- 1a517d277db7ba536c5d5353fba36c4042562057 later reintroduced three Vazirmatn TTF files under assets/fonts/ui/vazirmatn/, while the active registry, pubspec, PDF renderer, docs, and CI still favored VazirHarf.

## Actual baseline APK inspection

Source SHA: 18cbeecc95a03a3b301359ca5b96cfef175a3b15
Build run: [39785332668](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39785332668), completed successfully.
Artifact: arvin-release-apk from run 39785332668.
APK SHA-256: bb2a85a7c6082b0ae7b30b34358405d6e3c01d76e7e090369411327e95c60b4e.
APK size: 70,056,469 bytes.
The APK's assets/flutter_assets/FontManifest.json declared VazirHarf, not Vazirmatn. Its embedded font files were internally identified as VazirHarf revision 34.003:

| Embedded APK asset | Bytes | Internal weight | Version | SHA-256 |
|---|---:|---:|---:|---|
| Vazirharf-Regular.ttf | 135,844 | 400 | 34.003 | 1d4e7bc3c167ff79cf77dde0fa8ec85f56293ab3810a92c7ccaca9bd3e9cb1dc |
| Vazirharf-Medium.ttf | 135,788 | 500 | 34.003 | 18bdf39eb6167073f2b15008450fbffb4005804550d5daad0f119ba4bc98552c |
| Vazirharf-SemiBold.ttf | 136,056 | 600 | 34.003 | fb3944cec1784523a559a4eb8d4077f1a7b758f0c14c123f6b062de0c5bfdcb1 |
| Vazirharf-Bold.ttf | 136,148 | 700 | 34.003 | c632fd9082174e11b695383835075da41ba064c13fb243bf1cac9862b4c559e8 |

The APK also contains Flutter's MaterialIcons-Regular.otf; that is an icon font, not a Persian text family.

## Wave 6.69 corrective changes

- Register the four tracked Vazirmatn weights in pubspec.yaml.
- Set Vazirmatn as the runtime default and locally available font.
- Normalize persisted and portable legacy VazirHarf values to the canonical vazirmatn id.
- Point PDF output and Calendar typography at Vazirmatn.
- Remove CI-time VazirHarf downloads/copies; add tracked-asset SHA-256 gates and APK FontManifest.json checks.
- Update active typography contracts/tests. Older decision-log and historical audit entries are retained as historical records and are superseded by this Wave 6.69 decision.
- No Android Gradle configuration or production signing was changed.

## Validation status at initial commit

Baseline Build/Analyze/test shards and Device Smoke passed on the baseline SHA, but they validated an APK containing VazirHarf because CI injected it. Those results do not pass the current font-identity acceptance gate.

Post-change flutter pub get, flutter analyze, focused tests, Android build, packaged APK manifest, visual shaping, half-space, Persian digits, and device screenshots must be checked on the exact corrective commit. Until those results exist, mark them **NOT VERIFIED**. Release remains **BLOCKED — RELEASE: NO-GO**.


## Wave 6.70 — Asset failure reconciliation and PDF font-loader coverage

### Exact cause of Contract Test run 39898856452

- Run: [39898856452](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39898856452), completed with conclusion `failure`.
- Workflow/event commit SHA: `80d3100e91075167768dcb6916a05ad3bf57ef2b` on `docs/wave-6-10-exact-sha-evidence`.
- The workflow deliberately checked out and tested the pinned historical target SHA `35d445ea1bcf9a1bfd3e9999d495284db0753cf3`; the checkout matched that target exactly.
- `flutter pub get --enforce-lockfile`: **PASS**, exit code 0.
- `flutter test test/device_smoke_workflow_contract_test.dart`: **FAIL**, exit code 1. The test run emitted: `unable to locate asset entry in pubspec.yaml: "assets/fonts/vazirharf/fonts/ttf/Vazirharf-Regular.ttf"`.
- Root cause: the tested historical commit's Flutter asset/font contract referenced the absent VazirHarf TTF path. This run did **not** test the corrected typography branch and its failure must not be attributed to a newer SHA.

### Corrective branch and existing exact-head evidence

The current corrective branch is `fix/wave-6-69-vazirmatn-canonical`, PR [#2918](https://github.com/mobinpda-lab/Arvin-clean/pull/2918), with previously validated head `6582f4bdb522aa3e4bda9a70123133e59af1712f`. PR #2913 remains separate and was not edited by the typography correction. A backup branch `backup/wave-6-70-pre-audit-6582f4b` was created at that prior head before Wave 6.70 edits.

- [Build run 39855109824](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39855109824): **PASS** on exact PR head `6582f4bdb522aa3e4bda9a70123133e59af1712f`. `flutter analyze`, six test shards, and Debug/Release APK jobs succeeded.
- [Device Smoke run 39855109795](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39855109795): **PASS** on that same exact PR head; all seven selected scenarios succeeded, including Calendar, SQL Persistence, SQL Migration, Backup/Restore, Home, Quick Capture, and People.
- Build logs verify all four tracked font SHA-256 values against the repository manifest and confirm that the packaged Flutter `FontManifest.json` declares only the `Vazirmatn` text family with weights 400/500/600/700, using the four local paths. No `VazirHarf` family is present in that manifest.
- Release APK from that Build run: SHA-256 `b2867e5364e46fbaa598ed628b1d9c173a8a6c81b0cffae86e8aa58cd1ec508b`. This is internal CI artifact evidence, not official release approval.

### PDF verification gap and Wave 6.70 test change

The production PDF renderer now points at local `assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf` and `Vazirmatn-Bold.ttf`. However, the previous PDF test injected Helvetica through a custom font loader, so its passing result did not prove that the production local font loader could resolve those assets.

Commit `79f888440a08e2cc102458356ba4f183270f8e3e` updates `test/task_report_pdf_renderer_test.dart` to exercise the default production loader with Persian text, a half-space, and Persian digits. Its exact-head CI result is **PENDING** at the time of this audit entry; do not report this new test as passing until the corresponding run is complete.

The four standard static Vazirmatn v33.003 files remain verified against the supplied reference archive/upstream snapshot:
- Regular 400: `b69fd4c680b8f3f225feabcc655a2c585d97627b8f5f5c0f9985e894069f3a56`
- Medium 500: `b986623e4ddef10755e04be39f8ea7bcb1dc08bfe8dd0aa6af395736f256ad4a`
- SemiBold 600: `3f239d8364c14ee32c46b6839fa197c28958358b82a9673d2c6acc8506d78bc5`
- Bold 700: `f635fdbea28f265de395ba83b4b1570dcf2f58d13c65469e61903b1c2d2ae723`

### Remaining acceptance limits

Automated exact-head tests/build and APK asset identity are distinct from manual visual acceptance. Pixel-level Persian shaping/kerning, physical-device typography, exhaustive fallback behavior, and visual review of an actual PDF remain **NOT VERIFIED** by the evidence listed above. No SQL migration or release action is authorized by this audit. Release remains **BLOCKED — RELEASE: NO-GO**.
