# V7 → V19 Compatibility Report

**Source-level decision: DIRECT INSTALLATION PATH IS SUPPORTED BY THE HISTORICAL CODE SHAPE.**  
**Physical execution decision: PENDING RUNNER RESULT.**

The v19 installer contains explicit compatibility logic for pre-canonical Task columns and pre-v12 Follow-up/People/Task-person tables. Its target DDL is additive for the legacy v7 tables, and its conversion methods query the exact legacy table and column names present in the v7 DDL. The historical v19 tests include legacy Task, Follow-up, Person, Task-person, reminder, recurrence and occurrence migration cases.

The v7 fixture inventory confirms the required legacy tables and the expected schema-v7 baseline. Therefore Path A (direct invocation of the original v19 installer on an isolated physical v7 copy) is the valid next experiment. There is no source-level reason to invent or execute intermediate schema versions for this specific installer call.

This is **not yet an INCOMPATIBLE result**, and it is not a completed migration proof. Preconditions that depend on actual fixture row values, custom SQLite objects, strict Task-person JSON validation, recurrence decoding, and real physical execution must be checked by the dedicated runner. Any thrown exception or FK/integrity failure changes the result to BLOCKED and must be preserved without patching the historical installer.

No v20 execution is permitted.
