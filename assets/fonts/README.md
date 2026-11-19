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

| Flutter weight | Upstream file | Git blob SHA |
|---:|---|---|
| 100 | Vazirmatn-Thin.ttf | b7a7d233e2a78b48d2eaa6733dd4ba683a92d847 |
| 200 | Vazirmatn-ExtraLight.ttf | b7b947e6acda06dd5c545a2fcd506900500afaa8 |
| 300 | Vazirmatn-Light.ttf | 2dfd5c35ed4c26f7ce9f3ba753f11d9a38356c42 |
| 400 | Vazirmatn-Regular.ttf | 64e4a8189557a17b63fd7a77794207483e592972 |
| 500 | Vazirmatn-Medium.ttf | 1e08dd54d90a4879451ef0f80fe0d8068fb7462f |
| 600 | Vazirmatn-SemiBold.ttf | 6b3842aca6055c8258404b1758133b81c961a13f |
| 700 | Vazirmatn-Bold.ttf | efa9b095da01d299310bdcae293e24e657fe6da9 |
| 800 | Vazirmatn-ExtraBold.ttf | 380bd15866f3364d7c34af1cbd3c15a2e209dfee |
| 900 | Vazirmatn-Black.ttf | 4b9bd66179952e5b2edcfd97acbdef6d4acd0ea2 |

All nine font files are sourced from the same upstream tag. The five previously present weights (300–700) were compared by Git blob SHA and match upstream exactly; the four missing weights (100, 200, 800, 900) were added from the same tag. The asset regression test checks the FontManifest weights and loads every bundled TTF at runtime.

Upstream AUTHORS.txt blob SHA: 6efd2e62407e08b482647e134f9098b44e5ae5ec. Upstream OFL.txt blob SHA: be66b3824e9772e75141e631695c5256f105fb57.

Do not replace this family with VazirHarf or another font without a newer explicit product-owner decision. Preserve the license and authors files with the font binaries.
