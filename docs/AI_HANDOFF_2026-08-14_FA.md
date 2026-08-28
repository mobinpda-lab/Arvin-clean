# Arvin-clean — AI Handoff / انتقال کامل پروژه

**تاریخ:** ۱۴۰۵/۰۵/۲۳
**Repository:** `mobinpda-lab/Arvin-clean`
**Platform:** Android / Flutter / Dart
**هدف سند:** انتقال وضعیت، سابقه تصمیم‌ها، معماری، قابلیت‌ها، قوانین توسعه، خطاهای شناخته‌شده و مسیر ادامه پروژه به یک هوش مصنوعی دیگر، بدون نیاز به اتکا به حافظه گفتگوهای قبلی.

---

## 1. خلاصه محصول

آروین یک نرم‌افزار فارسی/RTL برای مدیریت کارها، پیگیری الکترونیکی، یادداشت ساده، تقویم و یادآوری است.

هسته محصول:

`Task + FollowUp History + Simple Note + Calendar + Reminder + Tags + Archive + Trash + Backup/Restore + Settings`

آروین نباید صرفاً یک Todo List ساده باشد. هدف، ثبت سابقه واقعی پیگیری کارها و امکان بازگشت به سوابق است.

---

## 2. مرجع ایده محصول

یک متن نیازمندی با الهام از تجربه Time Jot توسط کاربر ارائه شده و به‌عنوان **Product Requirements / Product Idea Reference** پذیرفته شده است.

نیازهای مهم ثبت‌شده:

- تاریخ هجری شمسی.
- استفاده از تاریخ و ساعت سیستم با امکان ویرایش توسط کاربر.
- ثبت کار و چندین پیگیری برای آن.
- مشاهده تاریخچه کامل پیگیری‌ها.
- دسته‌بندی و Tag.
- Reminder برای کار و پیگیری.
- PDF یک کار همراه پیگیری‌ها و Share.
- PDF فهرست کارها و Share.
- Backup / Restore.
- بایگانی و Trash.
- ویرایش کامل همه بخش‌ها.
- Long Press برای انتخاب چندتایی.
- عملیات گروهی.
- Swipe چپ/راست قابل تنظیم.
- توضیحات کار.
- نمایش آخرین پیگیری و ساعت/دقیقه در Home.
- Search سراسری.
- FAB پایین صفحه برای +.
- Sort بر اساس تاریخ، آخرین ورودی و عنوان و Reverse Sort.
- Note ساده که در صورت نیاز به Task دارای FollowUp تبدیل شود.
- Checklist داخل Note.
- Today / Future / Overdue.
- UI مدرن، فارسی و RTL.
- فونت اصلی **IRANSans / IranSansX(Eco)** بر اساس فایل فونتی که کاربر قبلاً ارائه کرده است.

سند تفصیلی ایده و Gap Analysis:

`docs/PRODUCT_IDEA_TIMEJOT_ANALYSIS_FA.md`

---

## 3. تصمیم مهم Note / Task / Reminder / Calendar

این چهار مفهوم نباید با هم اشتباه شوند:

`Simple Note != Reminder != FollowUp != Calendar Event`

### Simple Note

- مورد جدید می‌تواند ابتدا Note ساده باشد.
- تاریخ و ساعت ثبت خودکار از سیستم گرفته می‌شود.
- تاریخ و ساعت قابل ویرایش است.
- ذخیره خودکار انجام می‌شود.
- بعد از خروج، Note فقط‌خواندنی است.
- برای Edit مجدد باید دکمه «ویرایش» زده شود.
- تاریخ Note فقط داخل آروین نگهداری می‌شود.
- Note نباید به Calendar گوشی یا Google Calendar Event تبدیل شود.

### Task

با فعال‌کردن پیگیری روی یک Note/مورد، قابلیت Task/FollowUp برای همان مورد فعال می‌شود.

### FollowUp

هر FollowUp دارای timestamp خودکار سیستم است و کاربر می‌تواند تاریخ/ساعت آن را اصلاح کند. سابقه همه FollowUpها باید حفظ شود.

### Reminder

Reminder از timestamp ثبت جداست. Reminder یعنی زمان هشدار، نه زمان ایجاد Note یا زمان ثبت FollowUp.

### Google Calendar

در صورت فعال‌شدن Integration، فقط Task/FollowUpهای مناسب می‌توانند به Google Calendar بروند. Noteهای ساده هرگز نباید به Calendar ارسال شوند.

---

## 4. فونت

تصمیم نهایی محصول:

**فونت اصلی و پیش‌فرض UI آروین = IRANSans / IranSansX(Eco)**

فایل فونت قبلاً توسط کاربر ارائه شده است.

در آینده Font Settings می‌تواند امکان انتخاب فونت‌های مجاز دیگر را بدهد، اما فونت پیش‌فرض نباید بدون تصمیم جدید به Vazirmatn تغییر کند.

---

## 5. قابلیت‌های پایه موجود

README پروژه این موارد را به‌عنوان پایه‌های فعلی معرفی می‌کند:

- مدیریت کارها و پیگیری‌ها.
- عنوان خودکار از سطر اول توضیحات با امکان اصلاح.
- تاریخ پیگیری، شامل تاریخ‌های گذشته.
- Tag.
- انتخاب چندتایی و عملیات گروهی.
- Archive و Trash.
- تنظیم Swipe چپ و راست.
- Settings panel.
- Backup/Restore.
- آماده‌سازی اتصال Dropbox.

README همچنین Build پایه را این‌گونه تعریف می‌کند:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

---

## 6. ساختار Repository

در ریشه Repository فعلی این بخش‌ها مهم هستند:

- `README.md` — معرفی و Build.
- `PROJECT_DOCUMENTATION_FA.md` — مستندات اصلی پروژه.
- `docs/` — Roadmap، تصمیم‌ها، تحلیل Product Requirements و سوابق.
- `lib/` — کد Flutter/Dart.
- `test/` — تست‌ها.
- `android/` — پروژه Android.
- `.github/` — GitHub Actions.
- `pubspec.yaml` — dependencies و تنظیمات Flutter.

---

## 7. Backup / Dropbox

در `lib/` اجزای Backup موجود هستند، از جمله:

- `backup_manager.dart`
- `backup_service.dart`
- `backup_page.dart`
- `backup_schedule.dart`
- `backup_schedule_page.dart`
- `android_backup_scheduler.dart`
- `backup_background_runner.dart`
- `backup_notification_service.dart`
- `cloud_backup_provider.dart`
- `dropbox_cloud_backup_provider.dart`
- `dropbox_cloud_backup_provider_v2.dart`

**قانون:** سیستم Backup/Dropbox جدید و موازی نسازید. ابتدا همین پیاده‌سازی موجود را Audit و تکمیل کنید.

---

## 8. Calendar

`lib/calendar_page.dart` در Repository وجود دارد.

Calendar جلالی یکی از بخش‌های تثبیت‌شده پروژه است و قبلاً به دلیل Regressionهای تستی بررسی شده است.

**قانون:** Calendar را فقط برای یک تغییر واقعی و اثبات‌شده دستکاری کنید. سبز بودن CI به‌تنهایی دلیل بازنویسی Calendar نیست.

---

## 9. پروژه‌های مرجع

کاربر اجازه داده از تجربیات دو پروژه برای طراحی استفاده شود:

- `mobinpda-lab/arvin-task-tracker`
- `mobinpda-lab/daftar-peygiri`

از `arvin-task-tracker` مخصوصاً تجربه UI تقویم/ساعت برای UX الهام گرفته شود.

از `daftar-peygiri` برای تجربه دفتر پیگیری استفاده شود.

این پروژه‌ها **منبع الهام و تجربه** هستند، نه مجوز کپی کورکورانه. قبل از انتقال هر قابلیت باید معماری و کد Arvin-clean بررسی شود.

---

## 10. وضعیت Notebook

Simple Notebook بخشی رسمی از محصول است.

رفتار مصوب:

1. ایجاد Note با timestamp خودکار.
2. امکان ویرایش timestamp.
3. ذخیره خودکار.
4. خروج = Read-only.
5. مراجعه بعدی = Read-only.
6. دکمه Edit برای بازکردن حالت ویرایش.
7. Checklist.
8. امکان فعال/غیرفعال کردن رفتارهای مرتبط در Settings.
9. Noteها وارد Google Calendar یا Calendar گوشی نمی‌شوند.

Waveهای قبلی Notebook شامل Foundation، Service و Session Policy بوده‌اند؛ قبل از ساخت Wave جدید باید PRهای باز مربوط به Notebook بررسی شوند.

---

## 11. FollowUp

FollowUp هسته اصلی محصول است.

باید شامل:

- ثبت سریع.
- تاریخ و ساعت خودکار.
- امکان اصلاح تاریخ/ساعت.
- متن/توضیح.
- تاریخچه کامل.
- آخرین FollowUp در Home.
- Today/Future/Overdue.
- Reminder در صورت نیاز.
- اتصال صحیح به TaskRepository/TaskStore.

اگر قابلیت قبلاً در Wave دیگری پیاده شده، دوباره‌سازی ممنوع است.

---

## 12. Search

یک Wave مستقل Search ساخته شده است.

هدف Search:

- Task title.
- Task description.
- Tags.
- FollowUp text.
- FollowUp result.

Search باید روی مدل موجود کار کند و Repository/Storage موازی جدید ایجاد نکند.

---

## 13. وضعیت CI و خطای اخیر

Run ارائه‌شده توسط کاربر:

`31824305634`

Job:

`94844670770`

در این Run، GitHub روی merge ref مربوط به PR #67 اجرا شده و Flutter `3.47.0` روی Ubuntu 24.04 استفاده شده است.

خطای واقعی در `flutter analyze`:

```text
test/task_search_service_test.dart:18:23
const_with_non_const
non_constant_list_element
```

علت: در تست Search یک List/constructor غیر const با `const` استفاده شده بود.

این خطا مربوط به تست است، نه اثبات خرابی منطق Search.

**اقدام درست:** فقط همان fixture/test را اصلاح کنید و سپس Analyze/Test را دوباره اجرا کنید. از تغییر غیرضروری Search یا مدل داده خودداری کنید.

---

## 14. نکته مهم CI

Workflow فعلی قبل از Analyze یک `flutter create --platforms=android --project-name arvin .` اجرا می‌کند و سپس Gradle desugaring را تنظیم می‌کند.

این رفتار باید هنگام بررسی Build در نظر گرفته شود. اگر Build مشکلی نشان داد، ابتدا مشخص کنید مشکل از source واقعی پروژه است یا از مرحله bootstrap/CI.

Flutter cache فعلی در Run اخیر:

`3.47.0 stable`

---

## 15. قوانین توسعه — بسیار مهم

این‌ها قوانین دائمی همکاری پروژه هستند:

### قانون 1 — بررسی کل پروژه قبل از تغییر

قبل از هر Commit:

1. `main` را بررسی کن.
2. کد واقعی را بررسی کن.
3. PRهای باز را بررسی کن.
4. مستندات را بررسی کن.
5. تست‌های مرتبط و خطاهای اخیر را بررسی کن.
6. Product Requirements را بررسی کن.

### قانون 2 — دوباره‌کاری ممنوع

اگر قابلیت قبلاً رفع شده، دوباره آن را نساز.

### قانون 3 — خراب‌کاری ممنوع

مدل داده، Calendar، Backup و APIهای موجود را بدون دلیل و migration تغییر نده.

### قانون 4 — Parallel Development

Waveهای مستقل را تا جای ممکن به شکل Branch/Commit/PR مستقل اجرا کن و Workflowهایشان را همزمان اجرا/Validation کن.

### قانون 5 — Documentation

هر تصمیم مهم محصولی و هر تغییر معماری مهم باید در `docs/` ثبت شود.

### قانون 6 — Green CI کافی نیست

Definition of Done فقط سبزشدن Workflow نیست. قابلیت باید در کد، تست، UI، persistence و در نهایت APK قابل استفاده باشد.

### قانون 7 — APK واقعی

هر زمان یک مجموعه قابلیت به اندازه کافی پایدار شد، Release APK ساخته و روی گوشی تست شود. خروجی APK قابل تست باید از Artifact واقعی GitHub Actions گرفته شود.

---

## 16. Definition of Done پیشنهادی

هر قابلیت زمانی تمام‌شده محسوب شود که:

- [ ] مدل داده صحیح است.
- [ ] Service/Repository صحیح است.
- [ ] Persistence تست شده.
- [ ] Unit/Widget test مرتبط وجود دارد.
- [ ] UI واقعی متصل شده.
- [ ] RTL و فارسی بررسی شده.
- [ ] تاریخ شمسی بررسی شده.
- [ ] رفتار Read-only/Edit بررسی شده.
- [ ] Regression تست شده.
- [ ] CI سبز است.
- [ ] مستندات به‌روزرسانی شده.
- [ ] در APK واقعی قابل مشاهده است.

---

## 17. Roadmap فعلی

### Wave A — FollowUp

تکمیل اتصال Domain/Application/Agenda به UI واقعی و Task storage.

### Wave B — Simple Notebook

UI + Auto-save + Read-only/Edit + Checklist + Settings.

### Wave C — Home/Search/Sort

Search سراسری + Sort + Reverse + FAB + Swipe.

### Wave D — PDF/Share

PDF یک Task با FollowUps + PDF فهرست + Share.

### Wave E — Fonts

IRANSans به‌عنوان پیش‌فرض + Font Settings.

### Wave F — Reminder/Google Calendar

Reminder واقعی + Google Calendar برای Task/FollowUp؛ Noteها مستثنا.

### Wave G — Dropbox

Backup/Restore production-ready، authentication و conflict handling با استفاده از providerهای موجود.

### Wave H — E2E / Release

Regression کامل، APK Release و تست روی گوشی.

---

## 18. Checklist هوش مصنوعی بعدی

هوش مصنوعی جدید قبل از شروع باید:

- این فایل را کامل بخواند.
- `README.md` را بخواند.
- `PROJECT_DOCUMENTATION_FA.md` را بخواند.
- `docs/` را بررسی کند.
- PRهای باز را بررسی کند.
- وضعیت CI اخیر را بررسی کند.
- کد واقعی `lib/` و `test/` مرتبط را بخواند.
- سپس فقط یک Plan کوتاه بدهد و بعد تغییر کند.

هرگز فقط بر اساس این سند حدس نزن؛ **این سند برای انتقال context است، نه جایگزین source code**.

---

## 19. منابع مستقیم

Repository:

`https://github.com/mobinpda-lab/Arvin-clean`

README:

`https://github.com/mobinpda-lab/Arvin-clean/blob/main/README.md`

Documentation:

`https://github.com/mobinpda-lab/Arvin-clean/blob/main/PROJECT_DOCUMENTATION_FA.md`

Actions:

`https://github.com/mobinpda-lab/Arvin-clean/actions`

Reference projects:

`https://github.com/mobinpda-lab/arvin-task-tracker`

`https://github.com/mobinpda-lab/daftar-peygiri`

---

## 20. آخرین وضعیت در زمان ایجاد سند

- پروژه Flutter/Android فعال است.
- CI و Parallel Wave فعال هستند.
- Search Wave در حال Validation است.
- Notebook در حال تکمیل مرحله‌ای است.
- FollowUp هسته اصلی پروژه است و باید بدون دوباره‌کاری تکمیل شود.
- Calendar نباید بی‌دلیل بازنویسی شود.
- Backup/Dropbox providerهای موجود باید Audit شوند، نه اینکه سیستم موازی ساخته شود.
- IRANSans فونت اصلی مصوب است.
- Simple Note نباید Calendar Event بسازد.
- Google Calendar برای Task/FollowUp است، نه Note.
- PDF/Share، Font Settings، Search UI، Notebook UI، Dropbox production integration و E2E از قابلیت‌های باقی‌مانده مهم هستند.

**هدف نهایی:** یک APK فارسی، RTL، مدرن، پایدار و واقعاً قابل استفاده برای مدیریت کار، پیگیری، یادداشت و سوابق آن.
