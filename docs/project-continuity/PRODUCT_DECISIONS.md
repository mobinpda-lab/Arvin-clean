# Product Decisions Register
Canonical register for durable product decisions. Detailed implementation and historical evidence live in IMPLEMENTATION_LOG.md and root CHANGELOG.md.

## Approved
| Decision | Status | Basis / boundary |
|---|---|---|
| Product hierarchy is Center > Project > Category > Task | APPROVED | Owner-confirmed product hierarchy; use the Persian term «مرکز», not «واحد», for the top level. |
| Official UI font baseline is Vazirmatn | APPROVED | Every UI element uses Vazirmatn except the two exact owner-approved sacred Arabic phrases recorded below. |
| PR #3052 stays OPEN / DRAFT / UNMERGED; main untouched; release NO-GO | APPROVED | Binding governance constraints for the active delivery stream. |
| Phase 1 sync direction is local-network, offline Local P2P; cloud/Dropbox is a separate future Phase 2 | APPROVED | Product direction only. This does not approve a particular pairing or conflict algorithm. |
| Task due date, independent TaskReminder, recurrence and historical FollowUp remain separate concepts | APPROVED | Canonical product/data semantics; no conflation or parallel storage. |
| Task Templates are reusable definitions stored in the existing G1 Drift database, separate from executable Tasks; execution state and Follow-up history are excluded, while reusable recurrence pattern (frequency, interval, count, active, tracking level) and Reminder time definitions are retained; source execution dates/history are excluded | APPROVED | Owner directive for Issue #823; contract and non-destructive G1 v11 migration are recorded in `TASK_TEMPLATE_DATA_CONTRACT.md`. Source-context IDs are provenance snapshots only, not automatic project reassignment. |
| Report Center completed-follow-up report remains available through unified Filters rather than a separate top-level action | IMPLEMENTED | The change and tests are recorded at SHA 9b52d43; current HEAD must be rerun before claiming current-SHA verification. |

| Quick Capture visual redesign with four canonical priority chips; add description input bound to Task.description | APPROVED | Owner decision 2026-11-04. UI-only priority treatment; retain TaskPriority high/medium/low/none and existing persistence semantics. No P1–P4 visible codes; use Persian labels and helper captions. Existing center/project/category/tag, date, reminder and recurrence flows remain intact. |


| Quick Capture visual redesign with four canonical priority chips; add description input bound to Task.description | APPROVED | Owner decision 2026-11-04. UI-only priority treatment; retain TaskPriority high/medium/low/none and existing persistence semantics. No P1–P4 visible codes; use Persian labels and helper captions. Existing center/project/category/tag, date, reminder and recurrence flows remain intact. |

## Proposals — not approved for implementation
| Proposal | Status | Required review |
|---|---|---|
| QR-code pairing | PROPOSED | Threat model, authenticated identity, secure key exchange, expiry, replay and revocation. |
| Six-digit PIN pairing | PROPOSED | Entropy, expiry, rate limiting, peer identity, secure channel and recovery. |
| Last-Write-Wins with tombstones | PROPOSED | Domain conflict matrix, causality/versioning, deletion retention and no silent data loss. |
| Choosing a conflict winner using device-local clocks | PROPOSED / NOT APPROVED | Clock skew and deterministic tie-break analysis plus explicit owner approval. |

## Decisions awaiting owner clarification
| Topic | Status | Safe behavior until decision |
|---|---|---|
| Quick Capture empty-title feedback: two visible presentations (inline + SnackBar) or one clear inline presentation | BLOCKED | Preserve current implementation and all existing assertions. Do not change UX or test acceptance until owner decides. |
| Official typography: Vazirmatn for every UI element, with Naskh allowed only for the two owner-approved Arabic sacred phrases «بسم‌الله الرحمن الرحیم» and «أُفَوِّضُ أَمْرِی إِلَى اللَّهِ» (UI spelling may omit diacritics) | APPROVED | Explicit owner decision, 2026-11-05. No Persian UI text or other element may use Naskh; both phrases are the only exceptions. |

## Status vocabulary
PROPOSED = candidate only; APPROVED = explicit owner decision; IN_PROGRESS = work underway; IMPLEMENTED = code exists; VERIFIED = exact-SHA evidence proves acceptance; BLOCKED = cannot proceed safely; SUPERSEDED = replaced but retained historically; REJECTED = explicitly declined.


## ممیزی زنده CI — ۱۴۰۵/۰۸/۱۳ (2026-11-04)

- SHA ممیزی: `3f849eefed2afe08c3d3662cf66d9c488388e737`؛ شاخه مجاز PR #3052.
- Build & Analyze [41852047631](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047631): Analyze PASS و شش شارد test-0 تا test-5 همگی PASS؛ test-3 نیز PASS. فقط برای همین SHA معتبر است.
- Follow-up file-backed SQLite [41852047684](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047684): PASS، شامل persistence و close/reopen diagnostic.
- Device Smoke [41852048093](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852048093): Preparation PASS؛ Boot و Navigation در حال اجرا؛ Quick Capture، Reminder/Vazirmatn، Follow-up Persistence، Calendar Segmented View و Task Lifecycle در صف. هفت سناریو تکمیل نشده؛ نتیجه نهایی NOT VERIFIED.
- Calendar Provider [41852047809](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047809): اجرای instrumentation/provider acceptance در حال انجام؛ نتیجه NOT VERIFIED.
- Review APK [41852047701](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047701): ساخت staging APK در حال انجام؛ Artifact هنوز موجود نیست، پس لینک دانلود/تأیید APK NOT VERIFIED.
- اصلاح test-3 در این SHA: scrollUntilVisible قبل از pumpAndSettle و assertion اجرا می‌شود؛ Finder و assertion حفظ شده و تست تضعیف نشده است.
- PR #3052 هنگام ممیزی OPEN / DRAFT / UNMERGED؛ main تغییر نکرد؛ Vazirmatn و فیلدهای canonical Task حفظ؛ Release: BLOCKED — RELEASE: NO-GO.
- این snapshot فقط وضعیت runهای SHA ممیزی‌شده را ثبت می‌کند؛ commit مستندات SHA تازه‌ای می‌سازد و PASSهای قبلی را به SHA تازه منتقل نمی‌کند.

تصمیمات محصولی مصوب در این checkpoint تغییر نکردند؛ این ثبت فقط ثبات Vazirmatn، استقلال Reminder/Follow-up/Task due date و حفظ فیلدهای Task را یادآوری می‌کند.


## Module-Core-Logic v1.0 — live code crosswalk (۱۴۰۵/۰۸/۱۴ — 2026-11-05 02:38 Asia/Tehran)
**Status:** IN_PROGRESS / NOT VERIFIED as complete module acceptance.  
**Reviewed source SHA:** `4021c84ceb14faf4f6559379cf67dd94955bffe4`.  
**Source-text qualification:** the verbatim Module-Core-Logic v1.0 text previously emitted was not available in the retrieved conversation context. This entry records a source-backed crosswalk for the core invariants named in the execution request; it does not claim a line-by-line validation of unavailable wording and is not a new parallel module specification.

| Core invariant | Source-backed finding | Disposition |
|---|---|---|
| Task Due Date is independent from Reminder | `Task.dueDate` is a separate Task field; `TaskReminder.date` and reminder IDs are stored separately. Calendar projections/tests distinguish `task-due:` from `task-reminder-item:`. | IMPLEMENTED; exact-SHA source/tests support separation. |
| Follow-up timestamp source | `FollowUp.dateTime` is serialized to JSON and SQL `follow_ups.date_time`. `completedAt` is a getter alias to `dateTime`, not a second persisted Follow-up timestamp. | IMPLEMENTED; representation is aligned only if the module treats `dateTime` as canonical. |
| Legacy-field preservation | Task model/store/schema still retain and write `followUpEnabled`, `followUpDate`, and legacy `reminderDate`; FollowUp model/store/schema still retain `reminderDate` and `nextFollowUp`. | IMPLEMENTED for compatibility/preservation; retirement of active legacy schema/fields is NOT IMPLEMENTED. |
| Duplicate Reminder prevention | Delivery-state identity prevents re-delivery of an already delivered stable Reminder identity. However, `TaskStore.addTaskReminder` appends a new ID without an idempotency/deduplication key, and `FollowUpReminderDeliveryService.due` currently does not filter `TaskReminder.isEnabled == false`. | PARTIALLY IMPLEMENTED. Disabled reminders can enter the delivery candidate path; repeated add operations are not proven idempotent. No logic change made in this audit. |
| Stop Alarm cycle | `_stopAlarm` cancels only the active notification ID and closes the overlay; it does not complete or mutate the Task. Complete is a separate action. Snooze mutates only the selected Reminder ID, reschedules, then cancels the active notification. | IMPLEMENTED in source; focused test and file-backed evidence exist on the reviewed SHA. |
| Follow-up from Alarm | Alarm Overlay opens `FollowUpEntryPage(taskId: task.id, allowAddingReminder: false)`; the Follow-up is added to history only after explicit save. | IMPLEMENTED in source. |
| Alarm ID 42002 | `followUpReminderAlarmId = 42002` is the AndroidAlarmManager one-shot scheduler ID. Notification IDs are normally a stable-key hash; 42002 is only the hash-zero fallback in the notification service. | CLARIFICATION REQUIRED if the module calls 42002 the ID of every notification. The scheduler ID is fixed; per-notification IDs are not. |
| SQLite persistence and migration | G1 schema version is 8. File-backed persistence/Alarm Overlay close-reopen workflow passed on the reviewed SHA. Schema installation is transactional and the inspected additions are additive; legacy columns remain. | Persistence test PASS on this SHA; legacy-schema retirement/migration acceptance BLOCKED. |
| Real user DB / backup safety | No actual user database row/value inventory or verified backup/restore snapshot was inspected in this audit. | NOT VERIFIED; no destructive migration is authorized. |

**Required follow-up before module acceptance:** correct/test the disabled-reminder delivery filter and add idempotent Reminder creation protection under a separately authorized implementation task; decide the precise scope of legacy-field preservation versus eventual schema retirement; verify real DB contents and backup/rollback before any destructive migration.
## Uniform UI design tokens — owner directive (2026-11-05 09:56 Asia/Tehran — ۱۴۰۵/۰۸/۱۴)
**Status:** APPROVED — canonical visual token update. This later explicit owner instruction supersedes the earlier palette values recorded in historical UI references and style-lock snapshots; those historical records remain evidence, not the active token source.
| Token | Value | Usage |
|---|---|---|
| Primary purple | `#3F3D56` | Primary actions, active navigation and selected brand states |
| Header purple | `#2D2B42` | App/page headers and AppBar foreground contrast |
| Light background | `#F7F8FC` | Main light-theme canvas |
| Card background | `#FFFFFF` | Standard card surfaces |
| Card radius | `16px` | Shared card containers |
| Card shadow | black 4%, blur 10, offset (0,4) | Soft card elevation |
| Font | `Vazirmatn` | All app UI except the two exact owner-approved sacred Arabic phrases; no other font-family exception |
- Canonical implementation entry point: `lib/core/theme/arvin_theme.dart`; `ArvinColors` remains the semantic compatibility palette and maps shared primary/background/surface tokens to the new values.
- Shared Flutter `CardThemeData` and app-bar theme use the new light card/header tokens. Shared Home shell, navigation, radio/project selector and recurrence chip surfaces consume the central token aliases.
- Priority semantics stay unchanged: P1=high/red, P2=medium/blue, P3=low/amber, P4=none/neutral. User-facing labels remain Persian «اولویت ۱» … «اولویت ۴»; do not render literal English P1–P4 unless a later explicit UI decision authorizes it.
- Status chips retain their existing semantic states/colors; taxonomy remains Center → Project → Category → Tags, with contextual icons and separate existing semantic accent colors. No entity/model or priority enum remapping is authorized.
- **Coverage status:** foundation implemented; exhaustive conversion of every custom BoxDecoration/card-like surface across all screens and physical visual acceptance remain IN_PROGRESS / NOT VERIFIED. Do not describe the entire app as uniformly migrated until the cross-screen inventory and visual tests pass.
- Governance unchanged: PR #3052 OPEN / DRAFT / UNMERGED; main untouched; no merge/release; BLOCKED — RELEASE: NO-GO.

### Target-surface card rollout update — 2026-11-05 10:03 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
- The shared 16px card surface, white surface, centralized border and 4%/10px/4px shadow were applied to Task Details read-only/edit card wrappers, Task Editor reminder/checklist outer cards, Quick Capture cards/sheet canvas, and Calendar reminder cards. Task List card material already uses 16px radius and now inherits the new shared surface tokens through ArvinColors.
- This is a targeted pass over the four requested screen families, not proof that every decorative panel in every secondary screen has been migrated. Remaining custom panels and physical screenshot acceptance stay IN_PROGRESS / NOT VERIFIED.

 
## TaskHomeScreen — owner-approved final contract (2026-11-05 13:02 Asia/Tehran — ۱۴۰۵/۰۸/۱۴)
**Status:** APPROVED — canonical Home product decision. Full fourteen-point specification: `task_home_screen_spec.md`.
- Header RTL positions: hamburger/drawer right, centered Bismillah calligraphy + «آروین» + subtitle, general filter funnel left. No Home notification bell and no standalone header search icon.
- Independent search field immediately below the header; placeholder «جستجو در کارها...».
- One horizontally scrollable RTL row: Time → Center → Projects → Categories → Tags → Sort icon. The sort icon is independent and is not a sixth filter.
- Multi-select semantics: OR within each filter category; AND across different categories.
- Default sort key is Follow-up Date; undated Follow-ups remain last; priority and stable Task ID are deterministic tie-breakers. Past group retains its existing dedicated overdue ordering.
- Due Date alone classifies the groups Past, Today, Tomorrow, Future and Timeless. Follow-up Date sorts; Reminder Date triggers alarms only and is excluded from Home grouping/sorting.
- Dated group headers show dynamic Persian weekday + Jalali date; groups are collapsible and show a calendar icon and count badge.
- Task cards use a clean white surface, right-side circular completion control in RTL, Persian title, compact Center/Project/Category/Tag metadata and an optional real Follow-up badge.
- Purple Add FAB at bottom-right; five bottom tabs only: Home, Calendar, Notebook, Reports, More. «اقدام بعدی» is not a primary tab.
- No KPI/statistical dashboard and no standalone «کارهای من» Home tab/header.
- Existing tests/assertions are immutable under this execution request. Any test/analyzer result must be tied to the exact SHA.
- Implementation note: the two approved sacred phrases use the exact-text `AppFonts.familyForText` whitelist and Android's system serif/Naskh fallback; no bundled Naskh font asset is currently present. Physical glyph-level rendering remains NOT VERIFIED until device inspection.
- Governance unchanged: PR #3052 OPEN / DRAFT / UNMERGED; no main edits, merge or release; BLOCKED — RELEASE: NO-GO.


## مصوبه قطعی مالک محصول — فونت و استثنای خط نسخ — ۱۴۰۵/۰۸/۱۴ (2026-11-05)

- فونت پایه و اجباری تمام اجزا، متون، اعداد، دکمه‌ها، برچسب‌ها و سربرگ‌های اپلیکیشن **Vazirmatn** است؛ فقط دو عبارت مقدسِ بند بعد استثنا هستند.
- فقط دو عبارت «بسم‌الله الرحمن الرحیم» و «أُفَوِّضُ أَمْرِی إِلَى اللَّهِ» (یا نمایش بدون اعراب «افوض امری الی الله») مجازند با خط نسخ هنری رندر شوند.
- هیچ متن یا عنصر دیگری مجاز به استفاده از فونت/خط جایگزین نیست. استثنا فقط به محدوده همان دو عبارت محدود است و متن پیرامونی Vazirmatn می‌ماند.
- این تصمیم، پرسش قبلی درباره استثنای بسم‌الله را می‌بندد و برای هر دو عبارت مجوز صریح صادر می‌کند.

## Calendar UI/UX — owner-approved canonical contract — 2026-11-05 — ۱۴۰۵/۰۸/۱۴
**Status:** APPROVED — CANONICAL. Full fourteen-section specification: `docs/project-continuity/calendar_ui_ux_spec.md`.
- Header: sacred phrase «أُفَوِّضُ أَمْرِي إِلَى اللَّهِ» centered, replacing the Calendar title; search icon right; full Persian Today-date pill and «برو به تاریخ» picker adjacent at top-left. Help button removed.
- The full-date pill is a Today shortcut; the adjacent picker is a separate date-navigation action.
- Selected-date bar: bold prominent Jalali date centered; Gregorian date right; Hijri lunar date left.
- Four mutually exclusive view segments above the grid: «روزانه»، «هفتگی»، «ماهانه»، «سالانه»; default «هفتگی».
- Seven-column Saturday-to-Friday RTL calendar grid; each date cell shows bold primary Jalali date plus smaller Gregorian and Hijri lunar dates.
- Five content filters are strictly below the grid and above the agenda, in order: «همه»، «تقویم آروین»، «تقویم گوشی»، «یادآورها»، «انجام‌نشده».
- Agenda is scoped to the selected day and filtered by content category; Task/Event/Reminder cards must not overlap.
- Hijri adjustment options: +1 day, −1 day, Official Iranian Calendar Match.
- Architectural invariant: view modes are above the grid; content filters are below the grid. These are separate control groups.
- Details not specified by the owner approval remain unspecified; preserve existing behavior rather than inventing new rules. No runtime implementation is implied by this documentation decision.
- Existing calendar/provider/data/persistence contracts remain unchanged. PR #3052 OPEN / DRAFT / UNMERGED; main untouched; **BLOCKED — RELEASE: NO-GO**.


## مصوبه یکپارچه UI/UX سه‌صفحه‌ای — ۱۴۰۵/۰۸/۱۴ (2026-11-05)

| Decision | Status | Canonical reference / boundary |
|---|---|---|
| Home Screen: پنج فیلتر سریع RTL با منطق OR درون هر فیلتر و AND بین فیلترها؛ مرتب‌سازی مستقل و پیش‌فرض بر اساس Follow-up Date؛ پنج گروه زمانی بر اساس Due Date | APPROVED | `docs/project-continuity/task_home_screen_spec.md`; فقط presentation/sorting، بدون mutation داده. |
| Task Master-Detail: فرم واحد نمایش/ویرایش inline با ۱۱ بخش ثابت و حفظ موقعیت اسکرول | APPROVED | `docs/project-continuity/task_detail_ui_ux_spec.md`; قرارداد کامل در سند canonical. |
| Calendar: هدر سه‌ناحیه‌ای، عبارت مرکزی اعراب‌گذاری‌شده، نمایش سه‌گانه تاریخ، چهار حالت نمایش، پنج فیلتر محتوایی و معماری سه‌لایه تقویم | APPROVED | `docs/project-continuity/calendar_ui_ux_spec.md`; تنظیم قمری فقط بر تاریخ قمری نمایشی اثر دارد. |
| زبان طراحی مشترک سه صفحه | APPROVED | الهام از Microsoft To Do، کارت‌های سفید گوشه‌گرد، پس‌زمینه روشن، رنگ‌های معنایی، فارسی RTL و Vazirmatn؛ تنها دو عبارت قرآنی مصوب در ردیف تایپوگرافی مجاز به خط نسخ هستند. |

**حدود مصوبه:** این ثبت، تصمیم محصولی و مرجع UX است؛ مجوز تغییر کد اجرایی، تست، Golden Test، schema، Provider یا انتشار نیست. نگاشت «زمان اجرا» و assignment مسئول به داده canonical باید پیش از پیاده‌سازی ممیزی شود؛ تا اثبات منبع واقعی، NOT VERIFIED است. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main بدون تغییر؛ Release: BLOCKED — RELEASE: NO-GO.


## مجوز اجرایی تکمیلی مالک محصول — ۱۴۰۵/۰۸/۱۴ (2026-11-05)

- دستور تجمعی جدید مالک محصول، اجرای runtime code، migration و تست روی شاخه مجاز PR #3052 را صریحاً مجاز کرده است؛ محدودیت قدیمی «صرفاً مستندسازی / بدون runtime» برای این بسته اجرایی دیگر مانع کار نیست.
- قرارداد Task Template در `docs/project-continuity/TASK_TEMPLATE_DATA_CONTRACT.md` ثبت و در G1 v11 پیاده‌سازی شده است. تاریخ‌های اجرای قبلی، وضعیت تکمیل، Follow-up history و شناسه‌های Reminder به الگوی جدید منتقل نمی‌شوند؛ ساعت Reminder، تنظیم checklist، تعریف recurrence و People references حفظ می‌شوند.
- People فقط افراد مرتبط‌اند؛ مسئول مستقل در مدل canonical موجود اثبات نشده و همچنان NOT VERIFIED است. کارت مسئول نباید از Task.people نقش مسئول بسازد.
- فیلد canonical برای «زمان اجرا» در Task تأیید نشده است؛ کارت متادیتا باید «نامشخص» نشان دهد و از createdAt یا dueDate حدس نزند.
- فونت رسمی تمام اجزای رابط، متن‌ها، اعداد، دکمه‌ها و سربرگ‌ها Vazirmatn است. تنها دو عبارت «بسم‌الله الرحمن الرحیم» و «أُفَوِّضُ أَمْرِی إِلَى اللَّهِ» (یا نگارش UI بدون اعراب «افوض امری الی الله») مجازند با خط نسخ هنری رندر شوند؛ هیچ متن یا جزء دیگری استثنا نیست. این مصوبه صریح مالک محصول است.
- اجرای کد و تست روی شاخه مجاز انجام شده، اما تا اجرای تست‌ها و CI روی exact final SHA، وضعیت «پیاده‌سازی‌شده اما تأییدنشده» است. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main تغییر نمی‌کند؛ **BLOCKED — RELEASE: NO-GO**.


## تصمیم قطعی و جایگزین‌کننده قرارداد تایپوگرافی — ۱۴۰۵/۰۸/۱۴ (2026-11-05)
این تصمیم، تمام استثناها و تفسیرهای قبلی مربوط به فونت متنی عبارات مقدس، serif سیستم، Naskh fallback و Amiri را لغو می‌کند:
- تمام متن‌های UI، بدون استثنا، فقط با خانواده محلی Vazirmatn رندر می‌شوند؛ هیچ فونت متنی ثانویه، fallback متنی، فونت سیستمی یا خانواده دیگر مجاز نیست.
- «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ» در مرکز هدر Home، بالای عنوان آروین، به‌صورت SVG اختصاصی وکتوری قرار می‌گیرد؛ عرض هدف موبایل ۱۸۰ تا ۲۳۰ پیکسل، مقیاس‌پذیر در تبلت، رنگ سرمه‌ای تیره برند، بدون سایه و پس‌زمینه سنگین، همراه semantics دسترس‌پذیری متنی.
- «وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ» در سربرگ تقویم نیز فقط به‌صورت SVG اختصاصی نسخ هنری/اصیل استفاده می‌شود؛ هیچ Text widget با فونت استثنایی برای آن باقی نمی‌ماند.
- هر دو SVG باید از pathهای برداری واقعی تشکیل شوند؛ SVG دارای عنصر <text> و متکی به فونت خارجی، تصویر raster جاسازی‌شده، یا تبدیل خودکار به‌عنوان وکتور اصیل پذیرفته نیست.
- مرجع تصویری خوشنویسی تأییدشده در سوابق قابل بازیابی این ممیزی یافت نشد. طراحی path نهایی که ادعای تطابق دقیق با مرجع کند، تا دریافت/دسترسی به همان تصویر **NOT VERIFIED** می‌ماند. این محدودیت مجوز جایگزینی با خوشنویسی حدسی نیست.
- پذیرش: تست ساختاری وجود دو SVG و semantics، آزمون حالت روشن/تاریک و اندازه‌های گوشی/تبلت، بررسی عدم overflow و افت فریم، سپس Build و Device Smoke روی یک SHA واحد.
- این قرارداد در اولویت بالاتر از هر ثبت قبلی است. Vazirmatn تنها فونت متنی محصول باقی می‌ماند.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO** تا اعتبارسنجی بیلد پایدار و پذیرش مالک محصول.


## STD-GOV-AIPOS-v1.0 — 2026-11-05
- UI text everywhere uses Vazirmatn only. No Amiri, system serif, Naskh font, secondary family or text fallback is allowed.
- Bismillah in Home and Tafweez in Calendar are dedicated transparent SVG path artworks, navy #1A2B4C, not text widgets; each has one accessible semantic label and no duplicate screen-reader announcement.
- Exact approved reference images are required for final calligraphy approval. If unavailable, matching is NOT VERIFIED; do not claim a guessed design matches.
- Home taxonomy order: Center > Project > Category > Task. Filter controls use checkboxes; selections within one dimension are OR, dimensions combine with AND. Time filter prioritizes Overdue.
- Calendar retains three separate layers: view-mode/navigation, date-grid selection/projection, and selected-date agenda/content projection. Persistence and source filters remain separate.
- PR #3052 remains OPEN/DRAFT/UNMERGED; main untouched; release NO-GO.


## Decision register additions / checkpoint — ۱۴۰۵/۰۸/۱۵ — ۱۰:۰۱ (Asia/Tehran) / 2026-11-06
| Decision | Status | Evidence / boundary |
|---|---|---|
| Product hierarchy: Center > Project > Category > Task | APPROVED / IMPLEMENTED | Owner-approved hierarchy; canonical product language and current implementation are to be audited page-by-page before VERIFIED. |
| Completed Follow-up report is selected only inside the comprehensive Report Filters sheet; no separate top-level button | APPROVED / IMPLEMENTED | Source: `lib/report_center_page.dart`; regression: `test/report_center_page_test.dart` verifies the standalone action is absent and the unified filter path works. Exact-SHA full acceptance remains tied to current CI. |
| Official UI font is Vazirmatn; the two owner-designated sacred phrases are SVG vectors and must not introduce a secondary font | APPROVED | Font policy is binding. SVG implementation status must be recorded only against actual SVG assets and rendering tests; do not infer it from approval. |
| Calendar architecture uses three local layers | APPROVED | Architecture decision only; implementation/acceptance remain separate statuses and must be backed by source plus exact-SHA tests. |
| Local-network P2P synchronization precedes cloud synchronization | APPROVED (direction) | Phase 1 local P2P; Phase 2 cloud. Pairing, cryptographic and conflict-resolution details remain unapproved until their security review and owner decision. |
| Quick Capture empty-title feedback remains compact inline error plus floating SnackBar | IMPLEMENTED | Source and the original visible-feedback widget assertions are present; no test weakening. Full Smoke gate remains incomplete. |

The governance vocabulary remains: PROPOSED, APPROVED, IN_PROGRESS, IMPLEMENTED, VERIFIED, BLOCKED, SUPERSEDED, REJECTED. These statuses are not interchangeable; implementation does not imply verification.


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

## تصمیم بنیادین زمان کار / موعد — ARVIN-DIR-1405/08/16-02-MASTER
**وضعیت تصمیم: APPROVED | وضعیت پیاده‌سازی در checkpoint ثبت: NOT VERIFIED**

- تاریخ، ساعت و موعد ورودی تسک یک مفهوم واحد با عنوان «زمان کار / موعد» هستند؛ مقدار ذخیره‌شده همان Task.dueDate و تنها Deadline تسک است. فیلد موعد موازی یا تکراری در Quick Capture و Task Details مجاز نیست.
- Task با ساعت، در لحظه عبور از dueDate معوق می‌شود. Task تمام‌روز با پایان روز محلی انتخاب‌شده معوق می‌شود؛ زمان نیمه‌شب صرفاً شناسه روز است و نباید به‌عنوان ساعت نمایشی تلقی شود.
- ورود زمان در فرم‌های ثبت و ویرایش، یک جریان پیوسته است: تقویم شمسی ← تأیید تاریخ ← انتخاب‌گر ۲۴ساعته. لغو هر مرحله باید مقدار قبلی را بدون تغییر نگه دارد.
- کنار فیلد زمان کار، کنترل دایره‌ای ساعت نقش ضامن تمام‌روز/بدون ساعت را دارد. انتخاب آن مرحله ساعت را رد می‌کند؛ تغییر از تمام‌روز به زمان‌دار باید انتخاب ساعت معتبر داشته باشد.
- یادآور مستقل همچنان موجودیت جداگانه‌ای از Deadline است؛ زمان آن نباید با Task.dueDate یا تاریخچه FollowUp ادغام شود. فرم‌های یادآور نیز باید از همان جریان پیوسته تاریخ ← ساعت و کنترل تمام‌روز استفاده کنند.
- ویجت مشترک باید در Quick Capture، Task Editor/Task Details و فرم‌های یادآور استفاده شود. چیدمان Wrap و کم‌ارتفاع باید عرض‌های ۳۶۰، ۳۹۰ و ۴۱۲dp، صفحه‌کلید باز و مقیاس متن بزرگ را بدون RenderFlex overflow پشتیبانی کند.
- مدل موجود dueDate و allDay مبنای سازگاری داده است؛ هیچ فیلد ذخیره‌سازی موازی مانند deadline اضافه نشود. مهاجرت داده یا حذف فیلدهای legacy بدون ممیزی و پشتیبان‌گیری مجاز نیست.
- آزمون‌های لازم: توالی تاریخ/ساعت، لغو مرحله دوم، تمام‌روز، تبدیل تمام‌روز به زمان‌دار، مرز پایان روز محلی، Overdue، حفظ Reminder مستقل، حفظ داده و ماتریس اندازه/IME. هیچ تست یا assertion حذف، Skip یا تضعیف نمی‌شود.
- این تصمیم، قرارداد محصول را تعیین می‌کند و به‌تنهایی به معنی پیاده‌سازی یا پذیرش نیست. وضعیت اجرایی باید فقط با commit و CI روی SHA دقیق به IMPLEMENTED / VERIFIED ارتقا یابد.
