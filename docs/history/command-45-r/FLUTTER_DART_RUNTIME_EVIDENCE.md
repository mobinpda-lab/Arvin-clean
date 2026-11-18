# Flutter / Dart Runtime Evidence — COMMAND 45-R

Source: GitHub Actions run 44287318505 and run 44287623079, both with v19 and v20 matrix lanes.
Status: TOOLCHAIN AND DEPENDENCY BOOTSTRAP PASS; SQLITE SMOKE TEST BLOCKED.

## Exact toolchain

- Flutter: 3.47.0, stable
- Flutter framework revision: 4cf24164269a5ebf0c16a028a00727d0e77bbb05
- Flutter engine revision: 5f77625673248ee5846fbcaf5d3e1a3878386fd7
- Dart SDK: 3.13.0 stable
- DevTools: 2.60.0
- Runner OS: Ubuntu 26.04.1 LTS, linux_x64
- SQLite native build prerequisite: libsqlite3-dev 3.46.1-9ubuntu0.3 already installed

## Flutter Doctor

Flutter 3.47.0 and Chrome checks passed. Connected device discovery and network resources passed. Doctor reported two non-blocking environment categories:
- Android toolchain: Android SDK 37.0.0 present, but some Android licenses were not accepted.
- Linux desktop toolchain: GTK 3.0 development libraries missing; eglinfo unavailable.

Doctor therefore reported issues for Android licensing and Linux desktop development. The historical smoke test is a Linux-hosted SQLite test and does not require an Android emulator or Linux desktop build.

## Dependencies and lockfile

- flutter pub get --enforce-lockfile: PASS
- pubspec.lock remained unchanged: PASS
- pubspec.lock SHA-256: 146c122f71109fae332a2dcfcffc63f8b48e51eebcd183758b0808443f4bcabc
- Drift: 2.35.0
- sqlite3: 3.6.0

## Runtime acceptance

Flutter and Dart toolchain identity and dependency installation are proven for the completed runs. NativeDatabase physical fixture inspection is not accepted because the Dart test process terminated with SIGBUS after opening the connection and completing its first query. No migration was run.

## Addendum — runtime crash localization

Run 44295851388 reconfirmed Flutter 3.47.0 and Dart 3.13.0 in both v19 and v20 lanes, with dependency resolution and fixture hash verification passing. The diagnostic markers confirm all expected table queries completed and the JSON snapshot encoded successfully. The SIGBUS occurred after `SNAPSHOT_JSON_ENCODE_DONE` and before `SNAPSHOT_WRITE_DONE`, during asynchronous snapshot file output. The next candidate SHA 5646cfc06977e3d0b4999874b33aa8c0892c9296 changes that operation to synchronous file output; run 44296037837 was in progress when this addendum was written.