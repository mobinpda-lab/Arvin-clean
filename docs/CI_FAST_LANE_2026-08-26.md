# Arvin CI Fast Lane — 2026-08-26

Issues: #193, #200

## Goal
Reduce delivery latency from repeated heavy PR validation without weakening the final merge gate.

## Verified bottleneck
Before Fast Lane, every PR head ran both:
- `Arvin Build`: analyze + full test + release APK + debug APK;
- `Arvin Parallel Wave`: analyze + full test + independent surfaces + another release APK.

That duplicated APK production during iterative commits and made small corrections pay the full delivery cost repeatedly.

A second bottleneck was discovered after API-driven branch reconstruction: repository writes on `feat/**` / `test/**` did not reliably emit a usable `pull_request/synchronize` run for the new exact head. Old green CI must never be reused for a moved head.

## Fast Lane contract
### Draft / iterative feature work
Fast feedback is available through `Arvin Parallel Wave` for PR events and direct pushes on `wave/**`, `ci/**`, `fix/**`, `feat/**`, and `test/**`:
- dependency restore;
- analyze;
- full Flutter tests;
- independent FollowUp/Calendar/Backup/Typography/Release surfaces.

The heavy `Arvin Build` job is skipped while a normal PR is Draft.

### Ready PR
When a Draft PR is marked Ready for review and GitHub delivers the event, `Arvin Build` runs on that exact head and performs the canonical full gate:
- Android platform generation;
- desugaring configuration;
- Android V2 audit;
- analyze;
- full tests;
- release APK build/verification/artifact;
- debug APK build/verification/artifact.

### API-driven exact-head fallback
When an automated rebase/reconstruction changes a PR head but PR events do not produce a fresh full Build, create or move a validation ref named `gate/pr-<number>` to **the exact PR head SHA**. `Arvin Build` accepts `gate/**` pushes and runs the same full gate. This is merge evidence only when the workflow run `head_sha` exactly equals the current PR `head_sha`.

Rules for gate refs:
- a gate ref contains no unique product work; it only points at an already existing PR head commit;
- move it again whenever the PR head changes;
- never treat a Build from a previous SHA as current evidence;
- feature/test branches still receive fast Parallel Wave push feedback;
- the PR remains the review/merge object; `gate/**` is only a deterministic validation trigger.

### Main
Every push/merge to `main` keeps a full `Arvin Build`; post-merge evidence is not cancelled by newer main commits through the PR concurrency policy.

## Merge rule
A product PR is merged only when:
1. its exact head has successful `Arvin Parallel Wave` evidence (PR event or feature/test push);
2. the same exact head has successful full `Arvin Build` evidence (Ready PR event or `gate/**` exact-SHA trigger);
3. the head has not moved;
4. normal review/integration checks are satisfied.

After merge, the resulting `main` commit must still receive its full post-merge Build.

## Why quality is not reduced
- No production test is removed from the final gate.
- Full Flutter tests still run during fast feedback.
- Android V2 audit remains in the canonical full Build.
- Release/debug APKs still exist before merge and again on main.
- The optimization removes duplicate/intermediate APK work and event uncertainty, not validation requirements.

## Rollback rule
If Fast Lane causes missing exact-head full Build, missing Android audit, or unreliable gate-ref evidence, revert the workflow change and restore the previously known-safe validation path until the trigger contract is corrected.

## Production rule
Fast Lane is an Automation aid. It must not become a reason to split product work into smaller PRs. Prefer meaningful vertical slices containing implementation + integration + tests + documentation, then use fast feedback and one final heavy exact-head gate.

Refs #153 #195.
