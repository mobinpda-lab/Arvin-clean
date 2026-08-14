# Arvin Status Snapshot — ۱۴۰۵/۰۵/۲۳

## مبنای بازنگری

بازنگری برنامه بر اساس main فعلی، PRهای باز و مستندات موجود انجام شد. Repository در حال حاضر PRهای باز متعددی دارد که بخشی از آن‌ها Waveهای قدیمی‌تر هستند؛ بنابراین از این نقطه به بعد، اولویت با تعیین مسیر canonical و جلوگیری از اجرای موازیِ تکراری است.

## مشاهده‌های کلیدی

- README هسته محصول را Task/FollowUp، Tag، انتخاب گروهی، Archive/Trash، Swipe، Settings و Backup/Restore معرفی می‌کند و Dropbox را آماده اتصال می‌داند.
- در `lib` هم‌اکنون لایه‌های متعدد Backup، Calendar و Dropbox provider وجود دارند؛ بنابراین توسعه Cloud باید با audit انجام شود، نه ساختن Provider موازی جدید.
- Calendar جلالی و Reminder قبلاً Waveهای متعدد داشته‌اند؛ بازنویسی آن فعلاً اولویت نیست.
- FollowUp اجزای Domain/Storage/Application/Agenda/Office دارد؛ شکاف اصلی، integration محصولی و regression است.
- Simple Note نیز پایه‌های Domain/Storage/Application/Session Policy دارد؛ شکاف اصلی UI/Settings/Checklist و اتصال کنترل‌شده به Task است.
- Product Idea سند Time Jot به‌عنوان مرجع نیازمندی‌ها ثبت شده است.

## تصمیم مدیریتی جدید

از این مرحله، «تعداد PR» معیار پیشرفت نیست. معیار پیشرفت، قابلیت قابل استفاده در APK و عبور از Definition of Done است.

PRهای قدیمی که هدفشان قبلاً در main یا Wave جدید پوشش داده شده، نباید مبنای کار جدید قرار گیرند؛ قبل از هر Merge باید مشخص شود که آیا هنوز canonical هستند یا صرفاً سابقه/مستندات‌اند.

## اولویت فعلی

1. Baseline سبز.
2. FollowUp Integration.
3. Simple Note UI و رفتار Read-only/Edit.
4. Search/Sort/Home UX.
5. PDF/Share.
6. IRANSans + Typography Settings.
7. Reminder/Google Calendar.
8. Dropbox/Backup/Restore.
9. E2E و APK نهایی.

## اصل موازی‌سازی

Waveهای مستقل بدون انتظار متقابل اجرا و Validate شوند. اگر دو Wave به یک مدل یا فایل مشترک وابسته‌اند، ابتدا یک Contract کوچک و تست‌شده ساخته شود؛ سپس کارهای مستقل موازی شوند.

## اصل عدم خراب‌کاری

هر تغییر باید قبل از اجرا با main، PRهای باز، مستندات، تست‌های قبلی و مرزهای محصول مقایسه شود. قابلیت حل‌شده دوباره ساخته نشود و Calendar/Backup/FollowUp/Note بدون دلیل واقعی بازنویسی نشوند.
