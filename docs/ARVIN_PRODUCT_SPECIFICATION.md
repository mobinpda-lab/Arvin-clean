# Arvin Product Specification

## Purpose

آروین یک نرم‌افزار مدیریت کار، پیگیری و سازمان‌دهی اطلاعات شخصی و کاری است.
این سند مرجع محصول است تا طراحی، مستندات و پیاده‌سازی هم‌راستا بمانند.

## Product Areas

- Task Management
- Follow Up Management
- Projects
- Categories
- Tags
- Reminders
- Calendar
- Notebook / Notes
- Backup and Restore
- Multi-device Sync
- Future Intelligence Layer

## Expected Experience

### Home Center

صفحه اصلی مرکز کنترل روزانه کاربر است:

- کارهای امروز
- کارهای فعال
- کارهای انجام‌شده
- کارهای عقب‌افتاده
- جستجو و فیلتر
- دسترسی به پروژه‌ها، دسته‌ها و برچسب‌ها

### Task Detail

هر Task باید شامل:

- عنوان
- توضیح
- پروژه
- دسته
- برچسب
- زمان‌بندی
- یادآوری
- وضعیت
- تاریخچه

### Sync

Sync یک قابلیت مستقل از Backup است و باید شامل:

- همگام‌سازی چند دستگاه
- مدیریت نسخه داده
- مدیریت تعارض
- Retry
- بازیابی امن

## Source of Truth

برای هر توسعه جدید باید این سه مورد با هم بررسی شوند:

1. Product Specification
2. Current Implementation
3. Tests and Evidence

هدف: جلوگیری از اختلاف بین طراحی، مستندات و کد واقعی.
