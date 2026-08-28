# قرارداد نهایی مالک — کار پیگیری‌دار آروین

تاریخ ثبت: 2026-08-28

این سند مرجع پذیرش نهایی تجربه «کار پیگیری‌دار» است و باید همراه Issue #357، `docs/PRODUCT_CONTRACT_MATRIX.md` و وضعیت واقعی `main` خوانده شود. GitHub reality بر snapshotهای قدیمی مقدم است.

## مدل و منبع حقیقت
- یک Task پیگیری‌دار همان Task اصلی و ثابت است.
- هر ثبت جدید یک FollowUp جدید داخل همان `Task.followUps[]` است.
- ثبت FollowUp نباید Task جدید بسازد.
- FollowUpهای قبلی حذف یا جایگزین نمی‌شوند؛ ویرایش یک FollowUp همان id را درجا اصلاح می‌کند.
- منبع حقیقت: `Task`, `FollowUp`, `TaskStore`, `arvin.tasks`.
- هیچ مدل/storage/database دوم برای این قابلیت مجاز نیست.

## صفحه جزئیات کار پیگیری‌دار
- Home با لمس کارت، صفحه جزئیات read/view را باز می‌کند؛ ویرایش یک اقدام جداست.
- عنوان و توضیح Task نمایش داده شوند.
- آخرین FollowUp واقعی نمایش داده شود؛ تاریخ اولیه/legacy scheduling نباید جای FollowUp واقعی را بگیرد.
- تاریخ دقیق: هجری شمسی با ارقام فارسی.
- ساعت: با ارقام فارسی.
- زمان گذشته از آخرین FollowUp از `deviceNow - latest FollowUp.dateTime` مشتق شود و persist نشود.
- تاریخچه FollowUpها newest-first باشد.
- برای هر FollowUp به‌جز قدیمی‌ترین، فاصله تا FollowUp قبلی از timestamps محاسبه شود و persist نشود.
- نتیجه/وضعیت قابل نمایش باشد؛ از جمله «منتظر پاسخ».
- اگر history خالی است: `هنوز پیگیری ثبت نشده است`.
- دکمه گرد `+` برای Task پیگیری‌دار واضح و در دسترس باشد.
- Task و FollowUpها قابل ویرایش باشند.

## ثبت پیگیری جدید
- `+` صفحه «ثبت پیگیری» را باز کند.
- عنوان/متن FollowUp اختیاری است.
- تاریخ و ساعت با current device date/time prefill شوند.
- کاربر بتواند تاریخ و ساعت را قبل از ذخیره تغییر دهد.
- عنوان خالی validation error نباشد و هنگام ذخیره به `پیگیری` canonicalize شود.
- ذخیره به همان `followUps[]` اضافه شود و Timeline/Home بلافاصله refresh شوند.

## نمایش در Home
- عنوان/توضیح Task.
- آخرین FollowUp واقعی: تاریخ شمسی + ساعت فارسی دقیق همیشه visible.
- relative helper مثل `۳ روز پیش` فقط اطلاعات کمکی است و authoritative نیست.
- اگر FollowUp واقعی وجود ندارد، نباید scheduling/legacy followUpDate به‌عنوان «آخرین پیگیری» جعل شود.

## elapsed / interval
نمونه‌های معتبر:
- `۱۵ دقیقه از آخرین پیگیری گذشته`
- `۲ ساعت و ۱۵ دقیقه از آخرین پیگیری گذشته`
- `۳ روز و ۴ ساعت از آخرین پیگیری گذشته`
- `۲ هفته از آخرین پیگیری گذشته`
- `۱ ماه و ۵ روز از آخرین پیگیری گذشته`
- `فاصله از پیگیری قبلی: ۵ روز و ۳ ساعت`

این مقادیر presentation-only هستند و field جدید ذخیره‌سازی ندارند.

## PDF / Share / Print
برای Tasks باید انتخاب‌های زیر وجود داشته باشد:
- یک Task
- چند Task انتخاب‌شده
- همه Tasks در scope مربوط

برای یک Task پیگیری‌دار، گزارش جزئی باید تمام FollowUpهای canonical آن را به ترتیب مشخص نمایش دهد.
PDF و Print باید یک report projection/template مشترک داشته باشند. Share باید همان محتوای canonical را reuse کند و هیچ مدل یا persistence موازی نسازد. خروجی فارسی/RTL است.

## فونت و زبان
- فونت برنامه: Vazirmatn از پروژه رسمی `rastikerdar/vazirmatn`، با asset/license داخل repository و theme canonical.
- تمام تاریخ‌های user-visible مربوط به FollowUp در تمام surfaceهای فعال: Jalali/Persian.
- تمام ساعت‌های user-visible مربوط: Persian digits.
- RTL و خوانایی viewportهای باریک Android الزامی است.

## Sort و Widget
- مرتب‌سازی explicit بر اساس `Task.lastFollowUpDate` باید قابل انتخاب باشد؛ updatedAt/createdAt/relative elapsed text جای آن را نمی‌گیرد.
- Widget deep-link باید همان Task را مستقیماً در canonical Task Detail باز کند.
- Quick Add FollowUp از Widget قابلیت آینده قابل‌قبول است؛ در صورت اجرا باید همان canonical add flow را reuse کند و storage/model جدید نسازد.

## Gapهای پذیرش در baseline فعلی
این سند requirement را قفل می‌کند؛ وضعیت واقعی باید در Issue/PRهای اجرایی بسته شود:
- #385: Task Detail + add/edit FollowUp + elapsed/interval + widget deep-link.
- #386/#387: Jalali/Persian cleanup برای legacy FollowUp surfaces.
- #369/#388: explicit latest-FollowUp sort؛ UI discoverability/device acceptance هنوز باید بسته شود.
- #357: Home card final latest-FollowUp presentation شامل exact timestamp + optional relative helper و جلوگیری از legacy fallback به‌عنوان real history.
- #367: Notes/Tasks bulk selection + PDF/Share/Print + full FollowUp report acceptance.
- #361: Widget visual/action acceptance؛ Quick Add FollowUp از Widget فعلاً enhancement آینده است.

## Definition of Done
این قابلیت فقط زمانی Done است که:
1. تمام مسیرهای بالا روی canonical model/storage باشند.
2. focused tests سبز باشند.
3. exact-head Fast/Build/APK و Device/visual evidence برای PRهای UI لازم سبز باشد.
4. Home، Detail، Timeline، legacy FollowUp surfaces و exportها تاریخ/زمان فارسی/شمسی سازگار نشان دهند.
5. یک Task با چند FollowUp در PDF/Share/Print هیچ FollowUpی را از دست ندهد.
6. Task و FollowUp edit بدون duplicate/history loss انجام شود.
7. Product Contract Matrix/Handoff با main نهایی reconcile شود.
