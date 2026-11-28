# V19 Retry Results

**Status: NOT RUN — separate independent retry copy still required.**

COMMAND 48 confirms one real invocation of the original v19 Installer on a separate copy of the approved v7 fixture. It does not execute the Installer a second time.

- First execution: PASS, run `44308608481`.
- Second execution: NOT RUN.
- Duplicate-row analysis after a second invocation: NOT RUN.
- Idempotency verdict: NOT ESTABLISHED.

Do not infer idempotency from DDL `IF NOT EXISTS`, upsert statements or comments. A separate physical copy must receive two real invocations, then a full normalized snapshot and ID/relation comparison.
