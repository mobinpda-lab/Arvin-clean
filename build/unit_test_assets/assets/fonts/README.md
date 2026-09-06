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
