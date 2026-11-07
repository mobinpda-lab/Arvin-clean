# Arvin Parallel Evidence Checkpoint — 2026-11-06

- Evidence target SHA: `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b`
- Authorized branch: `fix/recovery-calendar-device-smoke-2026-10-31`
- PR #3052: OPEN / DRAFT / UNMERGED; observed base SHA for main: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Release: **BLOCKED — RELEASE: NO-GO**.
- Evidence is tied to each exact workflow SHA; no PASS is inferred from a pending job or historical SHA.

## Commit audit

Commit `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b` changed exactly three files: `test/ci_concurrency_contract_test.dart`, `CHANGELOG.md`, and `docs/project-continuity/CI_CONCURRENCY_CONTRACT_2026-11-06.md`. The test diff changes only the two Device Smoke expected values to `cancel-in-progress: false` and `max-parallel: 1`. No assertion/test was removed, skipped, weakened, or bypassed. `.github/workflows/device-smoke.yml` was not changed; its blob SHA is `030aa62801e8885994b997975bfbfc1a4e910dab`.

## Exact-SHA CI — target `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b`

| Workflow / Run | Observed result |
|---|---|
| ARVIN Production Loop / `42209856056` | SUCCESS |
| ARVIN Orchestrator / `42209855911` | SUCCESS |
| Orchestrator PR Wakeup / `42209855944` | SUCCESS |
| Parallel Wave / `42209855856` | SUCCESS |
| G1 lock sync / `42209855749` | SUCCESS |
| Follow-up File Persistence / `42209856031` | SUCCESS |
| Calendar Provider Acceptance / `42209855984` | IN PROGRESS |
| Arvin Build / `42209855954` | IN PROGRESS |
| Device Smoke / `42209855748` | PENDING; no jobs/artifacts at checkpoint |
| Draft Review APK / `42209856090` | SUCCESS |

Build `42209855954`: Analyze SUCCESS; test shards 0–5 SUCCESS; standalone visual job SUCCESS. APK Debug and Staging jobs remain IN PROGRESS. APK Release job completed SUCCESS and produced artifact `13498617943` (artifact digest `sha256:b78d24c1a6a841a452a95c32e13ee455b9c4108687f592244296203ad34ae021`). Extracted Release APK SHA-256: `34c7c7a0d326c63ecee5852c99595466c3b7a302a8a088a41f2a9a76247acad6`. Independent signature/production-key verification was not completed; this is not release acceptance.

## Review APK — exact target SHA

Draft Review APK run `42209856090` completed SUCCESS. Artifact `13498418932`; GitHub artifact digest `sha256:68c61ecfd1cb25eb23fba697dbe5ffb0213b3150a4e7c36758f4e9f814c1da2a`.

Inspected manifest and signature log:
- APK SHA-256: `a4040ef1939b42c82b7565484f32108727faa89f107636fd4a9832c7e4132fc5`
- APK size: 78,956,462 bytes
- Application ID: `com.example.arvin.staging`; Android debuggable: `false`
- Signature Scheme v2 and v3: verified
- Vazirmatn Regular, Medium and Bold assets: present
- Signing key: ephemeral review-only test key; `publishable=false`; `release_created=false`

Valid review/install-test evidence only, not a production-signed release APK.

## Device Smoke — strict SHA separation

Old run `42205465399` belongs to SHA `59a321d333bd867049cf7f5b87be82ad9cb8e68e`, not the target SHA:
- Boot SUCCESS; artifact `13498760412`, digest `sha256:1a936cd5f0ab8b53846d580294161f0beda3472f93bd4bfa59fca24c29f04b92`.
- Navigation SUCCESS; artifact `13497798480`, digest `sha256:62596a34da7323e82a879d4e331337b8d11bba4da56ff0fdb86fcb36abe1c929`.
- Calendar IN PROGRESS.
- Reminder/Vazirmatn, Quick Capture, Follow-up Persistence and Task Lifecycle QUEUED.
- No Quick Capture or Calendar acceptance artifact available at checkpoint.

New run `42209855748` is associated with target SHA `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b`; it was PENDING with no jobs or artifacts. No Device Smoke lane on the target SHA is accepted yet.

## Open gates

Continue polling Build `42209855954`, Calendar Provider `42209855984`, new Device Smoke `42209855748`, and old Device Smoke `42205465399` separately. Record each completed run's SHA, lane conclusions, artifact IDs and digests. Independently audit Release APK signing/provenance and inspect Debug/Staging artifacts when available. Keep PR #3052 OPEN / DRAFT / UNMERGED; do not merge or edit `main`. Release remains **BLOCKED — RELEASE: NO-GO**.

## Documentation synchronization

This checkpoint, its changelog entry, and the appended product-ledger section are documentation-only updates. Their resulting commit SHA is a new branch head. The workflow results above remain evidence for `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b` only; fresh exact-head workflows are required for the resulting documentation HEAD.


## Live parallel checkpoint — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Audited code SHA:** `e81862cbcd723dd0740411de0526aac5e1771e36`  
**PR #3052:** OPEN / DRAFT / UNMERGED. **main:** `45e4202b03a434459e4c021a04efa7e8396359db`. **Release:** BLOCKED — RELEASE: NO-GO.

### Exact-SHA workflow evidence
- Build `42212225056`: IN_PROGRESS. Analyze job `127874147349` PASS (log: `No issues found!`); Visual job `127874146662` SUCCESS; test shards 4 and 5 SUCCESS; shards 0–3 IN_PROGRESS; Debug, Staging and Release APK jobs IN_PROGRESS. No artifact listed at this checkpoint.
- Device Smoke `42212224923`: PENDING; no jobs and no artifacts exposed. No device lane is accepted.
- Follow-up File Persistence `42212224806`: SUCCESS; job `127873397879`; log reports one test passed and records SQLite executor close plus temporary-directory cleanup. This is focused file-backed persistence evidence, not full Device Smoke acceptance.
- Calendar Provider `42212224989`: IN_PROGRESS; job `127873398173`; log endpoint returned BlobNotFound while active, so detailed stage evidence is unavailable. No artifact.
- Draft Review APK `42212224924`: IN_PROGRESS; job `127873400021`; log endpoint returned BlobNotFound while active. No artifact.
- Production Loop `42212224920`, G1 lock sync `42212225294`, Orchestrator `42212224894`, Parallel Wave `42212225472`, and PR Wakeup `42212224907`: workflow-level SUCCESS; these do not replace product acceptance gates.
- Combined commit status endpoint returned no individual status entries at audit time.

### Previous-head runs — SHA `2c2594e4663b243932620e250b4586e564996461`
- Build `42210948715`: workflow conclusion CANCELLED, although the returned job list showed the visible Analyze, six shard and APK jobs completed SUCCESS. Treat the overall run as CANCELLED / not an accepted completed Build gate; do not promote child results into a workflow PASS.
- Device Smoke `42210947981`: CANCELLED; no jobs or artifacts returned. No device acceptance.
- No previous-head result is carried forward as evidence for `e81862c`.

### Branding diff audit
- Commit `e81862cbcd723dd0740411de0526aac5e1771e36` changes exactly one file: `assets/images/branding/tafweez.svg`.
- Parent blob `98203032b9c3ea9a257ed15a7763828bf66ac877`; new blob `dd5db5b401eceef981b417dd7f781d9994ac4e10`.
- The only diff removes the SVG `title` element. Removing that line from the parent content yields byte-for-byte equality with the new content; path geometry is unchanged.
- New SVG contains one `path`, no other drawable/metadata elements, no background element, and one fill value `#1A2B4C`; root viewBox remains `0 0 1792 1024`. Source-level Path-Only/vector contract is satisfied. Runtime rendering and accessibility acceptance still require exact-head CI/device evidence.

### Issue triage
- #823 OPEN: release-scope freeze remains binding; no feature or UX expansion authorized by this audit.
- #2102 OPEN: main remains at the PR base SHA; exact-main release evidence and physical-device/data-integrity gates remain open. No main change made.
- #2299 OPEN: remaining-work ledger remains the tracking authority; this checkpoint records evidence without closing product gates.

This checkpoint is documentation-only. All run results above belong only to the exact SHA stated for each run. The documentation commits require their own exact-head validation. No workflow, test, product feature, main branch, merge, or release configuration was changed.


## ممیزی و اصلاحات UX / Home و فرم‌ها — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Code checkpoint SHA:** `f614fab584cd149db7aa9234dbe825b14198c292`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED  
**main:** untouched  
**Release:** BLOCKED — RELEASE: NO-GO.

### Commits روی شاخه
- `6d7a48de45a4fc07a5f1c6dd70455e3484218ec8` — توکن‌های برند اصلی از بنفش/سرمه‌ای به آبی‌فیروزه‌ای تغییر کردند: primary `#087F8C`، header `#075E66`، soft `#DDF7F5`. رنگ‌های معنایی اولویت و taxonomy در تست توکن‌ها بدون تغییر باقی ماندند؛ رنگ SVG بسم‌الله `#1A2B4C` دست‌نخورده است.
- `1e63de1b39327ca569283a7bf6ea0cea9d328917` — ردیف انتخاب مرکز/پروژه/دسته/برچسب و ردیف موعد/یادآور/تکرار در ثبت سریع از اسکرول افقی به Wrap چندردیفی تغییر کرد؛ تست اندازه‌های 320 و 1024 پیکسل، نبود اسکرول افقی فرم را بررسی می‌کند.
- `c3e2b522ee72b74a4366648d09f19fc847a791f3` — نسخه اولیه Wrap برای taxonomy فرم کامل ثبت شد؛ ساختار این نسخه در کامیت بعدی اصلاح شد و این SHA به‌تنهایی مبنای پذیرش نیست.
- `5164319f5262e458ee85af127c83d3fc5bdd0d08` — ساختار Wrap فرم کامل اصلاح و برای Category / Project / Tag کلیدهای آزمون‌پذیر اضافه شد؛ چیدمان در عرض باریک دو ستونه و در عرض عریض سه‌ستونه است.
- `670e092f2bc4a0b3220f58d449a825637c1ea880` — عبارت نمایش پروژه به APIهای سازگار Dart محدود شد؛ از extension غیرضروری استفاده نمی‌شود.
- `f614fab584cd149db7aa9234dbe825b14198c292` — اولویت ثبت سریع تا انتخاب صریح کاربر `TaskPriority.none` است؛ تاریخ موعد و یادآور نیز بدون انتخاب کاربر null می‌مانند. تست عدم‌تولید پیش‌فرض‌ها افزوده شد.

### مواردی که پیش از این وجود داشتند
- هدر اصلی Home با منوی راست، SVG بسم‌الله، عنوان و زیرعنوان مرکزی و فیلتر عمومی چپ؛ کادر جستجو زیر هدر؛ ردیف پنج فیلتر RTL با مرتب‌سازی مستقل؛ پنج گروه زمانی؛ FAB و پنج مقصد Bottom Navigation از قبل در `lib/main.dart` وجود داشتند.
- مرتب‌سازی پیش‌فرض در Home از قبل `TaskListSort.lastFollowUp` با جهت صعودی بود. طبق قرارداد، موارد فاقد Follow-up پس از موارد تاریخ‌دار می‌آیند و تساوی با اولویت و سپس شناسه Task شکسته می‌شود. گروه‌بندی پنج‌گانه از Due Date استفاده می‌کند.
- فیلترهای Home از قبل منطق OR داخل بُعد و AND بین ابعاد را پیاده کرده بودند؛ آزمون موجود ترکیب Category و Tag را پوشش می‌دهد، اما پوشش کامل پنج بُعد و تمام ترکیب‌ها هنوز اثبات نشده است.
- مدل `PersonReference`، سرویس `TaskPeopleService`، فیلد `Task.people` و `FollowUp.personIds` و فیلتر اشخاص در Report Center از قبل وجود دارند؛ این به‌معنای وجود انتخاب/افزودن شخص در فرم Follow-up نیست.
- `allDay` برای Due Date از قبل وجود دارد؛ این وضعیت جایگزین پشتیبانی عمومی «بدون ساعت» در Follow-up و Reminder نیست.

### تطبیق Home و فرم‌ها — شکاف‌های باز
- **Home:** هدر، جستجو، فیلترها، گروه‌ها و navigation از نظر ساختاری موجودند. گروه «آینده» در کد عنوان تجمیعی دارد و نمایش تاریخ کامل برای آن هنوز نیازمند تطبیق دقیق با بند ۱۰ سند است. آزمون Home موجود viewport 320×640 و 390×844 را پوشش می‌دهد؛ آزمون DPR کسری 0.333px، بزرگ‌نمایی فونت و صفحه‌کلید برای Home هنوز اضافه/اجرا نشده است.
- **فرم کامل Task:** کنترل‌های Category / Project / Tag اکنون Wrap می‌شوند؛ انتخاب‌گر Center در این فرم هنوز وجود ندارد. Project دارای `centerId` است و نباید بدون انتخاب/رابط صریح، Center مستقل جعل شود.
- **اشتراک فیلترها:** ردیف Home از `ActionChip` و Report Center از بخش‌های مستقل `_Section` / `_MultiSelectChips` استفاده می‌کند. ادغام واقعی در یک جزء مشترک و یکسان‌سازی وضعیت/تعامل پنج فیلتر هنوز انجام نشده است؛ فیلتر شخص گزارش مستقل باقی می‌ماند.
- **Follow-up / Person:** فرم `FollowUpEntryPage` وضعیت «منتظر پاسخ» را ذخیره می‌کند، اما انتخاب شخص موجود/افزودن شخص جدید و تغییر/حذف پیوند شخص را در UI ارائه نمی‌کند. گزارش‌ها فقط از `personIds` موجود استفاده می‌کنند؛ آزمون ذخیره، بازگشایی و گزارش یک شخص واقعی هنوز انجام نشده است.
- **تاریخ/ساعت:** در چند فرم، انتخاب تاریخ و ساعت هنوز کنترل‌های جدا دارد. Due Date از `allDay` استفاده می‌کند، اما جریان واحد یک‌دکمه‌ای و گزینهٔ صریح «بدون ساعت» در همهٔ محل‌های اختیاری پیاده نشده است. پشتیبانی ذخیره/نمایش بدون ساعت برای Follow-up و عدم ساخت اعلان زمان‌دار بدون ساعت هنوز باز است؛ Due Date، Follow-up Date و Reminder Date مستقل باقی می‌مانند.
- **چیدمان تقویم:** تغییر قبلی به پیمایش عمودی و guard خطای startup در کد وجود دارد؛ این guard به‌تنهایی رفع منشأ RenderFlex را اثبات نمی‌کند. گزارش دستگاه با سرریز 0.333px در منابع قابل دسترس این ممیزی پیدا نشد؛ اصلاح منشأ و آزمون DPR کسری/فونت بزرگ/RTL هنوز NOT VERIFIED است.
- **SVG و فونت:** توکن رنگ بسم‌الله در Home حفظ شده است. وجود دو asset بسم‌الله و تفویض در مخزن به‌تنهایی اثبات path-only بودن، نبود عنصر text/raster، و render صحیح روی دستگاه نیست؛ این گیت‌ها باید با آزمون asset و screenshot تأیید شوند. Vazirmatn تنها فونت متنی مجاز باقی می‌ماند.

### وضعیت شواهد روی Code SHA بالا
- Build run `42261229876`: PENDING؛ در آخرین بررسی هنوز job آغاز نشده بود. بنابراین `flutter analyze` و مجموعه کامل تست‌ها روی این SHA نتیجه ندارند.
- Device Smoke run `42261230051`: PENDING؛ هنوز job و مدرک دستگاه/اسکرین‌شات ارائه نشده است.
- Follow-up File Persistence run `42261230162`: SUCCESS؛ checkout SHA دقیق تأیید شد؛ تست file-backed Repository و diagnostic بستن/بازگشایی SQLite هر دو SUCCESS شدند. این گیت محدود، جایگزین آزمون شخص/گزارش یا Device Smoke نیست.
- Calendar Provider run `42261229778`: IN_PROGRESS؛ آزمون instrumentation/provider در حال اجرا بود.
- Draft Review APK run `42261229806`: IN_PROGRESS؛ ساخت Staging APK در حال اجرا بود؛ در لحظه بررسی هیچ artifactی بارگذاری نشده بود. APK Debug مستقل ساخته/تحویل نشده است.
- نتیجهٔ orchestration/factory SUCCESS جایگزین Analyze، تست، APK، Device Smoke یا پذیرش مالک محصول نیست.

هیچ تست یا قابلیتی حذف، skip یا تضعیف نشده است. هیچ تغییر روی `main`، Merge، Release یا انتشار انجام نشده است. این ثبت مستندات، نتیجهٔ CI را به PASS ارتقا نمی‌دهد.


## آخرین اصلاح منبع چیدمان و آزمون‌های اندازه‌ناپذیر — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Parent code SHA:** `9e1c9f3e4e52f5168fb3749195b32926fa28bc0a`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO.

- Home header، search، filter row و active-filter chips اکنون داخل یک viewport عمودی قابل پیمایش با `FlexFit.loose` قرار می‌گیرند؛ در viewport کوتاه یا هنگام بازبودن صفحه‌کلید، محتوای کنترل‌ها به‌جای فشرده‌سازی اجباری و سرریز، در همان ناحیه پیمایش می‌شود. لیست کارها همچنان viewport مستقل Expanded دارد.
- آزمون‌های جدید منبعی برای Calendar و Home عرض منطقی 360.333px (1081 physical px در DPR=3)، فونت بزرگ 1.4، RTL و inset صفحه‌کلید Home اضافه شده‌اند. آزمون‌های Quick Capture و Task Editor نیز با بزرگ‌نمایی فونت اجرا می‌شوند.
- این‌ها آزمون‌های منبعی هستند؛ تا نتیجهٔ exact-SHA Build، هیچ‌کدام PASS محسوب نمی‌شوند و جای نصب روی دستگاه واقعی را نمی‌گیرند.
- گزارش دقیق مالک محصول از دستگاه فعلی (مدل دستگاه، مقیاس، مسیر صفحه، و screenshot مربوط به overflow 0.333px) در PR comments/Issue #823 comments و فایل‌های فعلی مخزن قابل بازیابی نبود. این خلأ به‌عنوان NOT VERIFIED ثبت می‌شود؛ گزارش قدیمی نصب APK از 2026-08-14 مربوط به PR دیگر است و مبنای این پذیرش نیست.
- Home spec چهارده‌بندی در منبع خوانده شد. بخش‌های ساختاری موجود (header، Bismillah SVG، search، پنج فیلتر و sort مستقل، گروه‌بندی Due Date، navigation پنج‌تب) از قبل پیاده بودند؛ تست‌ها و پذیرش بصری کامل هنوز لازم‌اند. شکاف‌های Center در فرم Task، یکپارچه‌سازی جزء فیلتر Home/Report، انتخاب Person در Follow-up و مدل/جریان بدون ساعت همچنان بازند.
- وضعیت runهای دقیق parent SHA `9e1c9f3`: Build `42261916395` PENDING بدون job؛ Device Smoke `42261916305` PENDING بدون job؛ Draft Review APK `42261916169` IN_PROGRESS؛ Calendar Provider `42261916279` IN_PROGRESS؛ Follow-up Persistence `42261916393` IN_PROGRESS. نتایج این runها فقط به همان SHA تعلق دارند.
- آزمون‌های قبلی روی SHA `f614fab` برای file-backed Repository و SQLite close/reopen هر دو SUCCESS بودند؛ نتیجه به SHA جدید منتقل نمی‌شود.

هیچ تستی حذف، skip، bypass یا تضعیف نشده است. main دست‌نخورده، PR OPEN/DRAFT/UNMERGED و انتشار NO-GO باقی می‌ماند.


## اصلاح خطای تحلیل و ساخت Quick Capture — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Parent SHA:** `1c14c801a2b04cc70a4a617e2e7626d6c35d4331`  
**Evidence run:** Build `42262323182` on SHA `b5c8892a7aa5dad5d83abbf717bc19ea5c63140c`; Draft Review APK `42262323487` on the same SHA.

- Analyze در SHA `b5c8892` با سه خطای syntax در `lib/quick_capture_dialog.dart` شکست خورد: دو خطای positional arguments و یک پرانتز بسته‌نشده (log lines around 762, 833, 863). Staging APK نیز در مرحلهٔ compile Flutter با همان دو parenthesis mismatch شکست خورد؛ هیچ APKی upload نشد.
- علت: در تبدیل دو ردیف ثبت سریع به Wrap، یک لایهٔ بسته‌شدن `_surfaceCard` از هر بلوک جا افتاده بود. این مورد پنهان یا skip نشد؛ در این commit دو closure مربوط به هر دو Wrap کامل می‌شود.
- این اصلاح فقط syntax را ترمیم می‌کند؛ پذیرش layout هنوز منوط به Analyze و آزمون‌های exact-head است.
- SHA `b5c8892` همچنان FAIL برای Analyze و Review APK ثبت می‌شود؛ نتیجه به SHA جدید منتقل نمی‌شود.
- برای parent SHA `1c14c80`: Build `42262966593` PENDING، Device Smoke `42262966560` PENDING، Draft Review APK `42262966666` IN_PROGRESS، Calendar Provider `42262966580` IN_PROGRESS، Follow-up Persistence `42262966838` IN_PROGRESS. Artifactی هنوز ثبت نشده بود.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ هیچ merge یا release انجام نشده است؛ **BLOCKED — RELEASE: NO-GO**.


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


## پیوست اصلاحیه Master — ۱۴۰۵/۰۸/۱۶

- کامیت تکمیلی محصول پس از ثبت قبلی: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`.
- سطح خالی کارت‌های فیلتر و لهجهٔ سربرگ پنل فیلتر نیز به توکن فیروزه‌ای/سطح خنثی مشترک منتقل شد؛ رنگ‌های برند غیر فیروزه‌ای در کنترل‌های فیلتر باقی نماند.
- آخرین کد پیش از این به‌روزرسانی اسناد: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`. نتیجهٔ CI این SHA تا لحظهٔ ثبت این پیوست هنوز قابل تأیید نیست؛ PASS از SHAهای قبلی به آن منتقل نمی‌شود.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ بدون Merge/انتشار؛ **BLOCKED — RELEASE: NO-GO**.
