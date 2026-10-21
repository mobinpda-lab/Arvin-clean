# CI Release Validation Note

**Updated:** 2026-09-08

Arvin v1 release validation consumes repository-owned build inputs. Release workflows must not regenerate or patch critical Android/Gradle configuration at runtime.

Canonical reproducible inputs:
- Flutter SDK: `3.47.0`
- dependency graph: committed `pubspec.lock`, resolved with `flutter pub get --enforce-lockfile`
- Android project: committed `android/` configuration and Gradle wrapper
- Gradle: `9.3.1`
- Android Gradle Plugin: `9.1.0`
- Kotlin Android plugin: `2.4.0`
- Java/JVM target: `17`
- core-library desugaring: `com.android.tools:desugar_jdk_libs:2.1.5`
- VazirHarf source revision: `3cbc943b9fb9107baa77008b3e96b3c3e40e9ed8`

`Arvin Build`, `Arvin Device Smoke`, `Arvin Release Closure`, and `Arvin Final Head Release Validation` must validate these tracked inputs directly. Dependency resolution must fail on lock incompatibility and must not rewrite `pubspec.lock` silently.

Android SDK compile/min/target values remain provided by the pinned Flutter 3.47.0 Gradle integration referenced by the tracked Android project; changing Flutter or the Android toolchain requires explicit lock/toolchain revalidation.

This release-engineering contract does not change Task, Reminder, FollowUp, Calendar, migration, storage, or production save semantics.

## Personal-use Debug APK lane — Wave 5.83

The Debug APK is a personal-install artifact and is separate from the official Release APK. The Build workflow publishes it as `arvin-personal-debug-apk` only after `apksigner verify --verbose --print-certs` succeeds, exactly one signer certificate SHA-256 is parsed, and the APK SHA-256 plus source checkout SHA are written to `build/apk-evidence.txt`. The APK job checks out and verifies the PR head SHA (or the explicit `target_sha` for workflow_dispatch); it does not silently treat the PR merge ref as the personal artifact's source.

The signature diagnostic records the apksigner path and version, captures the command's actual exit status, and prints its output only on failure. Certificate digest parsing accepts colon-separated or unseparated hexadecimal output and rejects any result other than 64 hexadecimal characters. Signature verification is never skipped.

**Update compatibility limitation:** the default Gradle Debug signing key on an ephemeral CI runner is not guaranteed to persist across workflow runs. Until a project-approved persistent personal signing key is configured through a secure Actions-secret path, each generated Debug APK may have a different signer and seamless in-place updates are not guaranteed. Do not uninstall an existing installation containing personal data just to install a differently signed APK. This personal lane does not require official Release signing secrets and does not change the official Release gate: Release remains blocked unless trusted Release credentials and the independently sourced certificate fingerprint validate.

Wave 5.83 is an implementation note, not a pass claim. The Build run on the final documentation SHA must supply the actual APK, artifact URL, APK SHA-256, signer fingerprint, signature verification result, and exact source SHA before `PERSONAL APK PASS` can be declared.
