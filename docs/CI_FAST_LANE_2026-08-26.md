# Arvin CI Fast Lane — 2026-08-26

Issue: #193

## Goal
Reduce delivery latency from repeated heavy PR validation without weakening the final merge gate.

## Verified bottleneck
Before this change, every PR head ran both:
- `Arvin Build`: analyze + full test + release APK + debug APK;
- `Arvin Parallel Wave`: analyze + full test + independent surfaces + another release APK.

That duplicated APK production during iterative Draft commits and made small corrections pay the full delivery cost repeatedly.

## Fast Lane contract
### Draft PR
Draft work receives fast feedback through `Arvin Parallel Wave`:
- dependency restore;
- analyze;
- full Flutter tests;
- independent FollowUp/Calendar/Backup/Typography surfaces.

The heavy `Arvin Build` job is skipped while the PR is Draft.

### Ready PR
When a Draft PR is marked Ready for review, `Arvin Build` runs on that exact head and performs the canonical full gate:
- Android platform generation;
- desugaring configuration;
- Android V2 audit;
- analyze;
- full tests;
- release APK build/verification/artifact;
- debug APK build/verification/artifact.

`Arvin Parallel Wave` does not repeat release APK production. Its role is fast independent quality/surface feedback.

### Main
Every push/merge to `main` keeps a full `Arvin Build`; post-merge evidence is not cancelled by newer main commits through the PR concurrency policy.

## Merge rule
A product PR is merged only when:
1. its exact head has successful `Arvin Parallel Wave` evidence;
2. the same exact head, after becoming Ready, has successful `Arvin Build` evidence;
3. the head has not moved;
4. the normal review/integration checks are satisfied.

After merge, the resulting `main` commit must still receive its full post-merge Build.

## Why quality is not reduced
- No production test is removed from the final gate.
- Full Flutter tests still run during Draft feedback.
- Android V2 audit moves into the canonical full Build rather than disappearing.
- Release/debug APKs still exist before merge and again on main.
- The optimization removes duplicate/intermediate APK work, not validation requirements.

## Rollback rule
If the Fast Lane causes a missing exact-head full Build, missing Android audit, or unreliable ready-for-review triggering, revert the workflow change and restore APK validation on every PR until the trigger contract is corrected.

## Production rule
Fast Lane is an Automation aid. It must not become a reason to split product work into smaller PRs. Prefer meaningful vertical slices containing implementation + integration + tests + documentation, then use Draft for iterative feedback and Ready for the final heavy gate.

Refs #153.
