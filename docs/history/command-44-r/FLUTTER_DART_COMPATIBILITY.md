# FLUTTER / DART COMPATIBILITY — COMMAND 44-R

**Status:** HISTORICAL FLUTTER VERSION EVIDENCED / DART RUNTIME TO BE RECORDED

| Item | Evidence | Decision |
|---|---|---|
| Flutter | PR #3384 historical `.github/workflows/build.yml` declares `FLUTTER_VERSION: '3.47.0'` | Pin runner to 3.47.0 |
| Dart | Bundled with Flutter 3.47.0; no independent exact Dart pin found in inspected project config | Record `dart --version` and `flutter --version --machine` at runtime; do not invent a separate version |
| Dart constraint | Historical `pubspec.yaml`: `>=3.5.0 <4.0.0` | Compatibility range only, not an exact SDK version |
| Runner OS | Existing historical build workflow uses `ubuntu-latest` | Use Ubuntu GitHub-hosted runner |
| Native SQLite | Historical v19/v20 lockfile pins `sqlite3 3.6.0`; lock also contains `sqlite3_flutter_libs 0.6.0+eol` | Install Linux SQLite development package and record actual `SELECT sqlite_version()` from Dart NativeDatabase |

## Source revisions

- v19 project/workflow source: `310c0e20e3447c488c1e1c102c38bea5040708ca`.
- v20 project source: `812082964c649be7660c41213209ec34aea7167b`.
- Historical v19 and v20 `pubspec.lock` blob: `ceeb9f91e3dd7f6877b1a024c0903fc6ae9c44c4`.

Flutter 3.47.0 is the only exact SDK version established by repository evidence. The actual Dart patch/build identifier and runtime SQLite version will be written into the Actions artifact; until that run exists, those values are intentionally not asserted.
