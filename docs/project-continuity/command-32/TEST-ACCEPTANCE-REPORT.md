# COMMAND 32 — Test Acceptance Report
Checkpoint SHA: `ed93d6ad30bfe4e75199f297efda0a2b8099ce49`

## Exact-SHA workflow evidence
| Workflow | Run | Last observed state | Acceptance |
|---|---:|---|---|
| COMMAND 20-E | 44191698513 | IN PROGRESS | NOT ACCEPTED |
| Device Smoke | 44191698618 | Preparation SUCCESS; Home and Quick Capture IN PROGRESS; other lanes QUEUED | NOT ACCEPTED |
| Build / Analyze / full test shards | No run returned for this SHA at last query | NOT OBSERVED | NOT TESTED |

## Added test coverage
- All-Day false serialization assertion in Task contract tests.
- All-Day on/off widget regression restoring selected hour/minute.
- Follow-up unknown-field JSON round-trip.
- Follow-up extension payload file-backed SQLite close/reopen.
- Schema assertion for follow_ups.extension_json.
- Backup candidate restore of a historical Person ID absent from active directory while retaining unknown Follow-up metadata.

## Remaining validation
1. Flutter Analyze.
2. Full Unit and Widget test shards.
3. Debug and Release APK builds.
4. Device Smoke: Calendar, Backup/Restore, SQL Migration, SQL Persistence, Home, People, Quick Capture.
5. File-backed v7→v8 migration from actual v7 fixture, repeated open/save, idempotency and rollback.
6. Backup/Restore round trip with unknown Follow-up metadata, orphan Person IDs, active directory entries and Calendar links.
7. H01 Stage A write, verified force-stop, Stage B fresh process read, eight-value comparison and cleanup.
8. W01 authorized label event, PR/base/branch/SHA checks, KVM access check without chmod.
9. RTL, small-screen, keyboard, PDF font embedding and visual regression checks.

No assertion was weakened. No PASS is inferred from queued or in-progress runs.
