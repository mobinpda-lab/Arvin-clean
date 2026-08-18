# Arvin — Continuation Protocol

**Status:** Permanent project rule
**Purpose:** Preserve the automatic continuation workflow across chats and future AI handoffs.

## Rule: «ادامه آروین»
When the user sends only **«ادامه آروین»**, do not ask the user to copy the next command again.

The assistant must:
1. Continue from the next unfinished project stage using the latest verified repository state.
2. Execute the next safe action against the real GitHub repository when the required GitHub access is available.
3. Report the real result; never invent CI, commit, build, artifact, branch, or test results.
4. Prepare the next executable Arvin command in a compact, copyable boxed format.
5. If the user sends **«ادامه آروین»** again, continue to the next stage automatically.
6. Keep doing this until the user explicitly says **«توقف»** or changes the project direction.

## Automatic execution boundary
- Low-risk audit, documentation, verification, testing, and independent validation may proceed without a separate approval request when project rules permit.
- Sensitive architecture, migration/persistence, storage, notification engine, widget foundation/lock screen, and calendar-engine decisions require the project's DeepSeek consultation gate before implementation.
- Production changes must remain small, reversible, documented, and validated.

## Parallel / fast execution
Independent lanes should be audited or progressed in parallel where safe. Shared foundations must not be changed concurrently by conflicting paths.

## Required end-of-response status line
Every Arvin execution response must end with exactly one compact line in this form:

`GitHub:خواندن: 🟢/🔴 نوشتن: 🟢/🔴 | کل پروژه: حدود ۶۱٪ تا ۷۰٪ (بسته به معیار؛ Foundation جلوتر از قابلیت نهایی است) | UI: حدود ۶۰٪`

The percentages are estimates and must be updated when real project evidence changes them.

## Current continuation point
At the time this protocol was recorded:
- Repository: `mobinpda-lab/Arvin-clean`
- Default branch: `main`
- Restore branch: `hotfix/restore-main`
- Restore source candidate: `f6d431d42b587138f67877cd63e22297b1569f37`
- Problem commit: `52d30bb172fa78b5d9c3601c7f5a6f30ae685895`
- PR #94: Home → Unified Item Migration Gate, open/draft
- PR #98: Architecture Foundation, open/draft
- PR #102: legacy FollowUp migration compatibility regression test, open/draft
- Immediate lane: resolve Missing CI / Migration Gate before applying the controlled `lib/main.dart` restore.

## Golden principle
**«Gap واقعی را ثابت کن؛ بعد کمترین تغییر لازم را انجام بده.»**

**«قابلیت موجود را دوباره نساز؛ Foundation مشترک را دوگانه نکن؛ و هیچ نتیجه‌ای را بدون بررسی واقعی GitHub ادعا نکن.»**

**«بسم الله الرحمن الرحیم»**
