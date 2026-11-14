# VazirHarf v34.003 — Asset provenance and license

## Canonical source

- Upstream repository: https://github.com/nadalaba/vazirharf
- Release tag: `v34.003`
- Pinned commit: `3cbc943b9fb9107baa77008b3e96b3c3e40e9ed8`
- Commit date: 2026-09-01
- Upstream commit message records the v34.003 version bump and font build.
- Selected variant: `misc/UI-Farsi-Digits/fonts/ttf`; this is the UI-optimized family with Persian-digit glyphs.
- Flutter family registered by Arvin: `VazirHarf`.

## Exact upstream Git blob identities

| Weight | Upstream file | Git blob SHA |
|---|---|---|
| Light 300 | `Vazirharf-UI-FD-Light.ttf` | `664da9092e47a0ebf6edd4ac1ad952020d10331e` |
| Regular 400 | `Vazirharf-UI-FD-Regular.ttf` | `e87f175fa0cf3843488e7ee7020e2c6060391f89` |
| Medium 500 | `Vazirharf-UI-FD-Medium.ttf` | `38937ef2b5ed781506b0b18889dac3addef73104` |
| SemiBold 600 | `Vazirharf-UI-FD-SemiBold.ttf` | `d14afecd1a9ae0aacb1bec6eeb649d9d638f7c73` |
| Bold 700 | `Vazirharf-UI-FD-Bold.ttf` | `1024a03bdc34bb4c8938741596c4558314d0d6c0` |
| License | `OFL.txt` | `bef621e4f7e06942700f2d20d076a6fde2aab348` |

The bundled TTF and license Git blob identities match the pinned upstream objects. The license declares SIL Open Font License 1.1 and the Reserved Font Name "Vazirharf".

## Runtime contract

- All light/dark UI themes use `VazirHarf`.
- The five approved weights are registered in `pubspec.yaml`.
- PDF rendering embeds the bundled UI-FD Regular and Bold files.
- Persian digits, punctuation and RTL must be verified through the exact-SHA widget, PDF and Android integration tests.
- No Vazirmatn runtime fallback or System Default fallback is allowed.
- Historical Vazirmatn assets remain in the repository for audit only; they are not declared in `pubspec.yaml` and must not enter the APK.
- Portable settings do not export a font picker preference; restore ignores legacy `fontFamily` keys.

## License

The complete upstream SIL OFL 1.1 text is included at `assets/fonts/ui/vazirharf/OFL.txt`.
