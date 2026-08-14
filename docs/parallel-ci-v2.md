# Parallel CI v2

Date: 2026-08-14

## Purpose

Keep independent Arvin validation surfaces parallel without allowing an unrelated surface failure to mask another surface's status.

## Matrix

- FollowUp: dedicated follow-up tests when present, otherwise smoke test
- Calendar: calendar tests when present
- Backup: backup tests when present
- Typography: font/typography/settings tests when present, otherwise smoke test
- Quality: full analyze + full test
- Android: generate Android platform, audit V2 embedding, build release APK, upload artifact

The matrix uses `fail-fast: false` so independent jobs continue running after another job fails.

Commit: `5dc12dbcad1c6381f4b32c82fa6d2dc7f43bb0f7`
