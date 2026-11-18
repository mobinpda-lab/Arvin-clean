# Semantic Query Expansion v1 — 2026-08-27

Issue #241. PR #242. Refs #92.

## Purpose

Advance Semantic Search on the existing canonical `TaskSearchService` without creating a second search engine, index, database, repository, storage key, network dependency, or embeddings service.

## Product behavior

The existing Home search path continues to use `HomeSearchProjection → TaskSearchService` over the canonical Task list.

Each normalized user query token remains an AND requirement. For a small explicit set of high-confidence task-management concepts, that token is expanded into an equivalent local alias group and any alias in that group may satisfy the token.

Current v1 groups are intentionally narrow:

- `تماس` ↔ `زنگ`
- `جلسه` ↔ `ملاقات`
- `فوری` ↔ `ضروری`
- `پرداخت` ↔ `واریز`
- `ارسال` ↔ `فرستادن`

Unknown tokens are not fuzzed or guessed; they keep the existing exact normalized substring behavior.

## Semantics

- OR inside one explicit alias group.
- AND across separate query tokens.
- Matching may still occur across different canonical Task fields exactly as before.
- Existing Persian/Arabic letter normalization, diacritic handling, separator handling and input ordering behavior remain intact.

Example: `تماس فوری` can match a Task whose title contains `زنگ` and whose tag contains `ضروری`, while a Task that satisfies only one concept is excluded.

## Guardrails

- no embeddings or external AI service
- no network call
- no search index or cache
- no new database/storage/repository
- no parallel Search UI
- no mutation/reordering of source Tasks
- no broad edit-distance/fuzzy matching that can silently increase false positives
- semantic vocabulary remains explicit, reviewable and small

## Validation

Focused tests cover:

- alias matching in either direction;
- semantic multi-term AND behavior across canonical fields;
- unknown-term exact fallback;
- real `HomeSearchProjection → TaskSearchService` wiring;
- all pre-existing exact, normalization, category/checklist and FollowUp regressions.

This slice was rebuilt directly on post-#243 main `0f920731bf8340dbee42baab1a4de4f38e3a824c`. Normal feature pushes do not create duplicate Parallel Wave runs. Exact-ref validation uses `ci/**`, `gate/**`, and the new deterministic `device/**` path so Parallel Wave, full APK Build and Device Smoke can validate one identical Head SHA. Merge only after all required exact-head evidence is green, followed by post-merge main validation.
