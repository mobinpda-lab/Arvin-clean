# Android Emulator Smoke — 2026-08-26

Issue #229. Refs #195 #225.

## Purpose

Add real Android runtime evidence to Gate H while keeping physical-device acceptance explicit.

## Path

`GitHub Actions -> Android Emulator -> real Arvin app -> Persian Home -> TaskDialog -> canonical Task persistence path`

## Scope

- Uses Flutter's SDK `integration_test`; no product runtime dependency is added.
- `Arvin Device Smoke` runs only for Ready PRs, main pushes, or manual dispatch; Draft PRs keep the heavy emulator job skipped.
- The emulator boots through `reactivecircus/android-emulator-runner@v2` with KVM enabled on Ubuntu.
- The smoke launches the real application, verifies Persian Home, opens the real Task dialog, fills its labeled fields and creates a Task through the user-facing Home path.
- Existing Analyze/Test/Parallel/Build/release+debug APK gates remain unchanged.
- This evidence is additive. Physical launcher/keyguard/resize/print/system-calendar behavior is still not inferred from emulator smoke.

## Runtime findings

### Finder correction

The first real run showed that a broad `TextField` count also included the Home search field. The smoke was corrected to target the actual Task dialog fields by their labels (`عنوان`, `توضیحات`, `تگ`) without weakening the user-flow assertion.

### Product defect found by Android runtime

The next run reached the real Save action and exposed a product bug not caught by existing widget tests: `TaskMigrationReader.load()` can return an unmodifiable list, while Home later appends a newly created Task. That produced `Unsupported operation: Cannot add to an unmodifiable list` on the real Android path.

Home now copies the canonical loaded values into a mutable list with `List<Task>.of(value)` before user edits. The Task objects themselves and the canonical persistence path remain unchanged. `home_mutable_task_list_contract_test.dart` prevents the unsafe assignment from returning.

## Merge gate

Require exact-head Parallel Wave, full Arvin Build/release+debug APK and exact-head Arvin Device Smoke on the final PR head. After merge, require both main Build and main Device Smoke evidence before Gate H score promotion.
