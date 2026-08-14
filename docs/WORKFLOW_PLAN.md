# Arvin Workflow Plan

## CI lanes

### Feature Validation
Validates Dart/Flutter behavior without claiming an Android release:
- `flutter pub get` with retry
- `flutter analyze`
- full `flutter test`
- focused FollowUp, Calendar, TaskStore and Backup tests

### Release Validation
Validates the actual Android release path:
- Flutter 3.47.0
- dependency resolution with retry
- Android V2 audit
- Core Library Desugaring audit
- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- APK existence check
- APK artifact upload

## Definition of done

A feature is complete only when its code, tests and documentation are committed and visible in GitHub. A release is green only after the release workflow successfully produces `app-release.apk` and uploads it as an artifact.

## Next feature sequence

1. Stabilize release APK.
2. Complete FollowUp History UI.
3. Stabilize Calendar and Reminder integration.
4. Add IranSansX as the default font and a persistent font switcher in Settings.
5. Run release candidate validation and update project status/version documentation.
