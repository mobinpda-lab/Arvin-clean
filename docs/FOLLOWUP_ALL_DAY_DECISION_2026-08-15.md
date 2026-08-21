# تصمیم FollowUp بدون ساعت — 2026-08-15

## تصمیم

یک FollowUp می‌تواند فقط برای یک **روز مشخص** ثبت شود و ساعت برای کاربر اجباری نباشد.

- تاریخ: اجباری
- ساعت: اختیاری
- گزینه کاربری: **تمام‌روز / بدون ساعت**
- Reminder مستقل از FollowUp باقی می‌ماند و در صورت نیاز می‌تواند ساعت خودش را داشته باشد.

## قرارداد داده

`FollowUp.dateTime` برای سازگاری با داده‌های قبلی حفظ شده و فیلد additive زیر اضافه شده است:

`allDay: bool`

برای `allDay=true` لایه‌های UI، Home، Widget، PDF و Print نباید ساعت `dateTime` را نمایش دهند. تاریخ همچنان همان تاریخ پیگیری است.

JSON قدیمی که `allDay` ندارد، به‌صورت خودکار `false` در نظر گرفته می‌شود؛ بنابراین migration مخرب یا Storage موازی ایجاد نمی‌شود.

## دلیل انتخاب

تبدیل `dateTime` به nullable یا ایجاد مدل دوم برای Date-only در این مرحله باعث تغییر گسترده‌تر در Persistence و نمایش می‌شد. قرارداد additive فعلی کوچک‌تر، backward-compatible و قابل توسعه برای UI است.

## گام‌های بعدی

1. UI انتخاب تاریخ/ساعت با گزینه «تمام‌روز».
2. نمایش Date-only بدون `00:00` در Home، FollowUp Office، Widget، PDF و Print.
3. تست Reminder مستقل از FollowUp date-only.
4. regression روی migration و داده‌های قدیمی.

این تصمیم **فقط قرارداد Domain/Persistence** را تثبیت می‌کند؛ تا تکمیل UI و regression، قابلیت End-to-End محسوب نمی‌شود.
