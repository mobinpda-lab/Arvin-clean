# FONT INVENTORY REPORT — COMMAND 60-R
**Status:** IN PROGRESS — one archive fully inspected.

## Available ZIP
- Name: `vazirmatn-v33.003 (2).zip`
- Source: ChatGPT Library and current conversation ZIP inventory.
- Size: 13,047,191 bytes.
- SHA-256: `0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb`.
- ZIP integrity: passed; 387 entries; no corrupt member reported.
- Actual family metadata inspected from TTF: Vazirmatn (including Vazirmatn FD and Vazirmatn UI FD variants).
- Formats: TTF, WOFF2; variable TTF/WOFF2 also present.
- Static weights in standard TTF: Thin 100, ExtraLight 200, Light 300, Regular 400, Medium 500, SemiBold 600, Bold 700, ExtraBold 800, Black 900.
- Farsi-digit and UI-Farsi-digit variants include the same nine static weights.
- License: SIL Open Font License 1.1; archive contains OFL.txt and README.
- Persian/Arabic family is documented by its upstream README; Latin glyphs are combined with Roboto in the standard family. Non-Latin variants are also supplied.
- File health: archive opens and all ZIP members pass CRC validation.

## Repository source at baseline
- `pubspec.yaml` declares Vazirmatn Regular 400, Medium 500, Bold 700.
- `lib/theme/app_fonts.dart` exposes family `Vazirmatn`.
- Repository license: `assets/fonts/ui/vazirmatn/LICENSE.txt`, OFL 1.1.
- Build APK font packaging audit passed on baseline SHA.
- `assets/fonts/README.md` describes proprietary IRANSansX local assets, which conflicts with the actual pubspec font declaration and requires cleanup/reconciliation.

## Missing / unresolved
- No `VazirHarf-v34.003.zip` or equivalently named VazirHarf archive was found in the current Library/conversation ZIP listing.
- A previous owner source reference to VazirHarf v34.003 exists in historical project context, but the current product decision file records a Vazirmatn/VazirHarf authority conflict. Do not replace the current font without source-of-authority reconciliation.
- No other font ZIPs were found in the available ZIP inventory; this statement is limited to the visible Library/conversation listing.
