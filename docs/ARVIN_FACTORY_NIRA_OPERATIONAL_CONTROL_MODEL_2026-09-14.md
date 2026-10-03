# ARVIN Factory + NIRA Operational Control Model

## اصل راهبردی

کارخانه‌ها وسیله هستند؛ آروین محصول نهایی است.

این سند مرجع هماهنگی بین محصول آروین، چرخه‌های داخلی آن، کارخانه آروین، نیرا و GitHub است.

## نقش‌ها

### Arvin Product

محصول نهایی کاربر است:

- تجربه کاربری
- داده واقعی
- پایداری
- قابلیت انتشار

### Arvin Factory

سیستم کنترل اجرای پروژه:

```
Observe
↓
Analyze
↓
Plan
↓
Execute
↓
Validate
↓
Record Evidence
↓
Next Cycle
```

### NIRA

موتور Reconcile و کنترل خودکار:

- بررسی اختلاف سند و وضعیت واقعی
- تشخیص انحراف
- ایجاد اقدام اصلاحی
- کنترل کیفیت
- گزارش سلامت

## چرخه داخلی آروین

چرخه‌های اصلی محصول:

- Task lifecycle
- FollowUp lifecycle
- Reminder lifecycle
- Recurrence lifecycle
- Archive lifecycle
- Trash lifecycle
- Notebook lifecycle
- Calendar lifecycle
- Sync lifecycle

هر چرخه باید وضعیت قابل مشاهده و نتیجه قابل بررسی داشته باشد.

## چرخه Reconcile

الگوی کنترل:

```
Current State
↓
Expected State
↓
Gap Detection
↓
Safe Action
↓
Test
↓
Evidence
```

## چرخه‌های زمان‌بندی‌شده

چرخه‌های دوره‌ای می‌توانند برای:

- بررسی سلامت پروژه
- بررسی خطاها
- بررسی تست‌ها
- بررسی انحراف معماری
- تهیه گزارش وضعیت

استفاده شوند.

## GitHub به عنوان سیستم کنترل تغییر

هر تغییر مهم:

```
Branch
↓
Commit
↓
Review
↓
Test
↓
Merge
```

را طی می‌کند.

## قوانین غیرقابل نقض

- کارخانه جای محصول را نمی‌گیرد.
- اتوماسیون بدون اعتبارسنجی اجازه تغییر مخرب ندارد.
- مدل‌های اصلی داده آروین حفظ می‌شوند.
- قابلیت فقط با کد واقعی، تست و شواهد کامل محسوب می‌شود.

## معیار آمادگی تولید

```
Documented
↓
Implemented
↓
Real Data Connected
↓
Tested
↓
Android Verified
↓
Released
```
