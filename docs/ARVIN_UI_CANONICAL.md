# Arvin Canonical UI Reference

## Canonical ontology — owner decision 2026-10-10

The only domain entities in this taxonomy are **Project / پروژه**, **Category / دسته** and **Tag / برچسب**. In Persian product language, «گروه» is a synonym for «دسته», not a fourth entity. Category and Tag remain distinct. Home's Time / Project / Category / Tag controls are four filters/views, not four domain entities. «گروه‌بندی» is allowed only for presentation/layout (for example, grouping Tasks by date), never as a separate data model. No Group model/store/repository or parallel management path may be introduced.

## Permanent Brand Requirement — NON-REMOVABLE

This is a binding, cross-surface Arvin UI/UX requirement. It survives UI redesigns, refactors, migrations, parallel implementation waves and future conversations.

### Arvin identity header
- The top of every primary Arvin product page must reserve a stable header/identity area; **Home is the primary mandatory instance**.
- The header must display exactly: **«بسم الله الرحمن الرحیم»** with the same calm, respectful visual character.
- This placement is part of Arvin's **brand identity**, not decorative copy.
- RTL presentation, generous breathing room, a soft/low-contrast treatment and harmony with **#4A4CAB** are mandatory.
- Removing, hiding, replacing, or relocating this identity element outside the approved stable header area is prohibited in any UI redesign, refactor, migration, test fix or merge.
- Any future UI work affecting a primary page must preserve this requirement and update the relevant regression/visual acceptance evidence.

### Final Arvin visual identity checklist
The final/reference imagery and release acceptance must preserve:
- **بسم الله الرحمن الرحیم**
- **مدیریت کارها و پیگیری آروین**
- exactly four primary Home filter/view controls: **زمان / پروژه / دسته / برچسب** (four filters/views, not four domain entities)
- a simple, calm daily-use Home
- a separate **Report Center**
- Arvin's indigo identity centered on **#4A4CAB**
- a custom Arvin **Bottom Navigation**, not a generic default navigation surface
- the feeling of a **Persian personal assistant**, not a generic Task Manager.

These are brand/product requirements, not optional visual polish. No future implementation may trade them away for generic Material convenience.

## Status
## Status
Accepted product/UI reference. Detailed governance is controlled by `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0.

This file is the **index of binding UI contracts**, not a replacement for their detailed acceptance criteria. A generic Material implementation is not acceptable when a more specific owner-approved surface contract exists.

## Latest recovery authority — 2026-09-12

GitHub Issue #845 and `docs/ARVIN_RECOVERY_WAVE0_EXACT_MAIN_AUDIT_2026-09-12.md` are the newest explicit owner-approved recovery overlay. They supersede older UI wording only where they directly conflict; the approved Arvin visual identity remains protected.

Current binding corrections:

- Home must no longer show the visible `کارهای من` title/options. Those filters/categories move under `بیشتر`.
- `کار امروز` is an automatic canonical due-date Task view; prayer entries and official events are excluded from Task counters.
- where `یادداشت` was used as the label for a work item merely because it had no FollowUp, use `بدون پیگیری`; this does **not** rename the real Notebook/Note concept.
- Task `+` / quick entry and full create/edit converge on one canonical editor behavior: title-only save is allowed and optional details remain available without creating another Task path.
- Notebook recovery targets a calm full-screen/near-full-screen content editor with category/actions at the top and easy same-ID move/delete while preserving canonical Notebook persistence.
- Project/Category/Tag, Calendar sync/actions, prayer state/reporting, Backup and font controls must reuse their existing foundations as mapped by Recovery Waves #847–#852.

Older screenshots/contracts remain traceability evidence. In particular, an older requirement for a visible `کارهای من` Home section is superseded by the explicit 2026-09-12 owner decision.

## Binding surface contracts

Before changing a product surface, read the most specific applicable contract:

- Recovery owner ledger and newest corrections: GitHub Issue #845 + `docs/ARVIN_RECOVERY_WAVE0_EXACT_MAIN_AUDIT_2026-09-12.md`
- Final owner decision for Home + Reminder Widget + Simple Note/To-do: `docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md`, except where superseded by the 2026-09-12 recovery overlay
- Home / Dashboard: `docs/HOME_STYLE_LOCK.md`, except the superseded visible-`کارهای من` placement rule
- Follow-up-enabled Task detail + add FollowUp flow: GitHub Issue #357
- Notebook / Simple Note / Checklist: `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md` + Recovery Wave #850 for the newest editor/layout requirement
- Follow-up Calendar: `docs/FOLLOWUP_CALENDAR_UX_CONTRACT_2026-08-27.md` when merged/current; live GitHub status outranks a stale branch copy
- Contextual Calendar/Notebook/Backup help: `docs/CONTEXTUAL_GUIDES_2026-08-27.md`
- Cross-surface acceptance registry: `docs/PRODUCT_CONTRACT_MATRIX.md`

When a new owner-approved visual/interaction decision is accepted, it must be added to the Product Contract Matrix or a newer explicitly indexed recovery overlay and linked here if it defines a primary surface.

## Core UI

AppShell / primary product surfaces include:
- Home / Dashboard
- Task detail
- FollowUp history and entry
- ReminderCard
- FollowUpCard
- Jalali Calendar
- Notebook / Simple Note / Checklist
- Quick Capture / unified Task entry behavior
- Project/taxonomy management surfaces
- Report/PDF/Print surfaces
- Notification/Widget surfaces
- First-run/contextual help and in-app User Guide

## Protected Rules

- Persian RTL-first presentation.
- Calm hierarchy and low visual noise.
- Approved navigation, typography, spacing, color language and component behavior remain stable unless a newer explicit owner decision changes a specific part.
- No broad UI redesign without explicit owner approval, design review, RTL verification, UX impact review and documentation.
- Current APK screenshots are runtime evidence; they do not automatically replace an accepted canonical design.
- A working backend/service does not count as UI completion when the accepted user interaction is missing.
- Splitting delivery into migration/parallel slices must not silently drop a deferred interaction; the Product Contract Matrix/recovery ledger remains open until the final user path is wired and validated.
- Help/onboarding is part of the product UI. It must not teach a superseded navigation, header action or creation flow.
- Recovery work must reuse canonical storage/models/services and must not create a second architecture merely to satisfy a visual change.

## Home Contract

The owner-supplied Arvin dashboard reference remains the final Home visual direction. Microsoft To Do is only a secondary source of small UX inspiration and is **not** the Home structure/color authority.

The 2026-09-12 recovery decision changes the information placement while preserving the visual identity:

- remove the visible `کارهای من` heading/options from Home;
- move the work filters/categories into `بیشتر`;
- keep Home focused on the approved dashboard hierarchy, current work/list content and compact primary add action;
- preserve the approved header/search/stat-card/task-card/bottom-navigation composition and indigo-led color language unless a later explicit owner decision changes it;
- expose `کار امروز` through canonical due-date semantics, not reminder/prayer/official-event timestamps.

Home identity safeguards:
- `بسم الله الرحمن الرحیم` and the product title remain the protected identity block.
- Backup is not a Home-header action.
- Quick Capture/selection utilities must not displace the approved identity/header hierarchy.
- Quick entry remains a fast input to the same canonical Task path and must converge with the owner-approved unified Task editor behavior; it must not create a parallel model/storage foundation.
- final visual acceptance requires applicable device/screenshot comparison with the owner-supplied Arvin reference while also verifying the newer placement decisions.

## Task / FollowUp Contract

Issue #357 remains binding where not superseded by newer #845 interaction decisions:
- Task create/edit exposes explicit `کار پیگیری‌دار` state.
- Home task tap opens task detail rather than jumping directly into edit where the detail contract applies.
- A follow-up-enabled Task detail exposes a round bottom `+` to append a FollowUp.
- Add FollowUp pre-fills system date/time, both editable.
- blank FollowUp text is valid and canonicalizes to `پیگیری`.
- save appends to existing canonical `followUps[]`; history is never erased by UI conversion/toggle behavior.
- Home shows the latest canonical FollowUp date/time.

Recovery Wave #848 additionally requires create/edit behavior to support title-only quick save and full optional details through one canonical editor path. This is a UX convergence requirement, not permission to duplicate Task storage or erase the existing detail/FollowUp contract.

## Notebook Contract

- «یادداشت ساده» and «چک‌لیست / To-do» remain distinct UX entry modes.
- Both reuse canonical `Task / TaskStore / arvin.tasks`; no Note/checklist storage path may be created solely for UI separation.
- A simple-note editor remains visually simple and does not show checklist controls by default.
- category/notebook grouping is visible and easy to reach; the newest recovery target places category/actions at the top of a full-screen/near-full-screen content-first editor.
- selecting a category immediately reassigns the same canonical Task through `Task.category`; do not clone or duplicate the note.
- delete/move actions should be easy to reach while still respecting Trash/soft-delete/data-safety rules.
- Joplin is a behavioral UX reference for notebook/category organization only; Arvin keeps its own canonical Flutter/Task architecture.

## Navigation Contract

Current verified shared implementation uses `خانه | تقویم | دفترچه | اقدام بعدی | بیشتر` through `ArvinPrimaryNavigation`.

The 2026-09-12 owner decision specifically makes `بیشتر` the home of the work-list filters/categories formerly shown as `کارهای من` on Home. It does not, by itself, change the five primary destinations above.

A future destination/order change requires an explicit owner-approved product decision and must update the applicable UI contract, Product Contract Matrix/recovery ledger, navigation tests and all user-facing help together.

## Help / Onboarding Contract

Arvin currently has distinct help concepts and they must not be conflated:
- first-run Home coach-marks may appear according to the dedicated seen-state contract;
- Calendar/Notebook/Backup contextual help is user-requested only per `docs/CONTEXTUAL_GUIDES_2026-08-27.md`;
- `UserGuidePage` is a read-only teaching surface and must match the current approved Home/navigation/workflows.

If UI/navigation changes, outdated help text or illustrations keep the related acceptance row **Partial** until reconciled. In particular, help must not teach a visible Home `کارهای من` filter block after Recovery Wave #848 lands, must not reintroduce Backup in the Home header, an obsolete extended primary add action, or an obsolete Calendar-as-launcher navigation model.

## Reminder / Widget Contract

`docs/OWNER_UI_DECISION_HOME_WIDGET_NOTEBOOK_2026-08-28.md` remains binding for reminder/widget hierarchy:

- `یادآور` is a type label; reminder content is the stronger main text.
- timed reminders show real time as accent metadata.
- all-day reminders show `تمام‌روز` and must not display a fabricated time.
- collapsed and expanded cards preserve a rounded light surface and clear reminder icon/hierarchy as platform space allows.
- expanded actions: complete, edit, convert to Task where permitted; Snooze is not a current accepted Calendar action.
- Lock Screen/widget behavior remains consistent with approved semantics and platform capability.

Historical issue #849 contains legacy Calendar complete/snooze wording. The current AMP contract supersedes Snooze: runtime action code is absent and regression tests assert that Snooze is not exposed. Do not restore it without a new explicit product decision; completion and the other approved Calendar actions remain governed by current acceptance evidence.

## Migration Direction

UI migration is incremental and must preserve existing working behavior while moving toward accepted canonical designs. Meaningful UI changes require appropriate widget/regression tests plus RTL and device/visual validation.

A deferred user interaction is not considered delivered merely because its domain model, service, persistence, reusable page or help text exists. Recovery status is governed by #845 and Waves #846–#853 until final convergence closes the ledger.


## AMP supersession note — Snooze (2026-10-10)

Older UI requirements mentioning Snooze are historical only and are superseded by the current owner-authored AMP contract. Current Calendar/task surfaces must not expose Snooze; keep the existing regression assertions that verify its absence.

## Supplemental owner visual-reference detail — migrated 2026-09-25

The following detailed visual contract is consolidated from the former `docs/UI/ARVIN_UI_CANONICAL.md`. It supplements this canonical UI index; newer explicit owner decisions and the binding contracts above take precedence wherever wording conflicts. The source file is removed only after preserving its substantive sections here.

## 1. هویت بصری مشترک

- رابط کاملاً فارسی و RTL.
- ظاهر روشن، تمیز، آرام، حرفه‌ای و کم‌ازدحام.
- کارت‌ها با زمینه روشن، گوشه‌های نرم و سایه بسیار ملایم.
- رنگ‌ها معنایی و کنترل‌شده باشند؛ رنگ نباید صرفاً تزئینی باشد.
- فونت نهایی: **VazirHarf v34.003**؛ جایگزینی با Vazirmatn مجاز نیست.
- آیکون‌ها باید از نظر معنا، ضخامت، اندازه، تراز و محل قرارگیری با مرجع هماهنگ باشند.
- اعداد، تاریخ و متن‌های فارسی با RTL و قالب نمایش فارسی هماهنگ باشند.
- اندازه‌ها، فاصله‌ها و تراکم اطلاعات موبایل باید از تصاویر مرجع تبعیت کنند، نه صرفاً از مقدارهای موجود در کد.

## 2. پالت پایه

| کاربرد | رنگ |
|---|---|
| رنگ اصلی آروین | `#4A4CAB` |
| سطح نرم/بنفش خیلی روشن | `#E9EAFF` |
| پس‌زمینه اصلی | `#F8F8FB` |
| سطح کارت | `#FDFDFE` |
| متن اصلی | `#232433` |
| متن فرعی | `#80829C` |

رنگ‌های معنایی باید ملایم و کم‌اشباع باشند و با زبان بصری مرجع هماهنگ شوند:

- پیگیری: بنفش/آبی آروین.
- انتظار پاسخ: زرد/نارنجی ملایم.
- اهمیت بالا: قرمز/صورتی ملایم.
- انجام‌شده: سبز ملایم.
- زمان، پروژه، دسته و برچسب: رنگ معنایی مستقل اما هماهنگ.

**اصل مهم:** تصویر مرجع برای شدت، سطح، ترکیب و کاربرد رنگ نیز مرجع است؛ تغییر رنگ صرفاً به دلیل سلیقه توسعه‌دهنده مجاز نیست.

## 3. صفحه اصلی

### هدر
- قرص «بسم الله الرحمن الرحیم».
- عنوان: **مدیریت کارها و پیگیری آروین**.
- اعلان در سمت فیزیکی چپ.
- منو در سمت فیزیکی راست.
- هدر فشرده و بدون عناصر تزئینی اضافی.

### جستجو
- نوار جستجوی روشن با گوشه نرم.
- آیکون جستجو در جای درست RTL.
- متن و فضای داخلی مطابق مرجع.

### چهار فیلتر/نمای اصلی Home
ترتیب و مفهوم نهایی:
1. **زمان**
2. **پروژه‌ها**
3. **دسته‌ها**
4. **برچسب‌ها**

برای هر چهار کنترل، اندازه، ارتفاع، گوشه، آیکون، رنگ، حالت انتخاب‌شده، فاصله و ترتیب RTL باید با تصویر مرجع هماهنگ باشد.

### حالت زمان
- عقب‌افتاده.
- امروز.
- آینده.
- گروه‌بندی بر اساس تاریخ انجام؛ یادآوری و پیگیری نباید به‌جای due date استفاده شوند.
- کار انجام‌شده نباید صرفاً به دلیل تاریخ قدیمی «عقب‌افتاده» نمایش داده شود.

### حالت پروژه‌ها
- گروه‌بندی بر اساس پروژه‌های موجود.
- استفاده از پروژه و آیکون/رنگ معنایی آن.
- بدون ایجاد ذخیره‌سازی موازی.

### حالت دسته‌ها
- گروه‌بندی بر اساس دسته‌های موجود.
- آیکون و رنگ دسته مطابق زبان بصری مرجع.

### حالت برچسب‌ها
- گروه‌بندی بر اساس برچسب‌های موجود.
- آیکون/رنگ و شمارنده‌ها مشابه منطق مرجع.

### کارت‌های کار
- عنوان واضح.
- چک‌باکس در محل مناسب.
- متادیتای کم‌حجم.
- نمایش آخرین پیگیری در جای مناسب.
- Badgeهای کوچک و رنگی.
- شمارنده‌های کوچک و خوانا.
- از کارت‌های بزرگ و سنگین غیرضروری پرهیز شود.

### نوار پایین
دقیقاً پنج مقصد:
**خانه، تقویم، دفترچه، اقدام بعدی، بیشتر**

- «خانه» حالت فعال و رنگ اصلی آروین را دارد.
- آیکون و متن هم‌تراز و کم‌حجم.
- FAB بالای نوار پایین و در موقعیت مشابه مرجع.

## 4. صفحه «کار پیگیری‌دار»

هدف این صفحه **مدیریت مسیر پیگیری** است، نه نمایش یک فرم اطلاعاتی ساده.

### هدر
- عنوان/هویت کار در مرکز توجه.
- **ویرایش** با آیکون مداد در سمت فیزیکی چپ.
- **جزئیات کار** و فلش برگشت در سمت فیزیکی راست، مطابق مرجع.
- عملیات فرعی مانند PDF/اشتراک‌گذاری داخل منوی بیشتر؛ هدر نباید شلوغ شود.

### کارت خلاصه اصلی
یک کارت یکپارچه شامل:
- عنوان کار.
- وضعیت.
- پروژه.
- دسته.
- برچسب.
- توضیح کوتاه.
- تاریخ انجام.
- یادآوری.
- نوع پیگیری.
- اهمیت.
- Badgeهای معنایی کوچک.

### وضعیت
Badgeهای معنایی:
- **کار پیگیری‌دار**
- **در انتظار پاسخ**
- **انجام شده**

رنگ Badge باید معنا را منتقل کند، نه صرفاً تزئین باشد.

### آخرین پیگیری
کارت برجسته با:
- عنوان **آخرین پیگیری**.
- متن آخرین اقدام.
- تاریخ و ساعت.
- نتیجه/وضعیت.
- سطح پس‌زمینه متمایز اما ملایم.

### تاریخچه پیگیری
- عنوان **تاریخچه پیگیری**.
- شمارنده کوچک.
- Timeline عمودی.
- نقطه وضعیت.
- خط اتصال ظریف.
- هر رخداد در کارت مستقل.
- تاریخ، ساعت و متن اقدام.
- منوی سه‌نقطه برای عملیات هر رخداد.

### اقدام بعدی
- کارت مستقل **اقدام بعدی**.
- متن اقدام و زمان بعدی.
- همان زبان بصری کارت‌های مرجع.

### عملیات پایین
دو عمل اصلی:
- **افزودن پیگیری** — عمل اصلی.
- **انجام کار** — عمل ثانویه.

دکمه‌ها باید تمام عرض مفید پایین صفحه را با تقسیم مشابه تصویر مرجع پوشش دهند.

## 5. قواعد آیکون

آیکون‌های اصلی مرجع:
- زمان: تقویم.
- یادآوری: زنگ.
- پروژه: پوشه.
- دسته: شبکه/چهارخانه.
- برچسب: تگ.
- پیگیری: سند/پیگیری.
- ویرایش: مداد.
- افزودن: بعلاوه.
- انجام کار: تیک.
- بیشتر: سه‌نقطه.
- بازگشت: فلش RTL.
- جستجو: ذره‌بین.
- اعلان: زنگ.

آیکون‌ها باید از یک خانواده بصری هماهنگ باشند و از نظر ضخامت، اندازه و تراز با مرجع هماهنگ شوند.

## 6. قواعد شکل، اندازه و فاصله

- گوشه کارت‌ها نرم و یکنواخت.
- حاشیه‌ها ظریف.
- سایه‌ها بسیار کم.
- فضای سفید کافی، اما بدون فاصله‌های غیرضروری.
- تراکم اطلاعات در موبایل مشابه مرجع.
- عنوان، Badge، آیکون و مقدار اطلاعات سلسله‌مراتب واضح داشته باشند.
- هیچ عنصر قدیمی یا زائد فقط به دلیل باقی‌ماندن در کد حفظ نشود.
- ظاهر نباید به سمت داشبورد شلوغ، کارت‌های سنگین یا رنگ‌های تند برود.

## 7. تایپوگرافی

- فونت اصلی: **VazirHarf v34.003**.
- RTL واقعی، نه صرفاً راست‌چین‌کردن متن.
- عنوان‌ها پررنگ و واضح.
- متن توضیحی سبک‌تر و کم‌رنگ‌تر.
- Badgeها کوتاه و خوانا.
- تاریخ/ساعت از نظر اندازه و رنگ فرعی‌تر از عنوان اقدام باشند.
- شکست خطوط باید کنترل‌شده و مشابه مرجع باشد.

## 8. اصل تطابق تصویری

هر تغییر UI باید از این فیلتر عبور کند:

1. شکل کلی مطابق مرجع است؟
2. رنگ و شدت رنگ مطابق مرجع است؟
3. آیکون درست و در جای درست است؟
4. اندازه و فاصله درست است؟
5. تراکم اطلاعات درست است؟
6. RTL و تراز بصری درست است؟
7. در Android واقعی نیز همین ظاهر دیده می‌شود؟

**وجود Widget/کد به‌تنهایی اثبات تطابق UI نیست.** تأیید نهایی باید با اجرای Android و مقایسه بصری انجام شود.

## 9. اولویت مرجع

در تعارض بین منابع:
1. **تصاویر مرجع صاحب محصول**
2. این سند
3. تصمیم‌های جدید و صریح محصول
4. کد موجود

UI قدیمی یا کامپوننت موجود، به‌خودی‌خود مرجع نیست.

## 10. محدودیت‌های معماری

این مرجع بصری نباید باعث بازنویسی غیرضروری محصول شود:

- داده‌های واقعی کاربر حفظ شوند.
- Storage یا Model موازی ایجاد نشود.
- UI روی مدل‌ها و ذخیره‌سازی canonical موجود سوار شود.
- تغییر ظاهر نباید Migration/Storage را خراب کند.
- «ظاهر دقیق» هدف UI و «حفظ داده و رفتار واقعی» شرط محصول است.

## 11. معیار نهایی تحویل

آروین زمانی از نظر UI این مرجع را رعایت کرده است که:
- صفحه اصلی در هر چهار حالت اصلی با مرجع هم‌خوان باشد.
- صفحه «کار پیگیری‌دار» با مرجع هم‌خوان باشد.
- رنگ‌بندی، آیکون‌ها، فونت، فاصله، اندازه، کارت‌ها و نوار پایین هماهنگ باشند.
- روی Android واقعی بررسی شده باشد.
- اختلاف‌های بصری باقی‌مانده شناسایی و اصلاح شده باشند.

**این سند یک «پیشنهاد طراحی» نیست؛ قرارداد بصری مورد انتظار محصول آروین است.**
