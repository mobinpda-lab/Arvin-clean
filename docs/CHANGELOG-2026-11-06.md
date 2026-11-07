# CHANGELOG — 2026-11-06 (PR #3052 exact-SHA audit)

**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Evidence code SHA:** `19fcb58e17f51624dd69b1047f7ddfcbeec77c5a`  
**Evidence checkpoint:** `docs/project-continuity/ARVIN_PR3052_CHECKPOINT_2026-11-06_SHA-19fcb58.md`

## Verified on the evidence SHA
- Draft Review APK workflow #803 / run `42282761255` succeeded. A real review-only staging APK was downloaded and inspected. APK SHA-256: `44f1908cdb47571229e96b78efc9a52e7953900cdd9433a55a220d2a6dee8fcd`; size: 79,038,285 bytes; package `com.example.arvin.staging`; debuggable=false; v2/v3 signature verified; Vazirmatn Regular/Medium/Bold assets present.
- The APK uses an ephemeral review-only key and is not publishable. No production signing or release was performed.
- Calendar Provider workflow #2131 / run `42282761379` succeeded on the exact SHA. Instrumentation verified CREATE, no-op update without duplication, update of the same event, delete, and survival of the canonical Task after provider-event deletion.

## Failed or incomplete evidence
- Build #9993 / run `42282761205`: Analyze and APK build jobs succeeded, but all six test shards failed (1,317 passed / 23 failed). This run is not a Build PASS.
- Independent Calendar failures include month-view measured height 342dp versus the test's <280dp assertion, rendering failures during period navigation, and a duplicate date-text assertion.
- Independent Reports failures include the exact-range filter panel assertion, person-specific active waiting rows, and active filter chip count.
- Home and form failures include missing `home-compact-filter-scroll` finder key, a 53px right-side Task Editor overflow, Quick Add's missing «ایجاد جدید» control in the tested flow, and additional Home/Category/Project assertions.
- Device Smoke #7229 / run `42282761181` remains PENDING with no jobs/artifacts. It is not accepted.
- The 360/390/412dp UX matrix with keyboard open/closed has not been executed in this checkpoint; no layout or touch-target PASS is claimed.

## Governance
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- main remains untouched; no merge, publication or release.
- Release decision remains **BLOCKED — RELEASE: NO-GO**.
- No test was removed, skipped, bypassed or weakened. This entry records observed evidence; it does not claim the outstanding code fixes are complete.


## 2026-11-07 — Dynamic theme palette implementation (acceptance pending)

- Added a ChangeNotifier-backed `AppThemeManager` with the nine approved accent colors and SharedPreferences key `arvin.settings.primaryColor`.
- The no-selection default is option 8, Vivid Sky Blue `#3A86EF`; unsupported stored values fall back to this default.
- Added «انتخاب تم و رنگ اصلی برنامه» to Settings. Selecting a swatch persists the value and notifies the app root for live Material theme rebuilding.
- Light/dark ColorScheme, both app bars, focused input borders and primary Material component themes now use the selected accent. The canonical static fallback brand token and its soft surface are also Vivid Sky Blue.
- Invalid legacy accent values are removed from SharedPreferences and replaced by the default on load.
- Added focused manager and Settings widget tests. These tests are source additions only; exact-HEAD CI has not yet established PASS.
- Repository-wide custom accent usage and full-screen reactivity remain subject to further audit; no claim of complete visual migration is made here.
- 360/390/412dp geometry, physical Samsung SM-A528B/DS installation, restart persistence, and screenshot acceptance remain NOT VERIFIED.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched. **BLOCKED — RELEASE: NO-GO.**


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
