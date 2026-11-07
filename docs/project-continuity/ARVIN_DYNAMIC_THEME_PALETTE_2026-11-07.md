# Arvin Dynamic Theme Palette — implementation checkpoint

**Date:** 2026-11-07  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR:** #3052 — must remain OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO

## Implemented in source

- Added `AppThemeManager`, a ChangeNotifier-backed owner for the selected accent color.
- Added the nine approved palette entries and SharedPreferences key `arvin.settings.primaryColor`.
- The default when no valid selection exists is palette option 8, `#3A86EF`.
- Unsupported or stale color values are not restored; the manager falls back to the approved default.
- Added the palette grid to Settings under «انتخاب تم و رنگ اصلی برنامه».
- Selecting a swatch saves the choice and notifies the app root; light and dark Material color schemes, app bar, navigation, chips, progress indicators, buttons and focused input borders derive from the selected accent.
- Updated the canonical static fallback brand token from the former turquoise default to vivid sky blue.
- Added focused tests for the default, supported palette, persistence/restore, invalid color rejection and Settings selection.

## Important acceptance distinction

This checkpoint records source changes only. It does not claim successful compilation, passing tests, full repository-wide replacement of every custom hard-coded accent, visual acceptance at 360/390/412dp, or physical-device acceptance on Samsung SM-A528B/DS. The existing custom widgets that still consume static semantic color constants require a full audit before describing every screen as fully palette-reactive.

## Required next evidence

1. Exact-HEAD Analyze and all test shards.
2. Debug/Review APK build and artifact inspection.
3. Layout checks at 360, 390 and 412dp, portrait, including settings palette and representative forms.
4. Physical install and live color-switch/restart persistence test on Samsung SM-A528B/DS.
5. Update this checkpoint with actual run IDs, artifact digests, device evidence and the final commit SHA.

No changes to `main`, merge, publication or release are authorized.
