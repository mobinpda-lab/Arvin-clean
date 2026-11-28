# V19 Idempotency Report — COMMAND 49-R

**Verdict: BLOCKED — idempotency not yet proven.**

## Source identity
- Historical installer checkout: `310c0e20e3447c488c1e1c102c38bea5040708ca`
- Installer blob: `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`
- The workflow verified both identities before execution. The historical installer and codecs were not edited.

## Observed execution
The first installation attempt on the isolated V7 copy reaches `OccurrenceSqlCodec.migrateLegacyEnvelopes` and throws:

`Bad state: Occurrence migration parity mismatch for Task command49-occurrence-task`

Run `44313646995`, job `134833931852`, artifact `14430913354`.

Because the first installation does not complete, the second invocation of the same installer has not been reached. No conclusion about idempotency, duplicate prevention, identifier stability, or second-run snapshot equality can be drawn.

## Required next proof
Resolve the observed parity failure without modifying the historical installer, then run the exact same installer twice on the same independent database and compare full snapshots, SQL values, IDs, relations, and TaskStore readback.
