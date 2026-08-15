# Arvin — Product Extension Roadmap — 2026-08-15

## هدف
این سند قابلیت‌های پیشنهادی جدید را با وضعیت واقعی `Arvin-clean` تطبیق می‌دهد تا توسعه آینده بدون دوباره‌کاری و بدون ایجاد مدل/Storage موازی انجام شود.

این سند **Feature implementation مستقیم نیست**؛ یک قرارداد توسعه است. هر قابلیت فقط پس از بسته‌شدن Gap واقعی و عبور از Gateهای فعلی وارد implementation می‌شود.

## اصل معماری
همه قابلیت‌های این سند باید روی همان هسته موجود ساخته شوند:

`Unified Item → Reminder → FollowUps[] → History`

ایجاد Task/Note/CRM/Memory/Voice Storage یا Repository موازی ممنوع است مگر اینکه در یک audit معماری جدید، ضرورت آن ثابت و صریحاً تصویب شود.

## تطبیق با وضعیت فعلی
- Unified Item / FollowUps[] منبع حقیقت فعلی است و هنوز Gate A (adapter/migration بدون شکستن Legacy) گلوگاه معماری است.
- Calendar Foundation و `CalendarReminder` موجود است؛ Provider واقعی اوقات شرعی و تعطیلات رسمی ایران هنوز Gap فعال است.
- FollowUp chain و Quick FollowUp Widget به‌عنوان Use Case محصولی ثبت شده‌اند.
- Widget Foundation native هنوز Gate است؛ قابلیت‌های جدید نباید آن را دور بزنند.
- Definition of Done فعلی شامل domain/application، persistence، UI واقعی، RTL/شمسی/فونت، regression tests، CI سبز، APK قابل استفاده و مستندات/AI handoff است.

## قابلیت‌های پیشنهادی و مسیر اتصال

| # | قابلیت | وضعیت نسبت به آروین | مسیر ادغام پیشنهادی | اولویت |
|---|---|---|---|---|
| 1 | Next Action هوشمند | جدید | روی Item/FollowUp؛ بدون مدل موازی | P1 |
| 2 | FollowUp خودکار | foundation نزدیک موجود | روی `FollowUps[]` و Reminder موجود | P1 |
| 3 | Timeline کامل هر موضوع | بخشی از History موجود | تکمیل UI/Query روی همان Item | P1 |
| 4 | Voice Capture فارسی | roadmap فعلی دارد | Voice → parser → Unified Item/Reminder/FollowUp | P1 |
| 5 | دستیار هوشمند آروین | جدید | فقط روی داده و APIهای رسمی فعلی؛ بدون AI database موازی | P2 |
| 6 | People / Contacts | جدید | رابطه اختیاری Item ↔ Person؛ طراحی بعد از Gate A | P1 |
| 7 | جستجوی معنایی | SearchService موجود | ارتقای SearchService؛ حفظ مسیر فعلی Search | P1 |
| 8 | Weekly Review هوشمند | جدید | query روی Item/FollowUp/Reminder؛ خروجی read-only/قابل اقدام | P2 |
| 9 | Memory آروین | جدید | استخراج از History/Notes فعلی؛ بدون حافظه ذخیره‌سازی موازی | P2 |
| 10 | وضعیت «منتظر پاسخ دیگران» | جدید | status/state روی Item یا FollowUp پس از audit مدل | P1 |
| 11 | Quick Capture | با Voice/Quick Add هم‌راستا | توسعه Quick Add موجود؛ یک ورودی واحد | P1 |
| 12 | Smart Calendar Assistant | وابسته به Calendar | روی CalendarReminder و Eventهای مجاز | P2 |
| 13 | تشخیص تداخل و زمان‌بندی هوشمند | جدید | روی Calendar/Reminder؛ بدون Calendar موازی | P2 |
| 14 | Rescheduling هوشمند | جدید | روی Reminder موجود و تاریخ/ساعت رسمی Item | P2 |
| 15 | Goal → Project → Item | جدید | ابتدا contract دامنه؛ سپس اتصال به Unified Item | P2 |
| 16 | Reminder مکانی | جدید | لایه trigger روی Reminder موجود؛ بدون Storage موازی | P3 |
| 17 | Privacy / Encryption | نیازمندی cross-cutting | بررسی persistence/Backup/Restore و secrets | P1 |
| 18 | Sync و Backup چنددستگاهی | foundation موجود | تکمیل Backup/Restore/Dropbox؛ توسعه sync بعد از audit | P1 |
| 19 | Personal Assistant بومی ایران | چشم‌انداز محصول | ترکیب Calendar/Prayer/Holidays/RTL/Voice/Assistant روی هسته واحد | P2 |

## ترتیب اجرای پیشنهادی

### Wave X0 — بدون تغییر محصولی
1. ثبت این قرارداد در roadmap.
2. بررسی وابستگی هر قابلیت به Gateهای A تا H.
3. تبدیل قابلیت‌های P1 به issue/acceptance criteria مستقل.
4. جلوگیری از هر implementation موازی که foundation مشترک را دور بزند.

### Wave X1 — هم‌راستا با جریان فعلی
- Next Action و FollowUp خودکار: فقط پس از تثبیت contract FollowUp و بدون مدل جدید.
- Timeline: تکمیل روی History فعلی.
- People/Contacts: ابتدا contract رابطه، بدون تغییر سنگین persistence.
- Semantic Search: آماده‌سازی روی SearchService موجود.
- Waiting for Response: ابتدا contract state روی Item/FollowUp.
- Quick Capture: تکمیل روی Quick Add/Voice path موجود.
- Privacy/Encryption: audit داده و Backup پیش از هر implementation.

### Wave X2 — بعد از بسته‌شدن گلوگاه‌های فعلی
- Voice Capture فارسی.
- Smart Calendar Assistant.
- Conflict Detection.
- Rescheduling.
- Weekly Review.
- Sync چنددستگاهی.

### Wave X3 — لایه هوشمند محصول
- AI Assistant.
- Memory.
- Goal → Project → Item.
- Personal Assistant بومی ایران.

## قوانین جلوگیری از دوباره‌کاری
1. قابلیت موجود دوباره ساخته نمی‌شود؛ ابتدا `main`، کد واقعی، PR/CI و مستندات بررسی می‌شوند.
2. هیچ قابلیت جدیدی حق ساخت Repository/Database/Storage موازی برای Task، Note، FollowUp، Reminder یا Memory ندارد مگر با audit معماری مستقل.
3. Voice فقط یک ورودی به Unified Item است، نه یک مدل داده جدید.
4. Semantic Search باید SearchService موجود را ارتقا دهد، نه اینکه موتور جستجوی مستقل محصولی بسازد.
5. People باید ابتدا به‌عنوان رابطه/Context بررسی شود؛ ساخت Personal CRM مستقل ممنوع است تا contract دامنه تثبیت شود.
6. AI Assistant و Memory باید روی داده‌های رسمی و قابل دسترس پروژه کار کنند و نباید منبع حقیقت موازی ایجاد کنند.
7. هر قابلیت باید focused test، regression، CI و در نهایت APK واقعی داشته باشد.

## Definition of Done برای این Extensionها
یک قابلیت فقط زمانی از این Backlog خارج می‌شود که:
- Gap و acceptance criteria آن مشخص باشد.
- با Unified Item/Reminder/FollowUp سازگار باشد.
- domain/application و persistence لازم تکمیل شده باشد.
- UI واقعی، RTL، شمسی و فونت اصلی رعایت شده باشد.
- regression/E2E تست داشته باشد.
- Workflow مربوط سبز باشد.
- APK واقعی در صورت نیاز validation شود.
- `PROJECT_STATUS.md` و `AI_HANDOFF_CURRENT_FA.md` به‌روزرسانی شوند.

## تصمیم اجرایی
این Extensionها به‌عنوان **جریان توسعه آینده رسمی** ثبت می‌شوند، اما تا زمانی که Gateهای فعلی بسته نشده‌اند، فقط کارهای contract/test/preparation که foundation مشترک را تغییر نمی‌دهند به‌صورت موازی آماده می‌شوند. هدف، افزایش سرعت بدون ایجاد بدهی معماری است.

## تاریخ
2026-08-15
