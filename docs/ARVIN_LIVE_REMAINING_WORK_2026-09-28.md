# Arvin — Live Remaining Work & Cross-Conversation Continuity Ledger
**Audit date:** 2026-09-28  
**Time basis:** Iran time  
**Repository:** `mobinpda-lab/Arvin-clean`

> This file is the persistent continuity ledger for the `ادامه آروین` execution trigger. GitHub reality outranks chat memory and historical reports.

## 1. Live baseline
- Current `main`: `fcfe53bd16adb87a94e47a0f26240a99ddb9e989`
- Strategy: **PRODUCT FIRST + FACTORY MINIMAL**
- Direct changes to `main`: prohibited.
- Product changes must use Issue + Branch + PR.
- No parallel Storage / Model / Repository / Settings / Scheduler / Calendar engine.
- Preserve real user data.
- Architecture / Storage / Migration high-risk decisions require independent DeepSeek architecture review before irreversible changes.
- A feature is not complete merely because code exists: exact-head CI evidence is required, and UX/product acceptance also requires real-device evidence where specified.

## 2. Verified current state
- PR #1902 custom recurrence was **merged** on 2026-09-28. Its implementation head was `96acb2bd0dfc9e30ff79fef17a6fa14d82e20a8d`.
- Current `main` contains the custom recurrence interval implementation in Quick Add and Task Edit and recurrence tests.
- PR #1901 remains **OPEN** at `964a55c46c92627c4e218bb816abda6b571e26da`.
- #1901 received a narrow-RTL Task Editor overflow fix; at audit time its new exact-head Device Smoke was still running and Build was queued.
- Current-main Release Closure run `36445968668` for `fcfe53bd...` was **in progress** at audit time.
- For current `main`, Production Orchestrator, Production Loop, Autonomous Task Queue and AI Code Worker had successful runs recorded at audit time.
- Physical-phone acceptance of the complete P0/P1 list is **unknown** until explicitly recorded.

## 3. Remaining product work — P0/P1

### 3.1 Calendar / device calendar
- Restore/verify the expected calendar actions:
  - «ویرایش کارهای آروین»
  - «ثبت کارهای آروین در تقویم پیش‌فرض گوشی»
- Add/verify Settings → «تقویم و همگام‌سازی» with automatic registration/sync of Arvin tasks to the selected/default device calendar.
- Continue from #516/#348 and existing `AppSettingsService`, `SystemCalendarBridge`, calendar-sync foundations.
- No parallel calendar engine/store/settings storage.
- Real Android provider evidence is required; emulator alone is insufficient.

### 3.2 Home
- Match the latest owner-approved Home reference.
- Four grouping controls must remain:
  - زمان
  - پروژه‌ها
  - دسته‌ها
  - برچسب‌ها
- Labels and icons must not clip at normal or larger font sizes.
- Contextual filters:
  - Projects → Project + Category
  - Categories → Category
  - Tags → Project + Category + Tag
- Filters must combine and update without reopening the page.
- Task cards must support multiline content without unwanted clipping/ellipsis.
- Semantic colors, iconography and state indication must follow the product color contract.
- Final visual acceptance must be performed on the real phone.

### 3.3 Typography / Appearance
- Real font picker in Settings with preview.
- Real app-wide font-size control.
- VazirHarf v34.003 remains the default/canonical font.
- Any additional bundled font must have verified source/license evidence.
- Never expose a font as selectable when it is not actually bundled/available.
- Use canonical `AppSettingsService`; no parallel settings store.
- Larger/smaller text must not shrink cards into clipping.

### 3.4 Project / Category / Tag management
- Central Settings management for Project / Category / Tag.
- Category and Tag creation must exist.
- Newly created items must appear immediately in Roll Box selectors.
- Creating an item and selecting it for the current Task are independent operations.
- A newly created Category must not disappear merely because it was not selected on the current Task.
- Task and Notebook must consume the same canonical taxonomy.
- Existing relationships must survive reload/persistence.

### 3.5 Notebook / دفترچه
- دفترچه remains a separate Arvin section.
- Checklist is **not** a separate tab/page/list.
- Notebook editor bottom row has three independent inline tools:
  1. شماره خودکار
  2. تیک
  3. چک‌لیست
- Each toggles on/off with one tap; enabled formatting continues from the cursor point; turning it off returns subsequent text to normal text.
- Preserve editing, Undo/Redo, autosave and reopen.
- Project / Category / Tag are exactly the canonical Task taxonomy.
- Notebook list filters by Project / Category / Tag and supports combination.
- Project / Category / Tag selectors should open as the contracted Roll Box UI in-place.
- Notebook Tag selection must work.
- No parallel Notebook storage/model/repository.
- Removing standalone Checklist/Shopping/Travel UI is allowed only after dependency audit and without deleting user data.

### 3.6 Quick Add / Task Edit
- Date + Time are on one row wherever both exist.
- Quick Add Due Date/Time must not open a blank page.
- Quick Add Reminder Date/Time must not open a blank page.
- RTL/Persian date/time entry and display.
- Project / Category / Tag use colored/icon Roll Boxes with existing values and «ایجاد جدید» as the final option.
- Newly created taxonomy values appear immediately.
- Repeat + Priority share one row in Task Edit.
- Custom recurrence day/week intervals are now present in `main`; exact-head/device acceptance still needs evidence.
- Completed ↔ Undone behavior and Done/All filters must match the product contract.

## 4. Acceptance / Release gates
For the final product lane:
1. Analyze
2. Full Test
3. Debug Build
4. Release Build
5. Device Smoke on the exact HEAD
6. Install the same exact-HEAD APK on the real phone
7. Repeat the owner acceptance checklist for Home, Calendar, Quick Add, Reminder, Typography, Taxonomy, Notebook and Swipe.
8. Record evidence against the exact SHA.
9. Do not call a requirement fixed when its evidence is missing; status remains **نامشخص** or **در حال انجام**.

## 5. Duplicate-lane control
The current regression lane is #1901. #1902 is merged and must not be reimplemented.
Older open PRs in this domain must be compared with current `main` before any reuse/merge/closure decision:
- #1892
- #1885
- #1847
- #1844
- other old UI/docs PRs only after diff/goal verification.

## 6. Binding issues
- #1901 — real-device regression closure
- #1911 — binding Notebook/Home filter product contract
- #1912 — Home screenshot/reference contract
- #1891 — Quick Add / taxonomy / scheduling / swipe / semantic color
- #1860 — typography / font size
- #1861 — canonical taxonomy management
- #1862 — Swipe + Notebook taxonomy
- #850 — Notebook UX
- #516 / #348 — device calendar integration
- #852 — grouped Settings / fonts / backup foundation

## 7. Cross-conversation/account continuation rule
When the user sends **«ادامه آروین»** from a new conversation or account:
1. Read this file.
2. Read Issue #1923 and the binding issues above.
3. Read the current `main` SHA and open PR list.
4. Re-check exact-head CI; never reuse stale CI.
5. Select the highest-priority unfinished lane.
6. Continue on a controlled Issue + Branch + PR.
7. Update this ledger whenever a requirement changes state.
8. Use **نامشخص** when evidence is absent.
9. Never create a second implementation of an existing canonical feature.
10. Product completion is the goal; factory automation is only the means.

## 8. Current audit conclusion
- Overall Product/Release-Ready status: **نامشخص — not yet proven Release-Ready**.
- #1902 custom recurrence: **merged; real-device acceptance still requires evidence**.
- #1901: **open; P0/P1 work remains as listed above**.
- Current-main Release Closure: **in progress at audit time**.
- Complete physical-phone acceptance of the P0/P1 list: **نامشخص**.
