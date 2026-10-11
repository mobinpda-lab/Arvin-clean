# Arvin User Experience Log

## 2026-10-09 — Calendar task actions reported missing
- Date: 2026-10-09 (conversation date; exact report time not established here)
- Context: User installed/used an Arvin build and inspected the Calendar task view.
- User Feedback: «در تقویم کارهای آروین دکمه ثبت در تقویم گوشی و دکمه ویرایش حذف شده است»
- Problem: The user reported that “add/register in phone calendar” and “edit” actions were missing from the Arvin Calendar task UI.
- Solution: No verified fix is recorded in this entry. Recheck live issues/PRs and test the actual UI before claiming resolution.
- Status: UNVERIFIED / acceptance evidence required.

## 2026-10-11 — Backup/restore acceptance boundary
- Date: 2026-10-11
- Context: Release-readiness and autonomous execution planning.
- User Feedback: The owner requires real installation/device experience to be retained and treated as product evidence.
- Problem: Emulator smoke cannot prove actual Android file-picker/provider behavior or physical-device data integrity.
- Solution: Require a documented physical-device export/restore round-trip and record device/OS, steps, backup artifact or screenshots/logs, and before/after data checks.
- Status: BLOCKED pending physical-device evidence.

## 2026-10-11 — Repeat Tracking Level owner contract
- Context: Owner supplied RTLC to strengthen important recurring commitments without introducing separate loan/debt/habit/payment/contract/customer-follow-up systems.
- Product expectation: Task form places «نوع پیگیری» after Repeat; «عادی» is the default and «مهم و قابل پیگیری» reveals advanced information progressively. Home uses only a restrained «تعهد مهم» / action-needed cue. Report Center offers «همه»، «عادی»، «مهم و قابل پیگیری» filters and accurate tracking metrics.
- Data expectation: existing Task identity, Repeat, occurrence history, per-occurrence checklist state, and backup/restore remain safe; past history immutable and future settings adjustable.
- Implementation status: decision recorded in [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605); first-pass source audit found model/persistence foundations already exist. Main-form/Home/report integration and end-to-end evidence remain pending. No UI screenshot or physical-device result was produced by this audit.




## 2026-10-11 — Owner installed-product feedback
- Environment: installed Android app (version/device not supplied in this report).
- Feedback: recurring Tasks fail to generate the promised 7 occurrences; recurrence activation should automatically fill today's date and current time but allow edits; automatic Calendar sync still has problems after changing a Task.
- Action: opened Draft PR #2606 for safe recurrence-editor defaults and regression coverage; recorded Calendar recurrence identity/projection defect in existing architecture issue #2248.
- Device reproduction/result: not yet captured in this session. Do not mark the user-facing defect resolved until exact-head CI and appropriate Android Calendar Provider validation are complete.
