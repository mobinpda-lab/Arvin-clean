# VAZIRMATN FONT ACCEPTANCE — COMMAND 60-R.1
**Observed:** 2026-11-19 / ۲۸ آبان ۱۴۰۵
**Archive:** `vazirmatn-v33.003 (2).zip`
**Archive SHA-256:** `0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb`
**Archive size:** 13,047,191 bytes
**Status:** IN PROGRESS / NOT ACCEPTED

## Source archive verification
- ZIP opens successfully; 387 entries; CRC test reports no corrupt member.
- Font metadata confirms family name `Vazirmatn`.
- Standard static TTF family includes weights 100, 200, 300, 400, 500, 600, 700, 800 and 900.
- Farsi-Digits and UI-Farsi-Digits variants are included in the archive.
- Archive includes README and OFL.txt; license is SIL Open Font License 1.1.

## Canonical repository at 6d806125e91056fedb74b0644d77a273ee4b675f
- `pubspec.yaml` registers only Vazirmatn 400, 500 and 700.
- Repository assets currently contain Regular, Medium and Bold TTF files only.
- `lib/theme/app_fonts.dart` centralizes the family string as `Vazirmatn`.
- `lib/theme/font_registry.dart` currently exposes the Vazirmatn option.
- `assets/fonts/ui/vazirmatn/LICENSE.txt` contains the SIL OFL 1.1 text.
- `assets/fonts/README.md` still describes IRANSansX private assets and conflicts with the actual Vazirmatn pubspec configuration; documentation must be corrected without removing license notices.

## Existing text-size setting — preserve
Settings already has a 12–24 text-size Slider and persists changes through `AppSettingsService.saveFontSize`. `lib/main.dart` applies `settings.fontSize / 16.0` through a root `MediaQuery.textScaler`. Do not delete or recreate this setting. Verify its immediate effect, persistence after restart, and coverage across Home, Dialog, Calendar, Form and management pages.

## Remaining implementation and tests
- Register required Vazirmatn weights from the verified archive and keep one central Font Family.
- Choose the appropriate standard / Farsi-digit / UI-Farsi-digit variants based on tested Persian and Latin numeral rendering; do not silently substitute another family.
- Verify all relevant font assets are packaged and that weight selection is real rather than synthetic bold.
- Test Persian and Latin numbers, mixed text, RTL shaping and fallback behavior.
- Inspect Dialog, Calendar, Forms and management pages visually.
- Add exact-SHA typography contract and app-wide text-scale persistence tests.
- Preserve OFL notices and source attribution.

## Decision
Archive provenance and license: VERIFIED.
Repository-wide font weights and visual acceptance: NOT COMPLETE.
Font system: IN PROGRESS / NOT ACCEPTED.
