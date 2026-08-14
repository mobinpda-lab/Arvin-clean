# Arvin Project Status

## Current baseline
- Branch: `feat/follow-up-history-v1.3`
- Flutter: 3.47.0 stable
- Android: V2 embedding
- FollowUp model/history and TaskStore persistence are implemented.
- Calendar foundation and Reminder tests are implemented.
- Backup/Restore and cloud-provider test coverage are implemented.

## Parallel CI policy
Feature validation is intentionally split into independent workflows for FollowUp, Calendar, Backup, and Release. A failure in one domain must not block diagnosis or progress in another domain.

## Remaining product work
1. FollowUp UI: complete create/edit/history/next-follow-up experience in Task detail.
2. Calendar/Reminder integration: connect FollowUp events to calendar and notification UX; finish responsive layout coverage.
3. Typography: add IranSansX as the default font asset and implement a persisted font selector in Settings.
4. Settings: centralize font, reminder, backup, and general preferences.
5. Backup UX: finish periodic-backup lifecycle and user-facing management.
6. Release Candidate: verify release APK artifact, checksum, versioning, and smoke test.

## Documentation rule
Every significant change must be accompanied by code, tests, CI validation, documentation, and a verifiable commit SHA.
