# Prayer Times completion lane — 2026-08-26

Parallel completion lane for Gate D.

## Implementation

- Added a local astronomical Prayer Times provider behind the existing `OfficialCalendarReminderSource` contract.
- Uses `adhan_dart` with the Tehran calculation preset and explicit coordinates/timezone offset.
- Default location is Tehran; the provider constructor keeps coordinates/location explicit and testable.
- Five daily prayers are projected into the existing `CalendarReminder` stream.
- `IranianOfficialCalendarPage` composes holidays + Prayer Times through the same official service; no second calendar store/source-of-truth is introduced.
- Failure remains handled by the existing Official Calendar retry/error boundary.

## Validation

Focused tests verify yearly cardinality, deterministic ids, prayer kind/location, chronological daily ordering, and configurable location input.

## Data boundary

Prayer calculations are local; there is no mandatory network call or new persistence key. The underlying calculation library uses astronomical formulae and the Tehran method preset.

## Current integration baseline

- Rebased/reconstructed on `main` `93e56d3cc6cd124f0aa6e7023091b63048ab08ea` after Gate H / PR #199 merged.
- The branch includes the new Release regression surface and must pass fresh exact-head Fast Lane/full Build evidence on this baseline.
- Older green runs remain historical only and are not merge evidence for the current head.

Refs #195 #153 #199.
