# V19 Failure Injection Report — COMMAND 49-R

**Verdict: BLOCKED — planned failure cases have not been executed.**

The current runner contains a later malformed-recurrence injection and recovery path, but the test exits during the initial migration of the non-empty Occurrence fixture. Therefore the injection code is never reached.

| Failure point | Execution | Rollback verified | Safe retry verified |
|---|---|---|---|
| Before migration starts | NOT RUN as an injected failure | NO | NO |
| After destination DDL | NOT RUN | NO | NO |
| Mid-transfer | NOT RUN | NO | NO |
| During Task rebuild | NOT RUN | NO | NO |
| During Commit | NOT RUN | NO | NO |
| Malformed recurrence payload (planned) | NOT REACHED | NO | NO |

The actual initial migration failure is:
`Occurrence migration parity mismatch for Task command49-occurrence-task`.

The historical installer contains a transaction and attempts `ROLLBACK` in its catch path, but this source-level behavior is not a substitute for a physical post-failure database inspection. No rollback success is claimed.

Evidence: run `44313646995`, job `134833931852`, artifact `14430913354`.
