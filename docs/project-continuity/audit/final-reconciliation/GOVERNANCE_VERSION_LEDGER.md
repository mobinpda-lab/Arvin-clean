# GOVERNANCE VERSION LEDGER
Snapshot: 2026-11-27 | Authority: latest explicit Product Owner directive

| Revision / source | Disposition | Binding interpretation |
|---|---|---|
| REV7 / REV7.1 | HISTORICAL | Preserve records; not current authority. |
| REV8 | HISTORICAL | Preserve records; not current authority. |
| REV9 | SUPERSEDED | Preserve archive; conflicts resolve in favor of REV10 and later owner decisions. |
| REV10 | CANONICAL GOVERNANCE | Current governance baseline. |
| REV12.00 | HISTORICAL | Mission checkpoint only. |
| REV12.01 | HISTORICAL | Mission checkpoint only. |
| REV12.21 | SUPERSEDED | Not current execution authority. |
| REV12.25 | HISTORICAL MISSION | Not the current execution command. |
| COMMAND 103-R | OWNER GOVERNANCE ADDENDUM | Retain as an approved governance addendum to REV10. |
| ARVIN-FINAL-UNIFICATION-2026-11-27 | CURRENT OWNER DIRECTIVE | Newest explicit mission scope and product contracts; supersedes conflicting older instructions. |

## Owner-locked product decisions confirmed in current source
- Primary Blue: #4169A1; ArvinColors.primary is the canonical token. Teal #078B91 is not the Primary.
- Official UI font: Vazirmatn. APK contains local Regular 400, Medium 500 and Bold 700 assets; source pubspec declares these three weights. The broader owner target weights 300/400/500/600/700 require separate implementation audit.
- Home filter dimensions and order: Time → Center → Project → Category → Tag. OR within a dimension; AND between dimensions.
- Center↔Project and Project↔Category are M2M; Task direct links to Center/Project/Category are independently optional; Task↔Tag is M2M.
- Reminder is separate from Task due date and historical Follow-up.
- Main is read-only. PR #3495 is the sole authorized development route. Keep Draft/unmerged until explicit owner approval.
- Historical releases/tags and branch/PR history must be preserved.

## Schema authority
The current owner directive sets v7→v9 as the target path. Historical v19/v20 work is evidence only and must not be blindly imported. The source on PR #3495 declares schema version 9, but its hierarchy migration declares source version 8 and target 9; the v7→v8 step is currently implicit in additive installer DDL and is not a separately versioned migration ledger. This is a P0 audit finding, not an acceptance.

## Governance status
REV10 is retained; no conflicting historic charter is deleted. The eight continuity documents remain active authority. The 15-file final reconciliation ledger is supporting audit evidence and does not supersede the eight documents.