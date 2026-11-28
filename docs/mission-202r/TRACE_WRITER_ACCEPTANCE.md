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


## REV11.34 — exact-SHA checkpoint evidence (2026-11-24)
The baseline commit 9d58e92203a32a22f7bc67b92552afe19db3ac50 was verified in Build run 45372415634, Trace job 138369867655.
- test/services/arvin_async_trace_test.dart: PASS, exit code 0.
- scripts/mission_202r_metadata.py --self-test: 18 regression scenarios passed.
- Real arvin-async-trace.jsonl was present and matched metadata SHA-256 e626c616862445893b8a2fe22fa7ae97af7ada43506492b3cef21e331e79644e.
- Trace artifact ID 14928130294; archive digest sha256:63a37db7c7e53b203a51bb74b795846934049b64ec24e599cbd3274da0ad5070.
- The Trace suite and metadata self-test are verified on this exact SHA. This does not establish full regression acceptance: the aggregate was 1, Center had four timeouts, Home had 18 failures, and Backup had nine failures.
- TW-01 through TW-05 were not deliberately re-run by REV11.34. Their prior acceptance state remains unchanged; no new claim is made about them.
- The overall Build run remained FAILURE, so this evidence is scoped to the Trace suite and metadata self-test only.

## REV11.34 Trace workflow repair status
TRACE-AGG-01 and TRACE-AGG-02 are implemented and locally tested by TWA-01 through TWA-06. Exact-SHA GitHub runner verification is pending. Missing Trace JSONL must remain MISSING and NO-GO; artifact upload must still run. No synthetic JSONL is acceptable.

## REV12.10 — artifact and scope checkpoint
Historical Run `45442396285`, Trace job `138617005431`, artifact `14962712644` was independently downloaded and checked:
- ZIP SHA-256: `e1d2e2a7c92a416ae4bcab74e4c3a46485a38537e45064dc3e11496f7d181904`
- JSONL SHA-256: `248c5a307620a6904e793dc6be3e0cde0642cda0501ee94206a37a09b709be14`
- Events: 29 START / 28 END / 1 ERROR; no operation ID lacked a terminal event.
- The one ERROR is the expected wrong-passphrase `FormatException` from the negative encrypted-backup scenario.
- Trace suite exit code: 0. Center, Home and Backup UI suite exit codes: 1; Encrypted Backup integration suite: 0; aggregate: 1.
- The artifact validates the independent Trace Writer test outcome but does not accept Center/Home/Backup UI behavior.

The later runner-boundary correction is a separate TaskStorageLock concern. It does not modify the Trace Writer acceptance contract above. New exact-SHA verification for the TaskStorageLock repair is pending Build run `45762850359`. Trace Writer acceptance remains separate from overall product acceptance.
