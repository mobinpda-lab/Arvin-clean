# Multi-term canonical search — 2026-08-26

## Scope
This slice advances the Search lane in Issue #92 without adding a new search engine, index, storage key, or repository.

## What changed
- `TaskSearchService` now treats a multi-word query as AND terms.
- Terms may match across different canonical fields of the same task, such as title + tag or tag + follow-up result.
- Category and checklist text are included in the existing canonical search corpus.
- Persian/Arabic character normalization, diacritic handling, zero-width handling, and existing single-term behavior remain intact.

## Product effect
Home already routes search through `HomeSearchProjection` and `TaskSearchService`, so this improvement is available to the existing Home search without a parallel UI or persistence path.

## Validation
Regression tests cover cross-field multi-term queries, category/checklist text, AND semantics, Persian variants, separators, and empty-query ordering.

This branch was rebuilt directly from current `main` after PR #162 merged so the validation gates run against the latest product state.

## Guardrails
- No embeddings or external service.
- No new database/index.
- No UI rewrite.
- Keep canonical Task data as the only search source of truth.
- Merge only after fresh `Arvin Build` and `Arvin Parallel Wave` checks are green on the current exact head.
