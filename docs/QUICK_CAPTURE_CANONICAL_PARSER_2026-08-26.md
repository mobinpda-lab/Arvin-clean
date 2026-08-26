# Quick Capture canonical parser — 2026-08-26

## Scope
This slice advances the Quick Capture lane in Issue #92 without creating a second task model or persistence path.

## What changed
- Added `QuickCaptureService` that converts one short text line directly into canonical `Task`.
- Standalone `#tag` tokens become Task tags.
- Remaining text becomes the Task title.
- Repeated tags are de-duplicated while preserving input order.
- Whitespace is normalized.
- Empty input is rejected.
- Tag-only input uses the existing `بدون عنوان` title fallback.
- `createdAt` is provided by the caller so the service stays deterministic and testable.

## Product boundary
This is the parsing/core slice only. It does not claim the full Quick Capture feature or add a new UI entry point yet.

## Validation
Focused tests cover Persian input, tag extraction, duplicate tags, whitespace normalization, empty input, tag-only capture, and embedded `#` text such as `C#`.

## Guardrails
- No new storage key/database/repository.
- No parallel Task model.
- No network dependency.
- No UI rewrite.
- Merge only after exact-head `Arvin Build` and `Arvin Parallel Wave` validation.
