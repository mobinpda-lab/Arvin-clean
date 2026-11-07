# ARVIN — Implementation checkpoint for the five open gaps
Date: ۱۴۰۵/۰۸/۱۵ — 2026-11-06 (Asia/Tehran)
Repository: mobinpda-lab/Arvin-clean
Authorized branch: fix/recovery-calendar-device-smoke-2026-10-31
Starting branch HEAD: 4e3136e4dde44bd0b41896265d6ddc6423845046
PR: #3052

## Changes committed
- `957f18bf2e5fe8a6f91e950cd963b2a1d03344dd` — `feat(task): add independent center and explicit all-day flow`
  - Added optional canonical `Task.centerId` with backward-compatible JSON serialization/deserialization.
  - Task edit application now preserves the independent Center reference.
  - Full Task Details now has a Center selector and Inline Add backed by `CenterStore`.
  - Quick Capture writes its selected Center into the canonical Task model.
  - Full Task Details uses a chained Jalali date → time flow for both create and edit.
  - Both full form and Quick Capture expose the explicit «بدون ساعت» action, including when no date has yet been selected; Quick Capture can open a Jalali date-only picker directly. The canonical Task persists `allDay=true`; automatic due-time reminder is cleared for all-day tasks.
- `eaddf66fd512e11a1e16bb0e056dac4824699d54` — `feat(report): reuse Home filters and match direct Center IDs`
- `286485ad1d73231dfb2b7f891803026cf190fd87` — `fix(forms): allow date-only selection before choosing a time`
- `1db75c307f357d50d3e5af5fa8c47666ed8d53f5` — `fix(task): preserve independent center semantics and form state`
- `3ac5e55841de027b18b8b2daa8f843fde1cae60a` — `fix(report): scope person filter to active waiting follow-ups`
  - Extracted the Home filter chip presentation into reusable `HomeFilterPill`.
  - Home and Report Center use the same component, with Report Center exposing the five dimensions in Home order: Time, Center, Project, Category, Tags.
  - Home and Report Center matching now recognizes the direct Task Center ID as well as the legacy Project Center association. Direct Task Center takes precedence; when absent, any linked Project Center can match.
  - Person filtering in Report Center now requires an active, incomplete waiting Follow-up carrying the selected stable person ID; a Task-level person relation or an ordinary/non-waiting Follow-up no longer creates a false match.

## Five-gap status
| Gap | Implementation status | Acceptance still required |
|---|---|---|
| 1. Follow-up person → Report Center | Existing Follow-up editor already supports selecting existing people, inline creation through the canonical directory callback, and stable `personIds`. Existing widget tests cover create/edit and person ID persistence. Added a report-projection regression test in this wave. | Exact-head widget/unit CI and verification of canonical directory write path. |
| 2. Chained date/time + no-time | Chained date → time enabled in full form for both new and existing Tasks; Quick Capture custom date selection already chains to time. Added explicit «بدون ساعت» controls and all-day semantics in both entry surfaces. | Exact-head tests, serialization checks and visual/device acceptance. |
| 3. Center selector + Inline Add | Added direct optional `Task.centerId`, JSON persistence, full form selector and canonical CenterStore Inline Add; Quick Capture now persists its selected Center. | Exact-head analyze/tests, existing-task round-trip and backup compatibility tests. |
| 4. Shared five filters | Extracted shared `HomeFilterPill` and reused it in Report Center in the same five-filter order; direct Task Center IDs participate in Home and Report Center matching. | Widget tests for navigation, filter selection and combined AND semantics. |
| 5. Tests, analyze and continuity | Added focused regression tests for Task Center/all-day serialization, edit application, direct Center report filtering, personId report projection, Quick Capture's explicit all-day action, full-form Center selection, and Report Center's waiting-only person match. | Flutter analyze and complete test suite must pass on the final exact HEAD; no local Flutter SDK was available in this execution environment. |

## Validation and governance
- The source commits above were pushed only to the authorized branch.
- `flutter analyze` has **not** been claimed as passed; exact-head CI is the validation gate.
- Do not reuse earlier workflow results from older SHAs.
- PR #3052 must remain OPEN / DRAFT / UNMERGED.
- No main-branch edit, merge, publication or release is authorized.
- Release remains **BLOCKED — RELEASE: NO-GO** until exact-head CI and owner device acceptance pass.

## Latest exact-head checkpoint
- Latest code/test HEAD at this documentation update: `3ac5e55841de027b18b8b2daa8f843fde1cae60a`.
- `flutter analyze` and full test suite: pending GitHub Actions for this exact HEAD; do not mark PASS until the Build workflow completes.
- The current change explicitly narrows Report Center's selected-person filter to active waiting Follow-ups and has a regression test distinguishing waiting from ordinary Follow-ups.
- PR #3052 must remain OPEN / DRAFT / UNMERGED. No main edit or merge is authorized.


## Exact HEAD continuation — 2026-11-06 22:24 Asia/Tehran
- Authorized branch advanced through df5295fe2464d99cc5b2abe83515822ee7c136af and 5f8cfefcb849816f3d16936f4b6bbb0f77c4cf68.
- df5295fe: preserve Home no-Center matching, make full-form taxonomy controls responsive at larger text scale, keep Quick Capture priority unset by default, and omit the Gregorian year in the selected-day summary.
- 5f8cfef: align focused regression tests for date-only/time affordance, Semantics time label, RTL wrapping, unset Quick Capture priority, vertical scrollable discovery, scoped Home chip styling and Report Center filter-sheet scrolling.
- These are follow-up hardening/test-contract commits; they do not by themselves close all five gaps or prove device acceptance.
- Exact-HEAD workflows: Build 42274180002 pending; Draft Review APK 42274179979 in progress; Calendar Provider 42274179939 in progress; Device Smoke 42274179896 pending. No PASS is recorded before completion on this exact SHA.
- A prior assistant message showed a sandbox APK path for SHA 7644fc08; that path was not verified in this execution context. Do not treat it as a valid downloadable artifact. New-head APK and APK SHA-256 remain pending artifact publication and verification.
- PR #3052 verified OPEN / DRAFT / UNMERGED at HEAD 5f8cfefcb849816f3d16936f4b6bbb0f77c4cf68. No main update or merge.
- Release remains BLOCKED — RELEASE: NO-GO pending exact-head CI, verified APK artifact and owner physical-device acceptance.


---

## ابلاغ Master و وضعیت اجرایی — ARVIN-DIR-1405/08/16-02-MASTER
**ثبت: ۱۴۰۵/۰۸/۱۶ | شاخه مجاز PR #3052**

- PRODUCT FIRST: نقص محصول در کد محصول رفع می‌شود؛ هیچ آزمونی حذف، Skip یا تضعیف نمی‌شود. اصلاح Finder فقط برای قرارداد واقعاً منسوخ و با حفظ پوشش رفتاری مجاز است.
- فونت یگانه رابط: **Vazirmatn**؛ بررسی `pubspec.yaml`، `lib/theme/app_fonts.dart` و `lib/theme/font_registry.dart` فقط همین خانواده را نشان می‌دهد.
- تم روشن فیروزه‌ای: Primary `#078B91`، Header `#066F75`، Soft `#DDF7F5`، Background `#F0FAF9`، Border `#D9ECEA`. رنگ‌های خطا/اولویت و وضعیت برای معنای وضعیت حفظ می‌شوند.
- SVG بسم‌الله با عرض نمایشی `210dp` حفظ شده؛ آزمون عرض ۲۱۰dp اضافه شده است.
- ترتیب فیلترهای Home: زمان ← مرکز ← پروژه ← دسته ← برچسب؛ مرتب‌سازی جدا و پس از پنج فیلتر است؛ Wrap راست‌به‌چپ و بدون پیمایش افقی.
- «پیگیری‌های انجام‌شده» فقط از بخش «نوع گزارش» در پنل فیلترها انتخاب می‌شود؛ دکمهٔ بالای صفحه وجود ندارد و آزمون آن را کنترل می‌کند.
- Calendar: محتوای سلول ماه درون سلول مقیاس می‌شود و هدف لمس حداقل ۴۸dp حفظ می‌شود؛ ارتفاع اضافهٔ نمای هفتگی کاهش یافته است.
- Task Editor و Quick Capture برای ۳۶۰/۳۹۰/۴۱۲dp، کیبورد باز/بسته و متن بزرگ پوشش آزمون دارند؛ کنترل‌های اولویت Quick Add حداقل ۴۸dp هستند.
- ایجاد مرکز/دسته/برچسب در Quick Capture دیگر کنترل متن موقت را پیش از پایان انیمیشن Sheet آزاد نمی‌کند؛ Sheetها قابل پیمایش‌اند.
- کامیت‌های کد/آزمون: `9de8f221`, `7125e828`, `895c7ad`, `21606a9`, `9946f15`, `4a64d50`, `4f65800`.
- Build روی SHA قبلی `21606a9f3050337d57c0ada2ca4c14c2febe907f` به‌علت توکن تعریف‌نشدهٔ `ArvinTheme.primarySoft` در Analyze/Visual و شاردها شکست کامپایل داشت؛ Follow-up Persistence run `42339727992` نیز به همان علت شکست خورد. توکن مرکزی در commit `4a64d50` تعریف شد؛ نتایج SHA قدیمی به SHA جدید منتقل نمی‌شوند.
- آخرین کد/آزمون پیش از این ثبت: `4f65800612bd0cce95448f39eee67d683e0e6504`. اجرای اختصاصی این SHA هنوز در فهرست GitHub ظاهر نشده؛ هیچ PASS برای آن ادعا نمی‌شود.
- فایل مستقل Master در پیوست‌های این گفتگو یا جست‌وجوی Library پیدا نشد؛ این یادداشت بر متن ابلاغ‌شده در گفتگو متکی است، نه بر ادعای مطالعهٔ فایل پیوست‌نشده.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` بدون تغییر؛ Merge و انتشار ممنوع. Device Smoke و پذیرش نصب واقعی هنوز مانع‌اند.
- **BLOCKED — RELEASE: NO-GO** تا Build، تمام شاردها، Provider، Persistence، Device Smoke و پذیرش گوشی واقعی روی یک SHA واحد PASS شوند.
