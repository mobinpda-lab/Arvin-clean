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

After a full green validation wave, the next validation wave is launched on the next meaningful commit with all independent workflows running concurrently. Manual dispatch is also enabled for the domain workflows so an individual green/failed area can be revalidated without coupling it to another area.

## Product roadmap / remaining work
### Wave A — product completion (parallel)
1. FollowUp UI: complete create/edit/history/next-follow-up experience in Task detail.
2. Calendar/Reminder integration: connect FollowUp events to calendar and notification UX; finish responsive layout coverage.
3. Typography: add IranSansX as the default font asset and implement a persisted font selector in Settings once the real font asset is supplied.
4. Settings: centralize font, reminder, backup, and general preferences.

### Wave B — hardening (parallel)
5. Backup UX: finish periodic-backup lifecycle and user-facing management.
6. Integration tests: cover Task → FollowUp → Calendar/Reminder flows and persistence boundaries.
7. Accessibility/RTL/responsive polish across the new surfaces.

### Wave C — Release Candidate
8. Verify release APK artifact, checksum, versioning, smoke test, and release notes.
9. Final documentation audit: ensure every significant feature has code + tests + CI + documentation + verifiable commit SHA.

## Guardrails
- Do not redo stable Android/CI infrastructure unless a workflow exposes a new reproducible failure.
- Do not block one product area on another; continue independent work in parallel.
- Do not claim a Release Candidate until the APK artifact is actually produced and verified.
- Keep IranSansX asset integration pending until the real font file is available; build the selector architecture without inventing a font binary.

## Latest green validation wave
Commit `7aa5b6137b0047baaf77751b6b6e22a2f5071ecc` completed with all seven validation workflows successful: Android audit, Analyze, Full Tests, Backup, Calendar, FollowUp, and Release.

## Documentation rule
Every significant change must be accompanied by code, tests, CI validation, documentation, and a verifiable commit SHA.
