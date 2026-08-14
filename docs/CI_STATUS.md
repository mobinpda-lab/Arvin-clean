# Arvin CI Status

## Baseline
- Repository: `mobinpda-lab/Arvin-clean`
- Branch: `feat/follow-up-history-v1.3`
- Flutter: `3.47.0` stable
- Android target: V2 embedding

## Validation workflows

### Release pipeline
`.github/workflows/build.yml`

Validates the release path:
1. Checkout exact source commit
2. Flutter setup
3. Android V2 audit/bootstrap guard
4. Core library desugaring audit/configuration
5. `flutter pub get` with retry
6. `flutter analyze`
7. `flutter test`
8. `flutter build apk --release`
9. APK verification and artifact upload

### Focused feature pipeline
`.github/workflows/feature-validation.yml`

Added in commit `e0c83322d448ae67142b0699be16d34cc1103e4c`.

It intentionally separates feature regressions from release failures and runs:
- full `flutter analyze`
- full `flutter test`
- FollowUp model/presentation/history-card tests
- Calendar tests
- TaskStore tests
- Backup service tests

## Current interpretation rules

- A green feature-validation run does not mean the release APK is green.
- A green release run is required before declaring Android release readiness.
- Temporary `pub.dev` authorization/network failures are infrastructure failures unless the same failure reproduces after retry.
- Every claimed code or workflow change must have a visible Git commit SHA.

## Next operational order

1. Run the focused feature workflow.
2. Fix only reproducible test/analyze failures.
3. Run the release workflow and verify actual APK artifact.
4. Stabilize Calendar and FollowUp History UI.
5. Integrate IranSansX as the default font and add a persistent font selector in Settings.
6. Keep this document updated whenever CI architecture or release criteria change.
