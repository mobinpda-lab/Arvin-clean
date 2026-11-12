# Font asset policy

## Canonical public/default application font

Arvin bundles **VazirHarf v34.003** from:

- Repository: https://github.com/nadalaba/vazirharf
- Pinned source commit: `3cbc943b9fb9107baa77008b3e96b3c3e40e9ed8`
- Variant: `misc/UI-Farsi-Digits/fonts/ttf` (UI-optimized TTF with Persian digits)
- License: SIL Open Font License 1.1; the exact upstream `OFL.txt` is bundled beside the font assets.
- Flutter family: `VazirHarf`

The five registered weights are Light 300, Regular 400, Medium 500, SemiBold 600 and Bold 700. PDF rendering uses the same bundled Regular and Bold assets.

## Legacy Vazirmatn assets

The previous `assets/fonts/ui/vazirmatn/` files and their license are retained in the repository for historical/source audit. They are not declared by `pubspec.yaml`, are not loaded by application code, and must not be packaged in current APKs. Do not delete them without a separate compatibility review.

## Licensed/private IRANSansX assets

This public repository intentionally does not contain proprietary IRANSansX binary files. For a licensed local/private build, keep the required license material and use the dedicated installation process. These files do not replace the canonical public/default VazirHarf family.
