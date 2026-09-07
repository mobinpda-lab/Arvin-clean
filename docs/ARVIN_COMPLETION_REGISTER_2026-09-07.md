# Arvin-clean — Permanent Completion Register

Date: 2026-09-07
Baseline HEAD: `123b2f1f82638659754ec8e575dea09ef2312d0c`

## Purpose
This register prevents product capabilities, acceptance requirements, and roadmap ideas from being forgotten. It is a checklist, not a replacement for the canonical operating package. GitHub reality always wins.

## Project boundary
This register belongs ONLY to `mobinpda-lab/Arvin-clean`. No code, product scope, issue, storage, business rule, or dependency may be imported from YadNegar, NetworkCenterMonitor/Payesh, Arvin Factory, or any other project. Transferable engineering patterns may be independently reimplemented only after project-specific audit.

## Priority order
### P0 — Release/blocker closure
- [ ] Reconcile current main against all product contracts and scorecard gates.
- [ ] Complete the current exact-head CI/build/device/security/release validation chain.
- [ ] Close any failure that is reproduced on the current HEAD; ignore stale failures from superseded HEADs unless they reproduce.
- [ ] Prove APK installability and required real-device behavior before release claims.
- [ ] Verify backup/restore recovery and data-safety behavior before production readiness.

### P1 — Core product completion
- [ ] Unified Item/Task + Reminder + FollowUps[] + History remains one canonical foundation.
- [ ] Timeline complete user-facing path over existing History foundation.
- [ ] Next Action, explicitly distinct from Reminder, integrated without a second model/store.
- [ ] Automatic FollowUp integrated with the existing FollowUp/Reminder chain.
- [ ] Quick Capture/Quick Add completed as one input path.
- [ ] Waiting-for-response state completed with stable identity/history behavior.
- [ ] Persian semantic search remains on the existing SearchService; no second search stack.
- [ ] People/Contacts relationship contract implemented only if current audit confirms it is still missing.
- [ ] Privacy/encryption: authenticated, versioned backup envelope over canonical portable bytes; legacy plaintext compatibility; tamper failure before mutation; recoverable cross-device key/passphrase design.
- [ ] Backup/Restore, SAF and cloud/Dropbox continue to share one canonical byte path.
- [ ] Widget and Lock Screen foundations and reminder actions receive required real-device/E2E evidence.
- [ ] Calendar foundation: verify remaining real gaps, including official Iran prayer-time/holiday providers only if still in the approved scope.

### P2 — Product extensions after P0/P1 blockers
- [ ] Voice Capture Persian → existing parser → canonical Item/Reminder/FollowUp.
- [ ] Smart Calendar Assistant.
- [ ] Conflict detection and smart rescheduling.
- [ ] Weekly Review.
- [ ] Smart assistant and Memory using official project data only; no AI source-of-truth database.
- [ ] Goal → Project → Item contract and implementation if approved by current architecture audit.
- [ ] Personal Assistant for Iran-specific calendar/RTL/voice/assistant capabilities.

### P3 — Optional extensions
- [ ] Location-based Reminder on existing Reminder trigger layer, only after product need is proven.
- [ ] Other queued ideas only after reconciliation with current main, roadmap, architecture, security and acceptance criteria.

## Cross-cutting acceptance gate
Every item is COMPLETE only when applicable implementation + automated tests + regression/E2E + RTL/Persian/Jalali validation + CI + APK/device evidence + security/recovery impact + documentation + exact-head evidence exist.

## Idea queue rule
Roadmap/idea items are not automatically implementation work. At every completion/reconciliation cycle classify each candidate as DUPLICATE, COMPATIBLE_NOW, COMPATIBLE_LATER, or DECISION_REQUIRED. Never rebuild an already-implemented feature. Never let ideas displace a real release blocker without a dependency/value reason.

## Permanent anti-forgetting rule
Before declaring Arvin complete, re-run this register against current `main`, the canonical operating package, product contract/scorecard, roadmap, open issues/PRs, implementation, workflows, build/device evidence, security, backup/restore and release evidence. Any unchecked applicable item is either completed, explicitly deferred with reason, or an active blocker; it must not silently disappear.
