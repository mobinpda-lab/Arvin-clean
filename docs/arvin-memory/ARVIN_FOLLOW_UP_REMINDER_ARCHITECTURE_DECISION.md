# ARVIN Follow-up & Reminder Architecture Decision — Version 2.0

Date: 2026-10-13  
Status: **OWNER-SUPPLIED PRODUCT / ARCHITECTURE DECISION**  
Repository: `mobinpda-lab/Arvin-clean`

This document records the owner's Version 2.0 command. It is the decision reference for follow-up/reminder work. Where an older note conflicts with this decision, this document is the newer owner instruction; historical notes remain for audit. Implementation and validation status must still be reported separately.

## 1. Canonical ownership

- `Task` remains the single source of truth.
- Follow-up, action plan, reminder, notification, Calendar, search, and reports are Task-owned behavior or projections—not parallel task systems, stores, databases, or schedulers.
- Preserve existing Task identity, follow-up history, legacy JSON fields, backup/restore compatibility, and stable Calendar event identity.
- Improve existing foundations; do not create duplicate models or infrastructure.

## 2. Definitions and data contract

### Follow-up / next action

Follow-up answers: **“When should I return to this subject or take the next action?”**

- `nextFollowUp` is the time/date of the next action or review.
- Follow-up title and result/notes belong to the follow-up action/history path where applicable.
- Follow-up may exist without any Reminder.
- Never delete, clear, or replace `nextFollowUp` merely to simplify UI or because a Reminder is absent.

### Reminder / notification

Reminder answers: **“What should Arvin notify me about, and when?”**

- `reminderDate` is a reminder schedule, not a synonym for `nextFollowUp`.
- A Reminder may exist without a Follow-up.
- One Task can own multiple independent reminders. Each reminder has a stable ID, editable title and schedule, explicit all-day/date-only metadata, and independent edit/remove behavior.
- Preserve legacy singular `Task.reminderDate` and `FollowUp.reminderDate` during compatibility work. Do not silently clear, migrate, or duplicate legacy values.
- Never infer all-day from a midnight timestamp.

## 3. Independence invariants

- Changing or deleting `nextFollowUp` does not move, edit, or delete any existing Reminder.
- Changing or deleting a Reminder does not move, edit, or delete `nextFollowUp`, Follow-up history, or another Reminder.
- Setting `nextFollowUp` alone does **not** create a Reminder.
- If the user explicitly chooses **Add Reminder** from a follow-up flow, the Task title and selected next-action date/time may be used as editable initial values. These are one-time defaults, not a live binding.
- If the user requests changing all related reminders, that must be an explicit user choice with clearly scoped confirmation; no silent cascade.

## 4. Full Task form

- Keep the **«کار پیگیری‌دار»** toggle.
- Remove the obsolete **«زمان پیگیری»** field when it is merely an automatically generated system timestamp.
- Do not invent a timestamp when follow-up is enabled.
- Follow-up history/action entry remains an explicit flow, not a hidden side effect of toggling the Task.
- Keep the existing independent Reminder controls; the full form must support multiple reminders through a dedicated **«یادآورها»** section and **«+ افزودن یادآور»**.
- Checklist remains Task-owned and independent of follow-up/reminder state.

## 5. Follow-up creation flow

The intended user path is:

`Task → Add Follow-up → Save Follow-up`

The entry flow may include:
- Follow-up title (optional)
- Result / notes
- `nextFollowUp`
- Optional explicit **«افزودن یادآور»** action

The optional Reminder is an independent record. Editing or deleting it must not rewrite the follow-up action or history.

## 6. Quick Entry and progressive disclosure

- Quick Entry must remain compact and fast.
- Provide separate **«پیگیری‌دار»** and **«چک‌لیست‌دار»** options near the primary controls.
- Prefer a compact layout grouping Date, Time, Repeat and Reminder on one row; Follow-up, Checklist and secondary options on another, adapting responsively when needed.
- Enabling Follow-up reveals its roll box; enabling Checklist reveals its roll box. Keep details hidden until requested (progressive disclosure).
- These toggles must not auto-generate timestamps, reminders, checklist entries, or duplicate Tasks.
- Quick Entry and Full Task Form create/edit the same canonical Task.

## 7. Calendar projection — clarification gate

The owner's v2 command says: if a Reminder exists, show the Reminder; otherwise show `nextFollowUp`, and every Reminder must link to its parent Task.

**Important scope conflict to resolve before changing phone-calendar synchronization:** earlier approved architecture says a Follow-up alone must not be projected to the phone calendar or generate an OS notification. Version 2.0 says “Calendar” but does not explicitly distinguish Arvin's in-app calendar from the Android/phone calendar. Therefore:
- Preserve existing stable Task/Event IDs and CREATE → UPDATE EXISTING behavior.
- Every projected Reminder must resolve back to its parent Task.
- Do not add `nextFollowUp` to the phone Calendar or schedule an OS notification from it until the owner confirms that Version 2.0 intends to supersede that earlier phone-calendar boundary.
- In-app Calendar presentation may be updated only with tests that keep Follow-up and Reminder visibly distinct and do not create duplicate events.

This is a narrow clarification gate, not permission to conflate the two concepts.

## 8. Reports and search

Reports and search must distinguish, filter, and label these dimensions separately wherever supported:
- Follow-up enabled / follow-up history
- `nextFollowUp`
- Reminder existence/status
- `reminderDate` / reminder schedule

Do not report Reminder counts as Follow-up counts, or infer one from the other. Report and search remain read-only projections of canonical Task data.

## 9. Data safety and migration

Before any database, JSON-contract, or persistence migration:
1. Audit current reads/writes of both fields and all dependent projections.
2. Verify backup availability and preserve legacy payloads.
3. Document a migration plan and explicit rollback plan.
4. Add compatibility tests before changing serialization.
5. Validate JSON round-trip, SQL save/reload, backup/restore, notification rescheduling/cancellation, and Calendar identity/no-duplicate behavior.
6. Do not ship a migration if rollback or preservation of legacy values is unproven.

Prefer additive, backward-compatible Task JSON changes through the existing Task SQL envelope and backup/restore pipeline. No parallel store or scheduler.

## 10. Acceptance checklist

- [ ] Follow-up and Reminder are independent in model, UI, notifications, Calendar and reports.
- [ ] `nextFollowUp` is preserved and never substituted by `reminderDate`.
- [ ] No auto-generated follow-up timestamp remains in the full Task form.
- [ ] Full form retains the Follow-up toggle and supports multiple independent reminders.
- [ ] Quick Entry exposes compact Follow-up and Checklist toggles.
- [ ] Follow-up and Checklist roll boxes open only when enabled.
- [ ] Optional Reminder creation is explicit and independently editable.
- [ ] Reminder edit/delete cannot mutate other reminders, follow-up history or `nextFollowUp`.
- [ ] All-day/date-only and intentional midnight remain distinct.
- [ ] Calendar Reminder links resolve to the parent Task and updates do not duplicate events.
- [ ] Reports/search separate Follow-up, `nextFollowUp`, Reminder and `reminderDate`.
- [ ] Legacy JSON, SQL persistence, backup/restore and migration/rollback tests pass.
- [ ] Exact-head Analyze, all test shards, Debug/Release APK, Calendar Provider Acceptance, six Device Smoke lanes and required physical-device checks are evidenced.

## 11. Related decisions and tracking

- Multiple independent Task reminders design: `docs/arvin-memory/ARVIN_MULTIPLE_REMINDERS_DESIGN.md` on the feature branch for PR #2655.
- Multiple reminder requirement: Issue #2654.
- Follow-up-level independent Reminder work: Issue #372.
- The current main implementation already has separate nullable `nextFollowUp` and `reminderDate` fields and compact Quick Entry Follow-up/Checklist controls in the inspected source. This source inspection alone does not prove the complete acceptance checklist.
- Release remains **NO-GO** until exact-head and physical-device evidence is complete.
