# Arvin — Parallel UI/UX Polish & Architecture Alignment
**Date:** 2026-11-09  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Authorized branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR:** #3052 — OPEN / DRAFT / UNMERGED  
**Reviewed source HEAD:** `58445bfbfe7880ece44527223a16390c96a63ed0`  
**Release:** BLOCKED — RELEASE: NO-GO

## 1. Scope and evidence boundary
This is a source-level structural audit and integration specification. It does not claim a Flutter build, widget test, emulator run, screenshot review, or physical-device acceptance. No UI source files were changed in this analysis wave.

## 2. Task Details — current structure
Evidence: `lib/task_detail_page.dart`.
- The page uses a fixed top summary/header and one vertically scrolling `ListView` for the detail sections. This is a single-column page structure; no two-column details grid was found in the reviewed page composition.
- Operational actions are composed as vertically stacked sections. The shared `_linearActionRow` switches to a compact vertical layout below 480 logical pixels.
- Compact rows currently use a 56dp minimum outer height, 12dp horizontal and 9dp vertical padding, a 28dp trailing slot, and ellipsis on title/value text. The due-date action uses this shared row component.
- The row is not literally configured with 48dp padding. The 48dp requirement should be treated as a minimum actionable target, not as 48dp of internal padding. Preserve the existing 56dp minimum row height unless measured tests show a safe reduction is needed.

### Integration specification
1. Keep Task Details single-column at all supported widths. Do not introduce side-by-side operational cards in the compact layout.
2. Preserve a minimum 48x48dp hit target for every actionable row/control; keep row content and hit target within the same InkWell/Material interaction surface.
3. Keep compact mode stacked: leading icon/trailing action, title, then value. Do not force the title and long date/value into one horizontal line at 360dp.
4. Keep title and value at one line with ellipsis; avoid fixed text widths. Use flexible constraints for any future inline controls.
5. Validate RTL layout at 320, 360, 390, and 412dp; include long Persian titles, long date/time strings, selected/disabled states, and text scaling 1.0x / 1.3x / 1.5x.
6. Add/retain widget assertions for zero RenderFlex overflow, minimum hit-target dimensions, and tappability of the complete operational row.

## 3. Brand glow and surface tint
Evidence: `lib/core/theme/arvin_theme.dart`, `lib/arvin_colors.dart`, and the ThemeData setup in `lib/main.dart`.
- Canonical soft glow is already defined as `ArvinTheme.primaryGlow = Color(0x403A86EF)`; `ArvinTheme.shadowStyle`, `ArvinColors.shadowSoft`, and `ArvinColors.shadowDark` use the same value.
- Task Details custom cards use `ArvinTheme.shadowStyle`, so this surface follows the requested glow.
- The app ThemeData explicitly makes ColorScheme surface tint, CardTheme, DialogTheme, and AppBarTheme tint transparent in the reviewed setup.
- There is a consistency gap: CardTheme and filled-button shadow colors are currently derived from the selected accent color with alpha values rather than always using the canonical `Color(0x403A86EF)`. Therefore, strict app-wide use of the fixed glow token is NOT yet proven or fully aligned.
- The source-level inspection did not exhaustively establish that every custom Material/Card surface across every Dart file explicitly neutralizes `surfaceTintColor`.

### Integration specification
1. Keep `ArvinTheme.primaryGlow` as the sole canonical fixed glow token: `Color(0x403A86EF)`.
2. Route decorative soft-glow shadows through the shared token/style rather than duplicating accent-derived shadow colors. Preserve stronger elevation shadows only where interaction hierarchy requires them and document the exception.
3. Keep `surfaceTintColor: Colors.transparent` on app-wide theme defaults and explicitly on custom Material surfaces that can otherwise receive Material 3 tint.
4. Add a source-contract test that scans the relevant theme/surface constructors for tint omissions and verifies the canonical glow value. Pair it with widget screenshots; a text-only test cannot prove visual shadow rendering.
5. Do not change the user-selected accent palette as a side effect of standardizing the fixed soft glow.

## 4. Branding placement
Evidence: `lib/main.dart` Home header and `lib/calendar_page.dart` Calendar AppBar.
- Home uses `assets/images/branding/bismillah.svg` in the centered branding group beside the «آروین» title.
- Calendar uses `assets/images/branding/tafweez.svg` in the Calendar sacred-header AppBar title.
- The reviewed Home header source does not reference `tafweez.svg`; the reviewed Calendar header source does not reference `bismillah.svg`.

### Integration specification
1. Keep `bismillah.svg` exclusive to the Home header.
2. Keep `tafweez.svg` exclusive to the Calendar section header.
3. Preserve the current semantic labels and stable widget keys (`home-bismillah-svg`, `calendar-sacred-header-svg`).
4. Add a repository-level branding contract test that asserts the intended asset-to-section mapping and rejects cross-placement.
5. Keep the Home header visually quiet: Bismillah vector plus Arvin product identity only; do not introduce the Calendar sacred vector into Home.

## 5. Next integration wave — ordered work
| Priority | Work item | Required evidence |
|---|---|---|
| P0 | Re-check 360dp Task Details operational rows and due-date action | Widget tests at 320/360/390/412dp; zero overflow; hit-target assertions |
| P1 | Unify soft glow usage on canonical token | Theme/source contract test plus before/after widget screenshots |
| P1 | Complete app-wide surface tint inventory and explicit neutralization | Enumerated source audit and targeted widget tests |
| P1 | Lock Bismillah/Home and Tafweez/Calendar asset placement | Branding contract test and Home/Calendar screenshots |
| P2 | Confirm visual consistency at enlarged text scale and RTL | Screenshot evidence at 1.3x/1.5x and long Persian content |

## 6. Governance and release gates
- All implementation work from this specification must remain on `fix/recovery-calendar-device-smoke-2026-10-31`.
- PR #3052 must remain OPEN / DRAFT / UNMERGED. Do not merge, close, retarget, or mark ready for review.
- Do not modify `main`.
- This document does not upgrade any CI, visual, device, product-acceptance, or release gate.
- Release remains **BLOCKED — RELEASE: NO-GO** until all required gates pass on one exact candidate SHA and owner acceptance is recorded.

## 7. Audit result
**Source-level findings recorded; implementation integration pending.** The single-column structure and asset placements match the requested direction in the reviewed source. The 48dp target still needs explicit test coverage, the shadow token usage is not yet uniform, and the app-wide tint audit is not exhaustive.