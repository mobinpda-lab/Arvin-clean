# Bidirectional Device Calendar Integration

## تصمیم رسمی

آروین باید با تقویم‌های موجود روی Android، شامل Google Calendar، Samsung Calendar و سایر Providerهای سازگار، از مسیر استاندارد Android Calendar Provider یکپارچه شود.

معماری هدف:

`Arvin ↔ Android Calendar Provider ↔ Google / Samsung / Other compatible calendars`

این سند Foundation جدیدی ایجاد نمی‌کند؛ existing Settings، Calendar، Work Agenda، sync planning، SystemCalendarBridge و canonical Task/Reminder/FollowUp foundations باید reuse شوند.

## مسیر تنظیمات

تنها مسیر رسمی:

`آروین → تنظیمات → تقویم و همگام‌سازی`

Calendar و Work Agenda فقط می‌توانند Shortcut به همین Settings داشته باشند و Settings Store یا Settings Architecture دوم ساخته نمی‌شود.

## Phase 1 — Settings contract

PR #519 روی production main merge شده و قرارداد device-calendar settings را به existing `AppSettings` / `AppSettingsService` اضافه کرده است.

تنظیمات هدف شامل:
- اتصال کلی به تقویم دستگاه
- نمایش eventهای تقویم گوشی
- انتخاب Calendarهای قابل نمایش
- ارسال eventهای انتخاب‌شده آروین به Calendar مقصد
- انتخاب kindهای due/reminder/follow-up/follow-up-reminder/recurrence
- auto sync
- delete linked external event with Task، پیش‌فرض خاموش
- device calendar ids و target calendar id به‌صورت local-only

Device-specific calendar ids عمداً وارد portable Settings backup نمی‌شوند و portable restore باید تنظیمات محلی Calendar را حفظ کند.

## Arvin → Device Calendar

موارد قابل projection طبق تنظیم کاربر:
- Task due date
- Task reminder
- FollowUp schedule
- FollowUp reminder
- recurrence occurrence در صورت تکمیل contract مربوطه

Create/update باید idempotent باشد. Mapping پایدار مفهوم زیر را حفظ می‌کند:

`ArvinEntityId ↔ ExternalCalendarEventId`

Refresh یا Sync مجدد نباید Duplicate بسازد.

## Device Calendar → Arvin

Calendarهای مجاز باید قابل discovery/read باشند. External event در فاز اولیه Task آروین نیست و خودکار به Task تبدیل نمی‌شود.

External projection باید source ownership را حفظ کند و در Calendar/Work Agenda موجود نمایش داده شود. Import به canonical Task فقط با اقدام صریح کاربر مجاز است.

## مالکیت داده

- **Arvin-owned:** Source of Truth آروین است.
- **External-owned:** Source of Truth Calendar Provider است؛ فاز اول read-only.
- **Imported-to-Arvin:** فقط با اقدام صریح کاربر canonical Task ساخته می‌شود.

ویرایش/حذف External-owned بدون اقدام روشن کاربر ممنوع است.

## Work Agenda

Work Agenda موجود Foundation aggregation باقی می‌ماند:

`Work Agenda = canonical Arvin work events + External Calendar Events`

Work Agenda دوم ساخته نمی‌شود و source هر ردیف باید مشخص بماند.

## Google و Samsung

Google و Samsung در Phase اول Engine اختصاصی ندارند. هر Calendar که Android Calendar Provider expose می‌کند از adapter واحد استفاده می‌شود.

Google OAuth/API مستقیم یا Samsung API اختصاصی فقط اگر Requirement بعدی واقعاً به آن نیاز داشته باشد بررسی می‌شود.

## Permission و Privacy

- Read permission فقط هنگام فعال‌کردن مشاهده external events.
- Write permission فقط هنگام فعال‌کردن write/update.
- Deny نباید عملکرد عادی آروین را مختل کند.
- متن واقعی eventها در CI/debug log ثبت نمی‌شود.
- CI فقط با داده synthetic.
- داده خارجی بدون درخواست کاربر به سرویس ثالث ارسال نمی‌شود.

## Reports و Backup

External events به‌صورت پیش‌فرض وارد Task Report، PDF، Share، Export یا Task Backup نمی‌شوند. آروین Backup کامل Calendar خارجی نمی‌سازد.

## Conflict و Delete policy

اگر فقط یک سمت از آخرین sync تغییر کرده باشد، همان تغییر قابل اعمال است. اگر هر دو سمت تغییر کرده باشند، conflict باید بدون data loss/duplicate ثبت و برای تصمیم کاربر ارائه شود.

حذف Task در آروین به‌صورت پیش‌فرض event خارجی متصل را حذف نمی‌کند. linked-delete opt-in است و default آن خاموش است.

## Execution phases

1. Phase 1: Settings contract — **merged via #519**.
2. Phase 2: Settings UI در Settings اصلی.
3. Phase 3: read-only Android Calendar Provider discovery/read/permissions — ادامه existing Issue #348.
4. Phase 4: External Event projection در Calendar/Work Agenda موجود.
5. Phase 5: Arvin → Provider create/update + stable mapping.
6. Phase 6: delete policy.
7. Phase 7: conflict detection/resolution.
8. Phase 8: explicit import to canonical Task.
9. Phase 9: real-device E2E با Google-backed و Samsung-backed calendars در صورت دسترسی به evidence واقعی.

## Maximum Parallel / Production rules

- laneهای مستقل هم‌زمان اجرا می‌شوند.
- هیچ workflow/PR/Build/Device سالم برای Calendar feature pause/cancel/restart نمی‌شود.
- هر lane روی current main ساخته یا بعد از main advance clean rebuild می‌شود.
- CI قدیمی evidence head جدید نیست.
- Fast + Build/APK + Device exact-head/current-main-safe لازم است.
- Mergeها سریالی‌اند.
- Production Orchestrator پنج‌دقیقه‌ای مسیر آماده‌سازی و Merge را کنترل می‌کند.

## Definition of Done

Target وقتی Done است که Settings، permission-safe read/write، Calendar discovery، external projection، idempotent create/update/no-duplicate، mapping، delete policy، conflict handling، offline safety، explicit import و real-device evidence لازم همراه با regressionهای Task/FollowUp/Reminder/Work Agenda/Settings و exact-head CI همگرا باشند.

## References

- Umbrella: Issue #516
- Android Calendar Provider lane: Issue #348
- Phase 1 Settings contract: merged PR #519
- Existing deterministic sync planning: current CalendarSyncRevisionService / CalendarSyncPlanService foundation
