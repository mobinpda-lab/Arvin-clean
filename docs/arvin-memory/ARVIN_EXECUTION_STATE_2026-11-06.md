# ARVIN — دفتر وضعیت محصول و گیت انتشار
## به‌روزرسانی ۱۴۰۵/۰۸/۱۵ — ممیزی PR #3052

**مخزن:** `mobinpda-lab/Arvin-clean`  
**شاخه:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**SHA شواهد:** `19fcb58e17f51624dd69b1047f7ddfcbeec77c5a`  
**PR #3052:** OPEN / DRAFT / UNMERGED  
**Base/main مشاهده‌شده:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**تصمیم انتشار:** **BLOCKED — RELEASE: NO-GO**

## دفتر گیت‌ها

| گیت | Run | وضعیت محصول |
|---|---:|---|
| Build / Analyze | 42282761205 | Analyze PASS؛ اما کل Build به علت ۲۳ شکست آزمون، FAIL |
| Debug APK build | 42282761205 | ساخت موفق؛ پذیرش محصول نیست |
| Release APK build | 42282761205 | ساخت موفق؛ این Job به‌تنهایی امضای تولید را اثبات نمی‌کند |
| Draft Review APK | 42282761255 | PASS برای artifact بازبینی و نصب آزمایشی؛ NOT publishable |
| Vazirmatn bundle | 42282761255 | Regular / Medium / Bold در APK واقعی موجود |
| Signature | 42282761255 | v2 و v3 تأیید؛ کلید موقت Review-only |
| Calendar Provider | 42282761379 | PASS در Emulator برای CRUD واقعی Provider |
| Device Smoke | 42282761181 | PENDING؛ بدون Job/Artifact |
| Physical device install | — | NOT VERIFIED |
| UX viewport matrix | — | NOT RUN / NOT VERIFIED |
| Product owner visual acceptance | — | NOT VERIFIED |

## APK بازبینی
- فایل واقعی: `Arvin-review-staging-19fcb58e17f51624dd69b1047f7ddfcbeec77c5a.apk`
- SHA-256: `44f1908cdb47571229e96b78efc9a52e7953900cdd9433a55a220d2a6dee8fcd`
- اندازه: 79,038,285 bytes
- Package: `com.example.arvin.staging`
- `debuggable=false`
- v2/v3 verified
- Vazirmatn Regular / Medium / Bold present
- ephemeral test signing key؛ `publishable=false`

این APK فقط برای Review و نصب آزمایشی است؛ امضای تولیدی یا مجوز انتشار نیست.

## شکاف‌های محصولی باز
1. **Calendar:** خطای ارتفاع نمای ماه و Render در جابه‌جایی دوره‌ها؛ assertion تکراری تاریخ.
2. **Reports:** پنل بازه دقیق، ردیف‌های منتظر پاسخ به تفکیک شخص، و تعداد فیلترهای فعال.
3. **Home:** کلید اسکرول فیلترها در آزمون‌ها یافت نمی‌شود؛ بررسی تطابق ساختار فعلی با قرارداد پنج فیلتر لازم است.
4. **Task Editor:** سرریز افقی ۵۳dp در آزمون ثبت‌شده.
5. **Quick Add:** مسیر ساخت پروژه جدید در آزمون جاری پیدا نشده است.
6. **UX پذیرش:** ماتریس ۳۶۰/۳۹۰/۴۱۲dp با کیبورد باز/بسته و اندازه هدف‌های لمسی هنوز اجرا نشده است.
7. **Device:** نتیجه کامل Device Smoke و نصب روی گوشی واقعی وجود ندارد.

## قواعد تصمیم
- وضعیت‌های PENDING / QUEUED / WAITING / CANCELLED هرگز PASS محسوب نمی‌شوند.
- PASS فقط به SHA و Run دقیق همان مدرک تعلق دارد.
- تغییر مستندات نیز HEAD جدید می‌سازد؛ پس از این checkpoint باید تمام CI روی SHA نهایی مستندات/کد دوباره اجرا شود.
- هیچ تستی حذف، skip، bypass یا تضعیف نمی‌شود.
- تا وقتی همه گیت‌ها روی یک SHA نهایی پاس نشده و نصب/پذیرش گوشی واقعی ثبت نشده است، Release ممنوع است.

**وضعیت فعلی:** BLOCKED — RELEASE: NO-GO  
**محدودیت حاکمیتی:** PR OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ Merge ممنوع.
