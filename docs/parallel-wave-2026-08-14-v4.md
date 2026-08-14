# Parallel Wave v4 — 2026-08-14

## Goals
Keep independent software areas running concurrently while preventing one surface from failing unrelated surfaces.

## Independent jobs
- Quality: full analyze + full test
- Android Release: generate Android, configure desugaring, audit V2 embedding, build and upload APK
- FollowUp: targeted FollowUp test with smoke fallback
- Calendar: targeted Calendar test with smoke fallback
- Backup: targeted Backup test with smoke fallback
- Typography: targeted widget/typography smoke test

## CI changes
- `fail-fast: false` remains enabled for the surface matrix.
- Android platform is generated before the V2 audit.
- Core library desugaring is configured before the APK build to satisfy `flutter_local_notifications`.
- APK artifact names use the workflow run ID and fail when the artifact is missing.

## Commit
- CI: `cf66c9c2bc5ebe9cbad3dac81a733b8fbb2e0f15`
- PR: #32
