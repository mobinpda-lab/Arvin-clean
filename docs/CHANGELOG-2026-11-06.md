# CHANGELOG — 2026-11-06 (PR #3052 exact-SHA audit)

**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Evidence code SHA:** `19fcb58e17f51624dd69b1047f7ddfcbeec77c5a`  
**Evidence checkpoint:** `docs/project-continuity/ARVIN_PR3052_CHECKPOINT_2026-11-06_SHA-19fcb58.md`

## Verified on the evidence SHA
- Draft Review APK workflow #803 / run `42282761255` succeeded. A real review-only staging APK was downloaded and inspected. APK SHA-256: `44f1908cdb47571229e96b78efc9a52e7953900cdd9433a55a220d2a6dee8fcd`; size: 79,038,285 bytes; package `com.example.arvin.staging`; debuggable=false; v2/v3 signature verified; Vazirmatn Regular/Medium/Bold assets present.
- The APK uses an ephemeral review-only key and is not publishable. No production signing or release was performed.
- Calendar Provider workflow #2131 / run `42282761379` succeeded on the exact SHA. Instrumentation verified CREATE, no-op update without duplication, update of the same event, delete, and survival of the canonical Task after provider-event deletion.

## Failed or incomplete evidence
- Build #9993 / run `42282761205`: Analyze and APK build jobs succeeded, but all six test shards failed (1,317 passed / 23 failed). This run is not a Build PASS.
- Independent Calendar failures include month-view measured height 342dp versus the test's <280dp assertion, rendering failures during period navigation, and a duplicate date-text assertion.
- Independent Reports failures include the exact-range filter panel assertion, person-specific active waiting rows, and active filter chip count.
- Home and form failures include missing `home-compact-filter-scroll` finder key, a 53px right-side Task Editor overflow, Quick Add's missing «ایجاد جدید» control in the tested flow, and additional Home/Category/Project assertions.
- Device Smoke #7229 / run `42282761181` remains PENDING with no jobs/artifacts. It is not accepted.
- The 360/390/412dp UX matrix with keyboard open/closed has not been executed in this checkpoint; no layout or touch-target PASS is claimed.

## Governance
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- main remains untouched; no merge, publication or release.
- Release decision remains **BLOCKED — RELEASE: NO-GO**.
- No test was removed, skipped, bypassed or weakened. This entry records observed evidence; it does not claim the outstanding code fixes are complete.


## 2026-11-07 — Dynamic theme palette implementation (acceptance pending)

- Added a ChangeNotifier-backed `AppThemeManager` with the nine approved accent colors and SharedPreferences key `arvin.settings.primaryColor`.
- The no-selection default is option 8, Vivid Sky Blue `#3A86EF`; unsupported stored values fall back to this default.
- Added «انتخاب تم و رنگ اصلی برنامه» to Settings. Selecting a swatch persists the value and notifies the app root for live Material theme rebuilding.
- Light/dark ColorScheme and the primary Material component themes now use the selected accent. The canonical static fallback brand token is also Vivid Sky Blue.
- Added focused manager and Settings widget tests. These tests are source additions only; exact-HEAD CI has not yet established PASS.
- Repository-wide custom accent usage and full-screen reactivity remain subject to further audit; no claim of complete visual migration is made here.
- 360/390/412dp geometry, physical Samsung SM-A528B/DS installation, restart persistence, and screenshot acceptance remain NOT VERIFIED.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched. **BLOCKED — RELEASE: NO-GO.**
