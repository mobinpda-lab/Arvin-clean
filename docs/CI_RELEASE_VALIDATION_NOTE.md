# CI Release Validation Note

**Updated:** 2026-08-16

The release-validation workflow must validate the repository in the same generated Android environment used by the primary Build workflow.

The Flutter project intentionally keeps generated Android platform files out of the repository. Therefore Release Validation must run `flutter create --no-pub --platforms=android --project-name arvin .` before auditing `android/app` and must apply the same core-library-desugaring configuration as `build.yml`.

The workflow is also aligned with `main` so a manual release-validation run on the production branch does not fail merely because generated Android files are absent from source control.

This is a CI-only correction. It does not change Task, Reminder, FollowUp, Calendar, migration, storage, or production save semantics.
