# Arvin parallel execution checkpoint — 2026-11-07



## Parallel execution checkpoint — 2026-11-07 — source 6fa57ce

- Source fix: removed the unused `_dateRollBox` declaration from `lib/task_editor_dialog.dart`; source commit `6fa57ce5231f73d67304bed46263a02af1e1cb90`, exact message: `fix(analyzer): remove unused _dateRollBox in task_editor_dialog`. No tests were changed, deleted, skipped, or weakened by this source commit.
- Exact-SHA GitHub Actions run: `42406373769`; Analyze job `128504856906` completed **SUCCESS**. The Flutter Analyze step itself is **SUCCESS**. This confirms the prior unused-element warning is resolved on source SHA `6fa57ce5231f73d67304bed46263a02af1e1cb90`.
- Test shards are independent. At this checkpoint, Shard 1 job `128504856909` is still `IN_PROGRESS`; Shard 2 is `IN_PROGRESS`; Shard 3 and Shard 4 have completed with `FAILURE`; Shard 5 test step has failed while its job is still finishing. Do not treat the earlier completed Shard 1 run as current-SHA acceptance evidence.
- Latest completed Shard 1 evidence available at checkpoint: run `42405042863`, job `128500803200`, source SHA `44f4dfbbb3db846765d4ea2e67dffa263aa4cac2`; result **173 passed / 14 failed**. Analyze in that shard was skipped by workflow design; the dedicated Analyze job is the authoritative check.
- Previous Shard 1 failures, exact test titles and failure messages:
  1. `test/task_detail_followup_flow_test.dart:151` — `inline description edit updates updatedAt and preserves completion and Follow-up history`: expected `DateTime(2026-11-02 12:00:00)`, actual `null`.
  2. `test/integration_task_reminders_migration_backup_test.dart:36` — `deleted migrated legacy reminder does not return after SQL and backup restore`: expected ID `legacy-task-reminder-task-reminder-integration`, actual ID `legacy-task-reminder-deleted-legacy-reminder`.
  3. `test/widgets/home_page_test.dart:193,198,200` — `Home uses the five checkbox filters as combined filters and preserves time grouping`: horizontal `RenderFlex overflowed by 158 pixels on the right`; interaction assertions failed.
  4. `test/services/task_migration_writer_test.dart:122` — `Home snapshot deletes omitted items and serializes new items canonically`: expected `true`, actual `null`.
  5. `test/services/home_today_projection_test.dart:55` — `legacy scheduling fields alone never create a Home FollowUp entry`: expected `DateTime(2026-08-27 08:00:00)`, actual `null`.
  6. `test/services/g1_drift_schema_test.dart:132` — `materializes multiple Task reminders, historical Follow-ups and Persons canonically`: SQLite error `Invalid argument (parameters): Expected 3 parameters, got 2`.
  7. `test/services/calendar_inbound_sync_service_test.dart:54` — `retired inbound reconciliation never mutates native Task ownership`: expected ID set containing `legacy-task-reminder`, actual contains `legacy-task-reminder-task-1` instead.
  8. `test/follow_up_repository_test.dart:48` — `appends a FollowUp while preserving the task envelope`: expected `DateTime(2026-08-14 09:30:00)`, actual `null`.
  9. `test/task_editor_dialog_test.dart:220` — `Task editor saves a new follow-up record with separate title and note`: expected `false`, actual `true`.
  10. `test/task_detail_metadata_selector_test.dart:42,45,48` — `Task Details category and tags use shared filter selectors`: expected category `شخصی`, actual `کاری`; also horizontal overflow by 158px.
  11. `test/follow_up_reminder_projection_test.dart:51` — `only independent TaskReminder records enter the projection`: expected collection length 1, actual length 2.
  12. `test/reusable_multi_select_filter_bottom_sheet_test.dart:50,53` — `multi-select sheet persists inline-created option and auto-selects it`: expected set `['new-شخصی', 'work']`, actual `null`; also horizontal overflow by 158px.
  13. `test/report_center_page_test.dart:246,253,256` — `Report Center shows separate person-specific active waiting rows`: expected text `نتیجه: 1 پیگیری` not found; also horizontal overflow by 158px.
  14. `test/task_edit_apply_service_test.dart:100` — `metadata edits preserve completion timestamp without future follow-up schedule`: expected `true`, actual `false`.
- Initial root-cause grouping (diagnostic hypotheses, not yet proven): (a) 158px horizontal overflow and resulting unreachable controls in shared filter/UI layout; (b) null/mismatched timestamp or snapshot values in Task/Follow-up editing and projection; (c) legacy reminder identity/migration normalization mismatch; (d) Drift insert SQL placeholder/bind count mismatch; (e) multi-select inline-created value not persisted/selected; (f) report projection missing the expected person-specific row. Fix production behavior and retain all regression tests; do not weaken assertions to match defects.
- Universal filter contract: `ReusableMultiSelectFilterBottomSheet`; checkbox multi-select; OR within a dimension and AND across dimensions; inline creation auto-selects the new value; active-selection count badges; dimensions Time, Center, Project, Category and Tag where applicable.
- Typography contract: **Vazirmatn**. Default accent color: **#3A86EF** (palette option 8); do not confuse this dynamic accent with legacy semantic teal tokens.
- Governance: PR #3052 remains **OPEN / DRAFT / UNMERGED**; `main` remains `45e4202b03a434459e4c021a04efa7e8396359db`; release remains **BLOCKED — RELEASE: NO-GO**. No merge, publication or release.
- Documentation synchronization itself changes the branch SHA; all exact-SHA acceptance gates must be checked again on the resulting documentation commit. Current physical Samsung SM-A528B/DS Device Smoke is not claimed as passed.
