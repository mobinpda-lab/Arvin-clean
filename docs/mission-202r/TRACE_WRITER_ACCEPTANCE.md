# Mission 202-R — Trace Writer Acceptance

## Scope
This document records the REV11.22 Trace Writer contract. It is not a release or product acceptance certificate.

## Implemented
- Product exceptions are rethrown with their original object identity and Stack Trace when the ERROR record is persisted.
- Writer exceptions are rethrown with their original object identity and Stack Trace when terminal persistence fails.
- When both product execution and ERROR persistence fail, `ArvinTraceDualFailure` retains both original exceptions and both original Stack Trace objects.
- A failed END is never reported as SUCCESS. The writer attempts an ERROR diagnostic; if that also fails, the operation remains visible in `missingEndOperationIds`.
- The operation callback is invoked once by `run`.
- The already-started Future compatibility adapter awaits the same Future rather than invoking product work again. It preserves the Future result on trace-only failure and exposes that writer failure through `compatibilityWriterFailures`.

## Acceptance cases
| ID | Required behavior | Test |
|---|---|---|
| TW-01 | Product exception identity and original Stack Trace | `TW-01 preserves product exception identity and original stack` |
| TW-02 | Writer exception identity and original Stack Trace | `TW-02 preserves writer exception identity and stack` |
| TW-03 | Both failures retained independently | `TW-03 retains product and writer failures together` |
| TW-04 | Product callback executes once | `TW-04 product callback is invoked exactly once after START` |
| TW-05 | Compatibility Future result is preserved and writer failure remains observable | `compatibility Future preserves product result on writer failure` |

## Status vocabulary
- **IMPLEMENTED:** source code contains the behavior.
- **TESTED:** an acceptance test exists.
- **VERIFIED:** the test completed successfully on the exact commit SHA.
- **ACCEPTED:** owner acceptance has been explicitly recorded.

At this documentation commit, implementation and test definitions are present. Runtime verification is pending exact-SHA CI. No acceptance is claimed.
