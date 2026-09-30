# مشخصات مرجع محصول — تقویم آروین

آخرین به‌روزرسانی: ۱۴۰۵/۰۷/۰۸ — ۳۰ سپتامبر ۲۰۲۶
مبنای اجرایی فعلی: شاخه feat/calendar-recurrence-and-product-ux-20260930
آخرین HEAD اصلاح UX: b573d391bbee3445d5adec87a734d1efa11f8b10
قرارداد canonical: Issue #2042

## 1) اصل محصول
Calendar در آروین یک projection از زمان‌بندی canonical Task/Recurrence است؛ occurrenceها رکورد مستقل Task یا Reminder نیستند.
Home لیست Taskهای canonical است، نه لیست occurrenceها. یک Task تکرارشونده در Home حداکثر یک کارت دارد.

## 2) رفتار recurrence در Calendar
- گذشته، امروز و آینده باید قابل پیمایش و نمایش باشند.
- برای هر تاریخ/ساعتی که recurrence واقعاً موعد دارد، در بازه قابل مشاهده یک occurrence نمایش داده می‌شود.
- روزی که طبق rule موعد ندارد، occurrence ندارد.
- occurrence گذشته صرفاً به دلیل قدیمی‌بودن حذف نمی‌شود؛ تا وقتی Task canonical انجام، بایگانی یا حذف نشده، تاریخچه باید قابل مشاهده باشد.
- پیمایش تقویم فقط presentation را تغییر می‌دهد و schedule canonical Task را تغییر نمی‌دهد.
- روزانه، هفتگی، ماهانه و intervalهای سفارشی باید از همان recurrence canonical استفاده کنند.
- intervalهای زمانی مانند ۲۰ دقیقه، ۹۰ دقیقه، ۱ ساعت و ۲ ساعت باید در همان engine canonical پشتیبانی شوند.

## 3) رفتار Home
- از هر recurring Task حداکثر یک کارت canonical.
- occurrenceهای گذشته/امروز/آینده نباید کارت‌های جدا بسازند.
- اگر امروز موعد recurrence است، همان کارت نماینده نوبت امروز است.
- اگر امروز موعد نیست، کارت زمانی جدید برای recurrence ساخته نمی‌شود.
- وضعیت عقب‌افتادگی در همان کارت canonical قابل نمایش است.

## 4) Move to Today
Move to Today برای نمایش recurrence لازم نیست و بخشی از acceptance این قابلیت نیست. هر اقدام آینده برای انتقال موعد به امروز باید یک قابلیت داده‌تغییردهنده مستقل باشد.

## 5) یادآور خودکار
اگر Task دارای due date + time باشد و تنظیم «یادآور خودکار برای موعد» فعال باشد، Reminder canonical باید با همان تاریخ/ساعت ایجاد یا همگام شود. Reminder باید بعداً قابل ویرایش/حذف باشد. تغییر یا حذف موعد نباید Reminder دستی کاربر را بدون قرارداد مشخص خراب کند. مقدار پیش‌فرض toggle تا زمان تصمیم محصول نباید حدس زده شود.

## 6) Calendar Provider / Sync
- Task canonical و event دستگاه باید لینک پایدار داشته باشند.
- ثبت دستی و sync خودکار نباید event تکراری بسازند.
- تغییر عنوان/موعد باید event موجود را update کند، نه event دوم بسازد.
- حذف/تکمیل/بایگانی/سطل‌زباله باید طبق policy مصوب، event را همگام کند.
- حذف دائمی Task باید event لینک‌شده را حذف کند.
- Calendar Sync باید به تقویم دستگاه انتخاب‌شده کاربر محدود باشد.
- Provider acceptance باید روی exact HEAD اجرا شود.

## 7) UI تقویم
- RTL و Persian digits الزامی است.
- سربرگ دوره باید نام کامل ماه شمسی + سال را نشان دهد؛ نمونه: «مهر ۱۴۰۵».
- نمایش «۱۴۰۵/۰۷» به‌عنوان سربرگ اصلی جایگزین شده است.
- سربرگ باید برای دسترسی‌پذیری به‌عنوان header شناخته شود.
- کنترل‌های رفتن به بازه قبل/بعد و «امروز» حفظ می‌شوند.
- ظاهر تقویم باید حرفه‌ای، خوانا و سازگار با زبان و پالت رسمی آروین باشد.

## 8) تست‌های الزامی
- روزانه: گذشته/امروز/آینده.
- هفتگی و ماهانه.
- intervalهای ۲۰ دقیقه، ۹۰ دقیقه، ۱ ساعت، ۲ ساعت و مرز نیمه‌شب.
- تغییر/حذف recurrence و جلوگیری از duplicate.
- Home با یک کارت canonical.
- auto-reminder با toggle روشن/خاموش.
- Calendar Provider create/update/delete و duplicate prevention.
- Persian RTL/digits و سربرگ ماه، شامل «مهر ۱۴۰۵».
- Analyze + full Test + Debug/Release Build + exact-head Device Smoke.

## 9) Architecture Gate
قبل از تغییر مدل، storage یا recurrence engine باید بازبینی معماری DeepSeek طبق قرارداد Issue #2042 انجام شود. تا فراهم‌شدن آن، فقط audit، contract و تست‌های غیرمخرب و UI مستقل مجاز است. ایجاد storage/model/repository/engine موازی ممنوع است.

## 10) وضعیت اثبات‌شده
UX سربرگ ماه شمسی در شاخه کاری پیاده شده و خطای syntax ناشی از commit قبلی نیز در HEAD b573d391... اصلاح شده است. CI برای همین HEAD در حال اعتبارسنجی است؛ تا سبزشدن کامل Build/Tests/Device Smoke، release-ready ادعا نمی‌شود.

## منابع canonical
- Issue #2042: قرارداد recurrence/calendar/reminder
- Issue #2045: اجرای recurrence + Calendar UX
- Calendar Provider acceptance: integration_test/android_calendar_provider_acceptance_test.dart