# Licensed IRANSansX assets

This public repository intentionally does not contain the proprietary IRANSansX binary files.

For a licensed local/private build, place these two files in this directory with the exact names below:

- `IRANSansXFaNum-Regular.ttf`
- `IRANSansXFaNum-Bold.ttf`

The project loads them at startup as the `IRANSansXFaNum` family and falls back safely to the platform font when they are absent (for example in public CI).

You can install the files from the purchased `IranSansX(Eco).zip` package by running:

```bash
bash tool/install_iransansx.sh /path/to/IranSansX\(Eco\).zip
```

If your FontIran license requires a project-specific license code or `FontLicense.txt`, keep that licensing material with the private build assets as required by your issued license; do not publish proprietary font binaries through this public repository.

## Open-source Vazirmatn UI font

Arvin's official Persian UI font is **Vazirmatn v33.003** from the upstream release tag v33.003:

- Upstream: https://github.com/rastikerdar/vazirmatn/tree/v33.003
- Release archive: vazirmatn-v33.003.zip
- Archive SHA-256: 0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb
- License: SIL Open Font License 1.1 (OFL.txt, stored as assets/fonts/ui/vazirmatn/LICENSE.txt)
- Authors: upstream AUTHORS.txt, copied byte-for-byte to the app assets.

The app bundles all nine **static** TTF weights (not a variable font):

| Flutter weight | Upstream file |
|---:|---|
| 100 | Vazirmatn-Thin.ttf |
| 200 | Vazirmatn-ExtraLight.ttf |
| 300 | Vazirmatn-Light.ttf |
| 400 | Vazirmatn-Regular.ttf |
| 500 | Vazirmatn-Medium.ttf |
| 600 | Vazirmatn-SemiBold.ttf |
| 700 | Vazirmatn-Bold.ttf |
| 800 | Vazirmatn-ExtraBold.ttf |
| 900 | Vazirmatn-Black.ttf |

All nine font files are sourced from the same upstream tag. The five previously present weights (300–700) were compared by Git blob SHA and match upstream exactly; the four missing weights (100, 200, 800, 900) were added from the same tag. The asset regression test checks the FontManifest weights and loads every bundled TTF at runtime.

Do not replace this family with VazirHarf or another font without a newer explicit product-owner decision. Preserve the license and authors files with the font binaries.
