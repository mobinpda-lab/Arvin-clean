# Arvin v1 Status

**Updated:** 2026-08-20

## Project
- Repository: `mobinpda-lab/Arvin-clean`
- Platform: Flutter
- Default branch: `main`
- Active Wave: **Wave A — Core + Architecture**
- Active PR: **#108**
- Active branch: `wave-a/core-storage-boundary-v1`

## Current status
- PR #107: 🟢 MERGED
- PR #108: 🟡 OPEN
- Latest documented corrective commit on PR #108: `1a83de14b222abcaf4bf53aa50ccd5fd56a51331`
- Latest reported test status: 🔴 94 passed / 1 failed
- Failing test: `test/widget_test.dart` — `HomePage loads legacy storage through the unified reader`
- Current priority: validate the latest commit with a real GitHub Actions run before merge.

## Documentation and evidence rules
1. GitHub is the source of truth for executable state.
2. Project documentation is the source of truth for architecture, governance and roadmap.
3. Conversation/memory provides continuity but must be reconciled with current repository evidence.
4. When sources disagree, identify and resolve the discrepancy; do not guess.
5. Never claim a commit, push, workflow, test, build or merge unless it actually happened.
6. Do not update code merely to make CI green; first identify the real contract/gap.
7. Important decisions and meaningful changes must be documented in the appropriate current-state, handoff, audit or changelog document.

## Development rules
1. Review context, current code, open PRs and relevant documentation before changes.
2. Make small, controlled, reversible changes.
3. Reuse existing capabilities and avoid duplicate architecture/storage/models.
4. Do not change `main` directly for normal development.
5. Use branch → commit → PR → workflow → validation → review → merge.
6. Run focused tests and required validation after changes.
7. Verify the actual workflow result for the exact commit/ref being discussed.

## Parallel execution principle
Arvin development is intentionally **parallel + simultaneous + fast**, with the goal of producing software in hours rather than days.

Independent work should proceed concurrently whenever there is no shared-file, shared-foundation or architectural conflict. Parallel execution must remain controlled so it does not create duplicate work or conflicting implementations.

## Current next action
1. Validate the latest PR #108 commit with the real CI pipeline.
2. If green, review and merge #108.
3. Immediately continue Wave A and start independent next-wave work in parallel where safe.
4. If red, fix only the verified failure and rerun validation.

## Risk areas
- Data migration
- Core model/storage boundaries
- Shared foundation changes
- CI/workflow behavior

DeepSeek consultation is recommended for major architecture, migration, storage or other high-risk decisions.
