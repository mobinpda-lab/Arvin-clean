# APK FORENSIC REPORT
Artifact: user-uploaded Arvin-review-staging-13988cf50598c660f9225cd327df48b907d6e559.apk  
SHA-256: 5ea45b1aaef66532ac8dd39c5c92532d84e8c05e37b4646ed1ef7167cf3bca66  
Size: 79,267,665 bytes (about 75.6 MiB)  
Disposition: STAGING / UNVERIFIED PRODUCT ARTIFACT

## Extracted metadata
| Field | Observed value |
|---|---|
| Package | com.example.arvin.staging |
| Version Name | 1.0-staging |
| Version Code | 1 |
| Minimum SDK | 24 |
| Target SDK | 36 |
| Compile SDK | 36 |
| Variant | Staging identity; Debug/Release build type not conclusively encoded in inspected manifest |
| Architectures | arm64-v8a, armeabi-v7a, x86_64 |
| Android Gradle Plugin | 9.1.0 (embedded app metadata) |
| Flutter/Dart version | Not extractable with available APK inspection tools |
| Build timestamp | Not reliably available; ZIP entry timestamps are not trustworthy build timestamps |

## Permissions
- SCHEDULE_EXACT_ALARM
- POST_NOTIFICATIONS
- RECEIVE_BOOT_COMPLETED
- READ_CALENDAR
- WRITE_CALENDAR
- VIBRATE
- com.example.arvin.staging.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION

## Fonts
APK contains Vazirmatn Regular 400, Medium 500 and Bold 700, plus Material Icons. Weights 300 and 600 were not found in the APK font manifest.

## Signing certificate
- Subject/Issuer: CN=Arvin Review Only Test, O=Arvin, C=XX (self-issued)
- Serial: e4ed504f287e741d
- Signature: SHA384withRSA, 2048-bit
- Valid: 2026-11-08 through 2026-12-08
- Certificate SHA-256: 1DFC6EF307D5DE7D78C5CFC41D8B0403BAD31680CA84628B2D0CE4DD21117678
- JAR verification command completed, but Java reported an invalid/untrusted certificate chain (self-signed). Android APK v2/v3 signature verification was not available in this environment; do not describe the certificate as a trusted release signer.

## Source/identity comparison
- GitHub pubspec.yaml on Main and Canonical declares 1.0.1+2.
- APK declares 1.0-staging / code 1 and package com.example.arvin.staging.
- Therefore the APK does not match the repository's declared production package/version.
- No build SHA or supported VCS revision was embedded (NO_SUPPORTED_VCS_FOUND).
- The APK cannot be attributed to Canonical PR #3495 or SHA d3a82... from embedded metadata.

## Runtime acceptance
No Android SDK tools, adb or emulator are available in the inspection environment. APK was not installed or launched. Fresh install, upgrade, task/reminder/calendar/backup/PDF/RTL and process-restart scenarios remain NOT TESTED. The uploaded file was read-only; it was not modified or republished.

## Reinspection of the attached APK — 2026-11-27

The mounted user attachment was inspected read-only. SHA-256 independently recalculated as `5ea45b1aaef66532ac8dd39c5c92532d84e8c05e37b4646ed1ef7167cf3bca66`; file size 79,267,665 bytes. Binary AndroidManifest extraction confirms package `com.example.arvin.staging`, versionName `1.0-staging`, versionCode `1`, minSdk 24, targetSdk 36, compileSdk 36; permissions include SCHEDULE_EXACT_ALARM, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, READ_CALENDAR, WRITE_CALENDAR and VIBRATE. Native libraries include arm64-v8a, armeabi-v7a and x86_64. APK contains Vazirmatn Regular 400, Medium 500 and Bold 700 only.

Embedded certificate read by keytool: subject/issuer `CN=Arvin Review Only Test, O=Arvin, C=XX`, serial `e4ed504f287e741d`, SHA384withRSA, 2048-bit RSA, valid 2026-11-08 through 2026-12-08; certificate SHA-256 `1DFC6EF307D5DE7D78C5CFC41D8B0403BAD31680CA84628B2D0CE4DD21117678`. This establishes the embedded certificate identity, not trusted publisher status or a verified APK v2/v3 signature; apksigner/Android SDK verification tools and adb/emulator are unavailable here.

The APK is staging identity/version and does not match `pubspec.yaml` `1.0.1+2`. `META-INF/version-control-info.textproto` says `NO_SUPPORTED_VCS_FOUND`; no source SHA is attributable. It was not installed, launched, modified or republished. Disposition remains STAGING / UNVERIFIED.
