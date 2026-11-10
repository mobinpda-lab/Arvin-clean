# Arvin — Final CI, Legacy All-Day and Review APK Checkpoint
Date: 2026-11-07
Repository: mobinpda-lab/Arvin-clean
Authorized branch: fix/recovery-calendar-device-smoke-2026-10-31
PR: #3052
Governance: OPEN / DRAFT / UNMERGED; main untouched; BLOCKED — RELEASE: NO-GO.

## Live refs and governance
- PR #3052 was re-read from GitHub after the authorized changes: state=open, draft=true, merged=false, base=main.
- Branch HEAD after this checkpoint's code/test changes: 46e84d1dd14f58ba504929f87d04fde54aa7fa27.
- The preceding tested HEAD was 60626e980540ec37ecc05fd807a1158788fe0c1c.
- PR base SHA observed: 45e4202b03a434459e4c021a04efa7e8396359db.
- Only the authorized feature branch was updated. No merge, release, publication, or main-branch edit was performed.

## CI evidence
### Superseded run set on SHA f69ef3aece1a0e15154e9f9486a714196b2ddd4f
- Build 42347818822: completed with failed test shards; not current-head acceptance.
- Calendar Provider 42347818855: SUCCESS.
- Follow-up Persistence 42347818727: SUCCESS.
- G1 Lock 42347818772: SUCCESS.
- Draft Review APK 42347818788: SUCCESS.
- Device Smoke 42347818732: Boot in progress and remaining lanes queued at inspection; no final seven-lane result. Earlier run 42346612483 was cancelled; all six device lanes were cancelled and the screenshot upload failed.

### Exact-HEAD run set on SHA 60626e980540ec37ecc05fd807a1158788fe0c1c
- Build 42350390975: FAILURE. Analyze failed because test/task_editor_full_entry_test.dart had an unused local variable at line 227. Test shards also had real failures, including duplicated RollBox keys, a Follow-up people-flow StateError, Quick Capture hit-test/overflow interactions, and Home filter geometry. Do not mark Build PASS.
- Calendar Provider 42350391008: SUCCESS.
- Follow-up file-backed SQLite Persistence 42350390984: SUCCESS.
- G1 Lock Sync 42350390974: SUCCESS.
- Draft Review APK 42350390987: SUCCESS on the exact SHA 60626e980540ec37ecc05fd807a1158788fe0c1c.
- Device Smoke 42350391002: workflow pending at last inspection; no jobs were returned yet and no seven-lane acceptance can be claimed.

## Authorized code/test corrections after the failed Build
- Commit 0957611ac0d32d818a4cfc9fb4092948bc6cc19e updates lib/widgets/arvin_roll_box.dart. Center, Project, Category and Tag selector triggers now reuse the same HomeFilterPill visual component as the five Home filters. Existing HomeFilterSheet interactions and create callbacks are retained. The duplicate child InkWell key was removed by replacing the old duplicate-keyed trigger composition.
- Commit 46e84d1dd14f58ba504929f87d04fde54aa7fa27 removes the unused reminderDate local from test/task_editor_full_entry_test.dart.
- These commits move the branch HEAD to 46e84d1dd14f58ba504929f87d04fde54aa7fa27. At checkpoint time, no workflow runs or commit status checks were yet associated with this new SHA. All results above are prior-SHA evidence and must not be transferred to the new HEAD.

## Legacy All-Day contract audit
- Task.reminderDate remains a legacy nullable timestamp and Task.reminderAllDay remains its explicit date-only flag. Task.fromJson migrates the legacy reminder into TaskReminder while carrying reminderAllDay into TaskReminder.isAllDay; midnight alone is not treated as All-Day.
- FollowUp.reminderDate remains nullable and FollowUp.reminderAllDay is independently serialized/deserialized. Missing reminderAllDay defaults to false; toJson persists true only when reminderDate exists.
- The editor paths already set midnight date identity and explicit All-Day metadata when the user selects «بدون ساعت»: Task editor uses _reminderAllDay; Follow-up editor uses _legacyReminderAllDay and preserves it on save.
- Existing focused tests include Task legacy All-Day migration/round-trip (test/task_reminder_legacy_compatibility_test.dart and test/task_editor_full_entry_test.dart), and FollowUp model plus UI All-Day round-trip (test/follow_up_reminder_model_test.dart and test/follow_up_entry_page_test.dart).
- Audit finding: the requested model-level contract is already present on SHA 60626e9. No additional model migration or destructive storage change was made. Exact-head test confirmation is still required on SHA 46e84d1.

## Review-only APK artifact — SHA 60626e9
- Draft Review run: 42350390987; artifact ID: 13565437343.
- Extracted APK: Arvin-review-staging-60626e980540ec37ecc05fd807a1158788fe0c1c.apk
- APK SHA-256: 3fa74d1a3ae08abdd3121ce49a3b032d2cd9680110b7347dd4459d5b91ef011d
- Size: 79,120,223 bytes.
- applicationId: com.example.arvin.staging; android_debuggable=false; APK signature V2 and V3 verified.
- Signing key is ephemeral and review-only. publishable=false; release_created=false.
- This APK predates the later selector commits and is therefore not the current 46e84d1 branch candidate. Do not use it as final acceptance APK. Obtain a fresh Draft Review APK on the new exact HEAD before owner/device acceptance.

## Remaining gates
1. Obtain fresh exact-SHA Build (Analyze + all six test shards + APK matrix) on 46e84d1 or later; repair all remaining failures without weakening/skipping tests.
2. Complete all seven Device Smoke lanes on the same exact candidate SHA and retain screenshot evidence.
3. Retain Calendar Provider and Follow-up Persistence SUCCESS evidence on that exact SHA.
4. Produce and hash a fresh Draft Review APK on the same exact SHA; then install/test on Samsung SM-A528B/DS and record owner acceptance.
5. Update this ledger with exact run IDs, SHA, artifact IDs, APK SHA-256 and manual device results.
6. Keep PR #3052 OPEN / DRAFT / UNMERGED; keep main unchanged; release remains BLOCKED — RELEASE: NO-GO until manual acceptance and all gates pass on one SHA.
