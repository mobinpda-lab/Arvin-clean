# V7 → V19 Compatibility Report

<pre>
SOURCE_COMPATIBILITY: PASS
DIRECT_INSTALLER_EXECUTION: PASS
FIXTURE_SHA256: VERIFIED
PRE_USER_VERSION: 7
POST_USER_VERSION: 19
POST_INTEGRITY_CHECK: ok
POST_FOREIGN_KEY_VIOLATIONS: 0
TASK_IDS: PRESERVED
CANONICAL_RELATIONS: VERIFIED
V20_EXECUTED: NO
</pre>

## Decision

**Path A — direct invocation of the original v19 installer on a physically independent v7 fixture copy — is confirmed for the approved Main v7 fixture.**

The exact v19 source ref was checked out, the installer blob SHA was asserted, historical dependencies were resolved with the lockfile enforced, and the original `G1DriftSchema.install` entry point executed. The physical database changed from SQLite `user_version=7` to `user_version=19` through the historical Drift open/install path.

The corrected runner additionally verifies:
- all Task IDs and core SQL-owned Task values;
- retained legacy source rows and their IDs;
- Project, Follow-up, Person and Tag identities;
- Checklist, Task-Tag, Project-Task, Task-Person and Follow-up-Person relationships;
- canonical Follow-up/Person relationship tables;
- materialized Task Reminder and Recurrence rows;
- selected unknown Task, Project, Person and Recurrence payload values;
- post-install SQLite integrity and foreign-key checks.

The fixture's source copy remains unchanged. Only the separately copied working database was migrated.

## Scope limitation

This establishes that the historical v19 installer can execute against this exact Main v7 fixture and that the asserted fixture data/relations survive. It does not certify every production database, custom index/trigger/constraint variation, or every possible unknown nested payload shape. Command 47's separate retry and failure-recovery acceptance gates remain outstanding.

## Residual observation

The installer-generated legacy JSON envelope can contain default values that differ from SQL-owned Task fields. The historical v19 TaskStore explicitly overwrites those fields from SQL before decoding. This is recorded as a compatibility contract in `V19_EXECUTION_EXCEPTION_LEDGER.md`, not misreported as a failed SQL-row preservation check.
