# Arvin Dynamic Theme Palette — implementation checkpoint

**Date:** 2026-11-07  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR:** #3052 — must remain OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO

**Implementation source checkpoint:** `ccf51e22fcb068cf803237d154cf6f539ad4ac46` (before this documentation synchronization commit)

## Implemented in source

- Added `AppThemeManager`, a ChangeNotifier-backed owner for the selected accent color.
- Added the nine approved palette entries and SharedPreferences key `arvin.settings.primaryColor`.
- The default when no valid selection exists is palette option 8, `#3A86EF`.
- Unsupported or stale color values are not restored; the manager falls back to the approved default.
- Added the palette grid to Settings under «انتخاب تم و رنگ اصلی برنامه».
- Selecting a swatch saves the choice and notifies the app root; light and dark Material color schemes, app bar, navigation, chips, progress indicators, buttons and focused input borders derive from the selected accent.
- Updated the canonical static fallback brand token and its soft surface from the former turquoise default to vivid sky blue.
- The selected accent also drives the dark app bar and focused input border.
- Added focused tests for the default, supported palette, persistence/restore, invalid color rejection and Settings selection.

## Important acceptance distinction

This checkpoint records source changes only. It does not claim successful compilation, passing tests, full repository-wide replacement of every custom hard-coded accent, visual acceptance at 360/390/412dp, or physical-device acceptance on Samsung SM-A528B/DS. The existing custom widgets that still consume static semantic color constants require a full audit before describing every screen as fully palette-reactive.

## Required next evidence

1. Exact-HEAD Analyze and all test shards.
2. Debug/Review APK build and artifact inspection.
3. Layout checks at 360, 390 and 412dp, portrait, including settings palette and representative forms.
4. Physical install and live color-switch/restart persistence test on Samsung SM-A528B/DS.
5. Update this checkpoint with actual run IDs, artifact digests, device evidence and the final commit SHA.

No changes to `main`, merge, publication or release are authorized.


## 2026-11-07 — ادامه اصلاح تجربه کاربری تم و کنترل‌های زمان (شواهد پذیرش در انتظار)

**Source checkpoint before documentation sync:** `9e66820d161131b947bcc91cf333b3acf426a51c`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31` · **PR #3052:** OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO

### تغییرات ثبت‌شده
- پالت انتخابی کاربر در `AppThemeManager` بدون تغییر باقی مانده است: گزینه ۸ و پیش‌فرض `#3A86EF`. توکن‌های پایهٔ فیروزه‌ای رابط (`#078B91`، `#066F75`، `#DDF7F5`) از رنگ انتخابی کاربر جدا شده‌اند؛ این کار پیش‌فرض پالت را تغییر نمی‌دهد و سطوح روشن/فیروزه‌ای را از accent انتخابی مستقل نگه می‌دارد. Source: `lib/core/theme/arvin_theme.dart`، commit `a58098c0a6a6afcc55ec194a751961fd1bad9848`.
- رنگ زندهٔ Theme به Home filter pill/card/chip و sheet، پوستهٔ Home، دکمهٔ افزودن، انتخاب‌گرهای taxonomy، Quick Capture، Task Details و کنترل‌های Report Center متصل شد. Source commits: `93d4cf75`, `a133fa8a`, `1e9db5fe`, `f7f3ceca`, `901078af`, `7932da2e`, `2261d28d`, `a2d54f27`, `fb47dfba`, `62b82598`, `89e7e914`, `01caa0d4`, `561a8b2e`, `dd968b25`, `9e66820d`.
- ترتیب پنج فیلتر Home در ردیف RTL از راست به چپ به زمان، مرکز، پروژه، دسته و برچسب تنظیم شد و کل ردیف کلید آزمون پایدار گرفت. Source: `lib/main.dart`, commit `dffefdd1bd0e32e1405f3c7a95fa405263eafd3d`.
- کنترل موعد Task Editor و Quick Capture از فهرست میانی انتخاب‌ها خارج شد: لمس کنترل مستقیماً تقویم شمسی را باز می‌کند و پس از تأیید تاریخ، ساعت‌گرد باز می‌شود. انتخاب «بدون ساعت» همچنان فقط داخل ساعت‌گرد است؛ لغو انتخاب ساعت، تاریخ نیمه‌کاره را ثبت نمی‌کند. Source commits: Task Editor `5650c5e152465c6df557739a130c42a887f5eb6d`، Quick Capture `65c319f2cf265dc4e6a06d88fa97ed18b0a5b198`.
- رنگ برند Task Details و Task Editor به Theme زنده متصل شد. Source commits: `6cff0d92`, `aff66d4e`.
- آزمون Home برای ردیف پنج‌فیلتر از انتظار Wrap قدیمی به قرارداد تک‌ردیفهٔ بدون پیمایش افقی در ۳۶۰/۳۹۰/۴۱۲dp و کیبورد باز تغییر کرد؛ حداقل عرض/ارتفاع ۴۸dp و نبود overflow بررسی می‌شود. Test commit: `ce0c68097d2bc183785c755aa5c6b2a27bb20e8f`؛ import test: `ed7a4c7f0735f1f703d5650819cdd4f4a272c069`.
- آزمون Theme filter به‌جای ActionChip قدیمی، رنگ زندهٔ Theme و هدف لمس ۴۸dp را برای کامپوننت واقعی می‌سنجد. Test commit: `d9b2df3ab6e5cdf5cb0588b8abc729ee5a2e6797`.
- آزمون‌های Task Editor و Quick Capture برای جریان تک‌لمسی تاریخ ← ساعت‌گرد و «بدون ساعت» به‌روزرسانی شدند؛ test commits: `8235c5142ff94205a484054caae62538ca6cda54` و `0ebf6790579caaec031ffed38324975b087b45e8`.

### وضعیت پذیرش و موارد باز
- Analyze روی SHA پیشین `8300e473a49c4e0b574cfd764ba31baf0ee472e3` PASS بود؛ هر شش Shard همان SHA FAIL بودند. این نتایج برای source checkpoint حاضر معتبر نیستند.
- Build/Review/Device Smoke برای source checkpoint حاضر در لحظهٔ ثبت هنوز نتیجهٔ نهایی نداشتند؛ اجرای بعدی پس از این ثبت اسناد باید روی SHA نهایی خوانده شود. هیچ PASS به این SHA منتقل نمی‌شود.
- رنگ زنده در تمام مصرف‌کننده‌های اختصاصی، Report Center و سایر فرم‌ها هنوز نیازمند ممیزی/آزمون کامل است؛ وضعیت را «اتصال بخش‌های نام‌برده‌شده انجام شده، پذیرش سراسری تأییدنشده» نگه دارید.
- آزمون‌های person-specific FollowUp/Report، category clear، Reminder All-Day، ردیف Home و چند تست Quick Capture/Task Editor در Run قبلی شکست داشتند؛ علت‌ها و اصلاحات باید با Run تازه بررسی شوند. تست‌های مربوط به زمان و تمام‌روز فقط روی SHA دقیق خودشان معتبرند.
- همگام‌سازی محلی P2P همچنان در حد طراحی/برنامه است؛ امنیت جفت‌سازی، لغو دسترسی، تعارض و انتقال دوسویه روی دو دستگاه اثبات نشده است. فاز ابری برنامهٔ آینده است.
- Device Smoke فیزیکی و تصویر نصب/تعامل روی Samsung SM-A528B/DS تأییدنشده است.

PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده؛ بدون Merge یا انتشار؛ فونت Vazirmatn و قرارداد SVG عبارات مقدس حفظ شود. **BLOCKED — RELEASE: NO-GO**.
