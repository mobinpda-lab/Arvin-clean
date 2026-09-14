# قرارداد محصول — دفترچه یادداشت ساده

> **وضعیت: قرارداد محصولی فعال، همگام‌شده با معماری canonical فعلی**
>
> این سند تصمیم‌های UX دفترچه یادداشت ساده آروین را حفظ می‌کند. هر اشاره تاریخی به مدل Note مستقل یا کلید `arvin.simple_notes` منسوخ است و نباید مبنای implementation جدید قرار گیرد.

## رفتار ثبت

- کاربر «یادداشت ساده» را مستقل از «چک‌لیست» انتخاب می‌کند.
- صفحه یادداشت ساده برای موضوع/عنوان و متن آزاد است و نباید بخش چک‌لیست را به‌صورت پیش‌فرض داخل همان editor نشان دهد.
- تاریخ و ساعت ایجاد از زمان سیستم ثبت می‌شود.
- ذخیره‌سازی متن در حالت ویرایش به‌صورت خودکار انجام می‌شود.

## رفتار پس از خروج

- یادداشت موجود در مراجعه بعدی در حالت فقط‌خواندنی باز می‌شود.
- کاربر با اقدام صریح «ویرایش» وارد حالت ویرایش می‌شود.
- تغییرات از مسیر canonical ذخیره می‌شوند.

## چک‌لیست

- «چک‌لیست» یک مسیر ایجاد جدا از «یادداشت ساده» در UX است.
- داده چک‌لیست از فیلد موجود `Task.checklist` استفاده می‌کند؛ مدل یا Storage دوم ساخته نمی‌شود.
- انتخاب چک‌لیست می‌تواند قالب‌های پیشنهادی داشته باشد، اما صفحه یادداشت ساده نباید به‌خاطر اشتراک مدل با چک‌لیست شلوغ شود.

## زمان یادداشت و Calendar

زمان ایجاد/ویرایش Note فقط metadata داخلی آروین است.

- Note نباید فقط به‌خاطر timestamp خود به `CalendarReminder` تبدیل شود.
- Note نباید به‌صورت خودکار در Google/system Calendar ایجاد شود.
- نمایش Note در Calendar آروین نیازمند تصمیم محصولی صریح جداگانه است.

## معماری canonical و سازگاری

- Simple Note یک رفتار از همان `Task / Unified Item` canonical است.
- تشخیص فعلی با `Task.isSimpleNote` انجام می‌شود.
- persistence فقط از `TaskStore` و envelope موجود `arvin.tasks` استفاده می‌کند.
- `CanonicalNotebookRepository` مرز فعلی Notebook است و عمداً هیچ کلید، دیتابیس یا مدل مستقلی ندارد.
- این قرارداد، پیشنهاد تاریخی Storage مستقل `arvin.simple_notes` را صریحاً supersede می‌کند.
- Backup/Restore باید Note و checklist را از همان canonical Task data حفظ کند.

## مرجع implementation فعلی

- `lib/models/task.dart`
- `lib/services/canonical_notebook_repository.dart`
- `lib/notebook_page.dart`
- `docs/NOTEBOOK_COMPLETION_LANE_2026-08-26.md`

## وضعیت UX canonical فعلی

تفکیک «یادداشت ساده» و «چک‌لیست» در UI و persistence صریح است:

- صفحه فهرست عنوان «دفترچه» و زیرعنوان «یادداشت‌ها و چک‌لیست‌ها» دارد.
- جستجو، فیلترهای مرجع «همه / شخصی / کاری / ایده‌ها» و mode switch مستقل «یادداشت‌ها / چک‌لیست‌ها» در سطح فهرست وجود دارد.
- دکمه + نوع انتخاب‌شده را ایجاد می‌کند و در صورت انتخاب فیلتر دسته، همان دسته را به‌عنوان مقدار پیش‌فرض canonical ثبت می‌کند.
- editor یادداشت ساده کنترل‌های چک‌لیست را نمایش نمی‌دهد.
- editor چک‌لیست شمارنده واقعی انجام‌شده/کل و progress واقعی دارد و add/edit/delete/toggle از همان `Task.checklist` ذخیره می‌شود.
- برای حفظ هویت چک‌لیست خالی، `Task.notebookKind` یک discriminator افزایشی و backward-compatible در همان `arvin.tasks` است؛ داده قدیمی فاقد آن همچنان از وجود `checklist` استنتاج می‌شود.
- Project/Tag grouping قدیمی جزو قرارداد بصری Notebook نیست و در سطح editor canonical Notebook نمایش داده نمی‌شود.

## قانون ضد دوباره‌کاری

قبل از هر تغییر مرتبط با Note/Checklist:
1. `main` و PRهای باز بررسی شوند.
2. `Task.isSimpleNote`، `Task.checklist` و `CanonicalNotebookRepository` دوباره استفاده شوند.
3. هیچ Note model/storage/repository موازی ساخته نشود.
4. Calendar/Backup compatibility بررسی شود.
5. تست تفکیک UX «یادداشت ساده» و «چک‌لیست» وجود داشته باشد.
6. exact-head CI و در تغییرات UI، device/visual validation انجام شود.
