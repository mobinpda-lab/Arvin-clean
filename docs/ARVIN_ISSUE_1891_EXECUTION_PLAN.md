# Arvin #1891 — اجرای کنترل‌شده اصلاحات پس از نصب

## هدف
اجرای واقعی اصلاحات گزارش‌شده توسط مالک محصول، بدون معرفی زودهنگام APK به‌عنوان نسخه نهایی.

## Lane A — Quick Add / Scheduling
- Bottom Sheet و ثبت سه Task پیاپی
- Project / Category / Tag Roll Box
- انتخاب Tagهای موجود
- Create + Select فوری و مستقل
- Due Date + Time
- Reminder Date + Time
- رفع Date Picker صفحه خالی
- Recurrence
- حفظ Draft هنگام خطا

## Lane B — Taxonomy
- سه موجودیت canonical: Project / Category / Tag؛ «گروه» موجودیت مستقلی نیست و در واژگان محصول همان «دسته» است.
- Category/Tag/Project ساخته‌شده بدون انتخاب فعلی حذف نشود
- Refresh فوری
- Tag چندانتخابی با checkbox
- بدون Storage/Model/Store موازی

## Lane C — Swipe
- چپ و راست مستقل
- Task → FollowUp
- same ID / no duplicate
- Archive/Trash مستقل باقی بماند
- RTL و هر دو جهت در Device Smoke

## Lane D — Color / Accessibility
- Time orange
- Reminder gold
- Project blue
- Category purple
- Tag teal
- Error/Overdue red
- Neutral gray
- Brand indigo
- state tokens و non-color indicators
- WCAG AA در نقاط تعاملی اصلی

## ترتیب ادغام
A/B/C/D مستقل اجرا شوند؛ تست‌های هر lane همراه همان تغییر اضافه شوند. سپس Integration و full validation.

## گیت‌های اجباری
1. Code/diff review
2. Analyze
3. Full tests
4. Debug build
5. Release build
6. Android Device Smoke
7. exact final HEAD verification
8. artifact verification
9. APK delivery

## ممنوع
- direct main change
- rewrite
- parallel storage/model
- reuse of old APK as proof
- claim of completion without exact-head evidence

## Physical-device note
پس از APK جدید، نصب واقعی مالک محصول برای Swipe/RTL/Date-Time/Reminder/Roll Box لازم است؛ CI/Emulator به‌تنهایی جایگزین آن نیست.
