# ARVIN Storage Schema and Migration Map

Status: **G1-MAP — نقشه Migration تأییدشده برای ساختار فعلی کد**
Repository: `mobinpda-lab/Arvin-clean`
Branch: `feature/arvin-final-integration-20260921`
Mapping checkpoint: `d09ce7370c701870d0508c87b398faf31ec16560`
Main at audit start: `25c2ecf7e935ac7a75cfa0d386e1e5eb1d342d47`
PR: #1271 — Arvin Final Integration — G1 Storage/Migration Validation

> این سند نقشه ساخت Storage جدید نیست. هدف آن ثبت دقیق Storage فعلی و تعیین مقصد بدون حذف، تغییر شناسه یا از دست دادن داده است. تا پایان این مرحله هیچ مسیر اصلی TaskStore به Drift منتقل نمی‌شود.

## 1. نتیجه ممیزی فعلی

- Storage اصلی Taskها: SharedPreferences، کلید `arvin.tasks`.
- `TaskStore`، `TaskMigrationReader`، `TaskMigrationWriter` و `TaskMigrationAdapter` مرز فعلی هستند.
- Notebook/Note/Checklist مدل مستقل و کلید مستقل ندارند؛ همگی داخل همان Task و کلید `arvin.tasks` نگهداری می‌شوند.
- Projectها Storage مستقل دارند: `arvin.projects`.
- Tag فهرست عمومی Storage مستقل دارد: `arvin.tags`؛ ارتباط هر Task با Tagها فعلاً داخل `Task.tags` است.
- Category فهرست مستقل ندارد؛ مقدار Category داخل `Task.category` و در Notebook نیز از همین مسیر خوانده می‌شود.
- Archive و Trash فیلدهای خود Task هستند: `archived` و `trashed`.
- Drift در `pubspec.yaml` این شاخه وجود ندارد؛ بنابراین G1 هیچ جدول Drift یا Migration اجرایی ایجاد نمی‌کند.

## 2. مدل واقعی Task

| فیلد | نوع فعلی | اختیاری/پیش‌فرض | JSON فعلی | مقصد پیشنهادی Drift |
|---|---|---|---|---|
| id | String | اجباری | `id` | Tasks.id، همان مقدار |
| title | String | پیش‌فرض `''` | `title` | Tasks.title |
| description | String | پیش‌فرض `''` | `description` | Tasks.description |
| createdAt | DateTime? | اختیاری | ISO-8601 / null | Tasks.createdAt |
| updatedAt | DateTime? | اختیاری | ISO-8601 / null | Tasks.updatedAt |
| dueDate | DateTime? | اختیاری | ISO-8601 / null | Tasks.dueDate |
| followUpEnabled | bool | پیش‌فرض false | `followUpEnabled` | Tasks.followUpEnabled |
| followUpDate | DateTime? | اختیاری | ISO-8601 / null | Tasks.legacyFollowUpDate؛ حفظ برای سازگاری |
| tags | List<String> | پیش‌فرض [] | `tags` | رابطه TaskTags؛ بدون تکثیر Task |
| category | String? | اختیاری | `category` | Tasks.category یا Categories + شناسه؛ تصمیم نهایی فقط پس از ممیزی واقعی Category |
| checklist | List<String> | پیش‌فرض [] | `checklist` | ChecklistItems با ترتیب پایدار؛ متن/وضعیت باید بدون تغییر حفظ شود |
| notebookKind | NotebookItemKind? | اختیاری | `notebookKind` فقط در صورت وجود | Tasks.notebookKind |
| reminderDate | DateTime? | اختیاری | ISO-8601 / null | Tasks.reminderDate |
| priority | TaskPriority | پیش‌فرض none | `priority` فقط اگر none نباشد | Tasks.priority |
| archived | bool | پیش‌فرض false | `archived` | Tasks.archived |
| trashed | bool | پیش‌فرض false | `trashed` | Tasks.trashed |
| completed | bool | پیش‌فرض false | `completed` | Tasks.completed |
| followUps | List<FollowUp> | پیش‌فرض [] | `followUps` | FollowUps با taskId و همان id |
| recurrence | RecurrenceRule? | اختیاری | `recurrence` | TaskRecurrence یا ستون‌های معادل؛ بدون تغییر معنا |
| people | List<PersonReference> | پیش‌فرض [] | `people` فقط اگر غیرخالی | TaskPeople + Persons سبک یا JSON موقت؛ باید ID و displayName حفظ شود |

### نکته مهم درباره فیلدهای ناشناخته

`TaskMigrationWriter` در ویرایش Home، کل JSON موجود را می‌خواند و فیلدهای ناشناخته را در envelope حفظ می‌کند. بنابراین Migration نهایی نباید فقط از `Task.toJson()` به عنوان تنها منبع استفاده کند؛ باید Legacy JSON را نیز در گیت پذیرش مقایسه کند. هر کلید JSON موجود که در مدل typed ثبت نشده باشد، تا زمان تعیین مقصد صریحاً «حساس و حل‌نشده» است.

## 3. FollowUp

مدل واقعی:

- `id: String`
- `dateTime: DateTime`
- `note: String` با پیش‌فرض `''`
- `result: String?`
- `reminderDate: DateTime?`
- `nextFollowUp: DateTime?`
- `completed: bool` با پیش‌فرض false

JSON:

`id`, `dateTime`, `note`, `result`, `reminderDate`, `nextFollowUp`, `completed`.

Mapping:

`FollowUps.id = FollowUp.id` و `FollowUps.taskId = Task.id`.

ترتیب تاریخچه در Storage فعلی همان ترتیب آرایه `followUps` است و نباید بازچینی یا حذف شود. عملیات ویرایش نیز با شناسه FollowUp انجام می‌شود.

Legacy:

اگر `followUps` خالی/غایب باشد و `followUpDate` قدیمی وجود داشته باشد، `Task.fromJson` آن را به تاریخ فعال FollowUp تبدیل نمی‌کند؛ مقدار `followUpDate` را به عنوان فیلد سازگاری نگه می‌دارد. این تفاوت باید در Migration تست شود و بدون تصمیم صریح تبدیل دیگری انجام نشود.

## 4. Project

مدل `ProjectPlan`:

- `id: String`
- `title: String`
- `colorValue: int`، پیش‌فرض `0xFF4A4CAB`
- `isArchived: bool`، پیش‌فرض false
- `itemIds: List<String>`، شناسه‌های Task

Storage: `arvin.projects`.

Project payload Task را کپی نمی‌کند. ارتباط از طریق `ProjectPlan.itemIds` است و هر Task در قرارداد فعلی حداکثر عضو یک Project است.

Mapping:

- Projects.id ← ProjectPlan.id
- Projects.title ← title
- Projects.colorValue ← colorValue
- Projects.isArchived ← isArchived
- ProjectItems(projectId, taskId, order) ← itemIds با حفظ ترتیب

حذف Project دارای آیتم مجاز نیست؛ Migration نباید این رابطه‌ها را حذف کند.

## 5. Category

در Storage فعلی Category موجودیت مستقل با کلید جداگانه ندارد.

- Task.category ← نام/مقدار Category.
- Notebook نیز Category را از همان Task.category استخراج می‌کند.
- بنابراین ساخت جدول مستقل Categories در G1 فقط به عنوان مقصد احتمالی ثبت می‌شود و نباید فهرست جعلی یا داده تکراری ساخته شود.

اگر در ممیزی بعدی مسیر مستقلی برای Category پیدا شود، آن مسیر باید به همین سند افزوده شود و قبل از G1-DRIFT تأیید شود.

## 6. Tag

Storage عمومی: `arvin.tags` با نوع SharedPreferences String List.

ارتباط Task: `Task.tags: List<String>` در `arvin.tasks`.

Mapping پیشنهادی:

- Tags.id/name ← مقدار یکتای Tag
- TaskTags.taskId ← Task.id
- TaskTags.tagId ← Tag همنام
- ترتیب Tags عمومی در صورت نیاز UI حفظ شود؛ رابطه TaskTags نباید باعث تکثیر Task شود.

اگر Tag حذف شود، هیچ Task نباید با شناسه Task جدید بازنویسی شود.

## 7. Notebook / Note / Checklist

Notebook Storage مستقل ندارد و `CanonicalNotebookRepository` فقط روی TaskStore کار می‌کند.

Note:
- همان Task با `notebookKind = note` یا legacy fallback برای شناسه `note-`.
- id، title، description، category، tags، project membership، createdAt و updatedAt همان داده canonical هستند.

Checklist:
- همان Task با `notebookKind = checklist` یا legacy تشخیص داده‌شده از checklist.
- `checklist: List<String>` شامل متن خام و پیشوند وضعیت `[ ]` / `[x]` است.
- Migration نباید این رشته‌ها را به متن ساده تبدیل کند؛ مقصد ChecklistItems باید order، text و completed را lossless نگه دارد.

Archive/Trash Notebook نیز همان `Task.archived` و `Task.trashed` است.

## 8. Archive / Trash

Storage جداگانه‌ای برای Task Archive/Trash پیدا نشد.

مبدأ:
- `Task.archived`
- `Task.trashed`

مقصد:
- ستون‌های مستقل روی Tasks.

هیچ حذف فیزیکی در Migration انجام نمی‌شود. Trash فقط وضعیت است تا زمانی که محصول صراحتاً حذف دائمی را اجرا کند.

## 9. کلیدهای SharedPreferences شناسایی‌شده

| کلید | نوع | مالک | مقصد/تصمیم |
|---|---|---|---|
| `arvin.tasks` | String(JSON list) | TaskStore / Notebook / FollowUp | Drift Tasks + FollowUps + ChecklistItems + TaskPeople |
| `arvin.projects` | String(JSON list) | ProjectStore | Projects + ProjectItems |
| `arvin.tags` | StringList | TagStore | Tags |
| `arvin.settings.themeMode` | String | AppSettingsService | Settings |
| `arvin.settings.usePersianDate` | bool | AppSettingsService | Settings |
| `arvin.settings.fontFamily` | String | AppSettingsService | Settings |
| `arvin.settings.swipeRightAction` | String | AppSettingsService | Settings |
| `arvin.settings.swipeLeftAction` | String | AppSettingsService | Settings |
| `arvin.settings.calendar.*` | bool/String/StringList | AppSettingsService | Settings/CalendarSettings |
| `arvin.calendar.externalLinks` | String(JSON list) | ExternalCalendarLinkStore | CalendarExternalLinks؛ metadata sync |
| `arvin.backup.directory` | String | ArvinBackupManager | Device/Settings metadata؛ مسیر فایل |
| `arvin.backup.schedule.enabled` | bool | BackupSchedule | BackupSettings |
| `arvin.backup.schedule.hour` | int | BackupSchedule | BackupSettings |
| `arvin.backup.schedule.minute` | int | BackupSchedule | BackupSettings |
| `arvin.backup.directoryUri` | String | BackupBackgroundRunner | legacy backup configuration؛ حفظ تا migration سازگار |
| `arvin.backup.payload` | String(JSON) | BackupBackgroundRunner | legacy compatibility only؛ نباید منبع canonical داده باشد |
| `arvin.dailyContent.enabled` | bool | DailyContentPreferencesService | DailyContentSettings |
| `arvin.dailyContent.notificationEnabled` | bool | DailyContentPreferencesService | DailyContentSettings |
| `arvin.dailyContent.notificationHour` | int | DailyContentPreferencesService | DailyContentSettings |
| `arvin.dailyContent.notificationMinute` | int | DailyContentPreferencesService | DailyContentSettings |
| `arvin.dailyContent.enabledKinds` | StringList | DailyContentPreferencesService | DailyContentSettings |
| `arvin.dailyContent.cachedPack.v1` | String(JSON) | DailyContentPackCache | Cache؛ قابل بازسازی، نه داده Task |
| `arvin.dailyContent.cachedPack.savedAt` | String | DailyContentPackCache | Cache metadata |
| `arvin.guide.homeCoachMarksSeen.v1` | bool | InteractiveGuideService | UI preference؛ قابل بازسازی |
| `arvin.prayer_completion.v1` | String(JSON list) | PrayerCompletionStore | PrayerCompletion |
| `arvin.followup.notificationState` | String(JSON map) | AutomaticFollowUpBackgroundRunner | FollowUpNotificationState |
| `arvin.followup.reminderNotificationState` | String(JSON map) | FollowUpReminderDeliveryState | FollowUpReminderState |

Native Android representation `flutter.arvin.tasks` نیز وجود دارد، اما منبع مستقل نیست؛ همان داده SharedPreferences مربوط به `arvin.tasks` است و نباید به جدول دوم تبدیل شود.

## 10. Backup

Backup عمومی تمام کلیدهای قابل پشتیبانی SharedPreferences را می‌تواند در envelope `arvin-backup` نسخه 1 قرار دهد. Backup canonical نیز Tasks و در صورت وجود Projects و Settings را در همان سند نگه می‌دارد.

قانون Migration:

1. Backup قدیمی قبل از Migration باید بدون تغییر قابل خواندن باشد.
2. Restore ابتدا باید candidate بسازد و قبل از نوشتن اعتبارسنجی شود.
3. IDها در Restore ثابت بمانند.
4. Duplicate Task/Project باید رد شود.
5. هیچ Backup قبلی حذف یا overwrite نشود.

نکته: `BackupBackgroundRunner` یک payload قدیمی محدود به چند فیلد Task دارد؛ آن payload برای Migration کامل کافی نیست و منبع canonical محسوب نمی‌شود. منبع کامل `TaskStore` و Backup canonical است.

## 11. Mapping هدف Drift

حداقل ساختار هدف:

- Tasks
- FollowUps
- Projects
- ProjectItems
- Tags
- TaskTags
- ChecklistItems
- TaskPeople / Persons
- Settings
- CalendarExternalLinks
- FollowUpNotificationState
- PrayerCompletion
- BackupSettings
- DailyContentSettings

Notes و Checklists جدول Task جدا ندارند مگر زمانی که داده واقعی نشان دهد جداشدن لازم است. Note/Checklist هویت خود را در Tasks نگه می‌دارند تا تبدیل Note ↔ Task همان ID را حفظ کند.

## 12. قوانین ID و Duplicate

- هیچ ID موجودی تولید مجدد نمی‌شود.
- ID Task فقط از `Task.id` می‌آید.
- ID FollowUp فقط از `FollowUp.id` می‌آید.
- ID Project فقط از `ProjectPlan.id` می‌آید.
- رابطه‌ها با همان IDها ساخته می‌شوند.
- Duplicate Task/FollowUp/Project قبل از درج رد می‌شود.
- Migration مجدد باید idempotent باشد: اجرای دوباره همان داده رکورد دوم نسازد.
- ترتیب Checklist و FollowUp حفظ می‌شود.

## 13. Verification

پیش از تغییر canonical path باید برای یک مجموعه نماینده:

1. تعداد Task قبل/بعد برابر باشد.
2. تعداد FollowUp قبل/بعد برابر باشد.
3. تعداد Project و ProjectItem برابر باشد.
4. تعداد Tag و TaskTag برابر باشد.
5. ChecklistItemها از نظر متن، وضعیت و ترتیب برابر باشند.
6. IDها دقیقاً برابر باشند.
7. عنوان، توضیح، وضعیت، موعد، یادآور، تکرار، پروژه، دسته، برچسب، Archive، Trash و Notebook برابر باشند.
8. FollowUp شامل تمام فیلدها و تاریخچه باشد.
9. JSON canonical قبل و بعد، پس از نرمال‌سازی مجاز، برابر باشد.
10. اجرای دوباره Migration هیچ رکورد تازه‌ای نسازد.
11. Backup قبل از Migration روی مسیر جدید نیز قابل Restore باشد.

## 14. Rollback

در G1:

- Legacy SharedPreferences حذف نمی‌شود.
- قبل از هر write مقصد، Legacy فقط خوانده می‌شود.
- تا زمان موفقیت Verification، TaskStore همان Storage اصلی باقی می‌ماند.
- شکست Migration نباید مقدار `arvin.tasks` را تغییر دهد.
- تغییر canonical read/write فقط بعد از Gate مستقل و Commit جداگانه مجاز است.

## 15. تست‌های موجود و تست‌های G1

پایه موجود:
- `test/services/task_migration_adapter_test.dart`
- `test/services/task_migration_writer_test.dart`
- `test/task_store_test.dart`
- `test/canonical_notebook_repository_test.dart`

این‌ها Duplicate ID، داده خراب، حفظ FollowUp، Notebook/Checklist، همان ID و رفتار Storage فعلی را پوشش می‌دهند.

تست G1 باید علاوه بر آن، round-trip همه فیلدهای واقعی Task، FollowUp، Recurrence، Person، NotebookKind، Project و روابط Tag/Project را کنترل کند. تست Failure باید ثابت کند Legacy بعد از شکست بدون تغییر قابل خواندن است.

## 16. موارد حل‌نشده قبل از G1-DRIFT

1. نمونه واقعی داده کاربر روی دستگاه در GitHub موجود نیست؛ بنابراین «مقدارهای واقعی کاربر» قابل استخراج نیستند. آنچه این سند قطعی می‌کند، schema و مسیرهای واقعی کد و JSON است.
2. هر کلید JSON ناشناخته در داده‌های runtime باید قبل از Migration نهایی استخراج و تعیین مقصد شود؛ سورس کد نمی‌تواند وجود یک کلید runtime اضافه را اثبات کند.
3. طراحی نهایی ستون‌های Settings/Cache نیازمند تصمیم جداگانه است که کدام preferenceها باید به Drift منتقل شوند و کدام باید SharedPreferences باقی بمانند.
4. جدول Category مستقل هنوز از داده واقعی موجود نتیجه نمی‌شود و نباید برای آن رکورد ساختگی ایجاد شود.
5. جدول‌های Drift هنوز ساخته نشده‌اند و این عمداً شرط G1 است.

## 17. نتیجه Gate

**G1-MAP: آماده برای ورود به طراحی اجرایی Drift، اما هنوز بدون ساخت Drift.**

این مرحله موفق است از نظر شناسایی ساختار کد، Storageهای فعلی و mapping اولیه lossless. قبل از G1-DRIFT فقط موارد بخش 16 باید در dataset/runtime acceptance بسته شوند؛ هیچ تغییر مسیر Storage در این Commit انجام نشده است.

مرجع اجرا: `TaskMigrationReader` → `TaskMigrationAdapter` → `TaskMigrationWriter` → سپس G1-DRIFT.
