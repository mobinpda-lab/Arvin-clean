# CI stale-run concurrency — 2026-08-26

## Goal
Reduce wasted GitHub Actions time when an active PR branch is rebuilt or force-updated, without weakening validation or cancelling post-merge builds on `main`.

## Arvin Build
- Pull-request runs use the PR number as their concurrency key.
- A newer validation for the same PR cancels the older in-progress PR validation.
- Pushes to `main`/`master` use the unique GitHub run id as their key, so every merged main commit keeps its own post-merge Build.

## Arvin Parallel Wave
- Push and pull-request events for the same working branch share the branch name as the concurrency key.
- This collapses duplicate/stale runs created when `fix/**`, `ci/**`, or `wave/**` branches are pushed and also have an open PR.
- A newer branch validation cancels the older one.

## Guardrails
- No test, analyze, surface, APK build, APK verification, or artifact upload step was removed.
- Main post-merge validation remains non-cancellable by newer main commits through this policy.
- The change only controls stale-run scheduling; validation content is unchanged.

## Expected effect
Fewer obsolete CI jobs consume runners after branch rebuilds, making active PR feedback arrive sooner while preserving the exact-head and post-merge validation rules used by Arvin production.
