# Android Emulator Smoke — 2026-08-26

Issue #229. Refs #195.

## Purpose

Add real Android runtime evidence to Gate H while keeping physical-device acceptance explicit.

## Path

`GitHub Actions -> Android Emulator -> real Arvin app -> Persian Home -> TaskDialog -> canonical Task persistence path`

## Scope

- Uses Flutter's SDK `integration_test`; no product runtime dependency is added.
- `Arvin Device Smoke` runs only for Ready PRs, main pushes, or manual dispatch; Draft PRs do not consume emulator runtime.
- The emulator boots through `reactivecircus/android-emulator-runner@v2` with KVM enabled on Ubuntu.
- The smoke launches the real application, verifies Persian Home, opens the real Task dialog and creates a Task through the user-facing Home path.
- Existing Analyze/Test/Parallel/Build/release+debug APK gates remain unchanged.
- This evidence is additive. Physical launcher/keyguard/resize/print/system-calendar behavior is still not inferred from emulator smoke.

## Merge gate

Require exact-head Fast Lane, Ready full Arvin Build/APKs and exact-head Arvin Device Smoke. After merge, require both main Build and Device Smoke evidence before Gate H score promotion.
