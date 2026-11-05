# Product Decisions Register
Canonical register for durable product decisions. Detailed implementation and historical evidence live in IMPLEMENTATION_LOG.md and root CHANGELOG.md.

## Approved
| Decision | Status | Basis / boundary |
|---|---|---|
| Product hierarchy is Center > Project > Category > Task | APPROVED | Owner-confirmed product hierarchy; use the Persian term «مرکز», not «واحد», for the top level. |
| Official app font is bundled Vazirmatn | APPROVED | Owner-confirmed typography baseline; every page must use Vazirmatn. |
| PR #3052 stays OPEN / DRAFT / UNMERGED; main untouched; release NO-GO | APPROVED | Binding governance constraints for the active delivery stream. |
| Phase 1 sync direction is local-network, offline Local P2P; cloud/Dropbox is a separate future Phase 2 | APPROVED | Product direction only. This does not approve a particular pairing or conflict algorithm. |
| Task due date, independent TaskReminder, recurrence and historical FollowUp remain separate concepts | APPROVED | Canonical product/data semantics; no conflation or parallel storage. |
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
| Font | `Vazirmatn` | All app UI; no font-family change |
- Canonical implementation entry point: `lib/core/theme/arvin_theme.dart`; `ArvinColors` remains the semantic compatibility palette and maps shared primary/background/surface tokens to the new values.
- Shared Flutter `CardThemeData` and app-bar theme use the new light card/header tokens. Shared Home shell, navigation, radio/project selector and recurrence chip surfaces consume the central token aliases.
- Priority semantics stay unchanged: P1=high/red, P2=medium/blue, P3=low/amber, P4=none/neutral. User-facing labels remain Persian «اولویت ۱» … «اولویت ۴»; do not render literal English P1–P4 unless a later explicit UI decision authorizes it.
- Status chips retain their existing semantic states/colors; taxonomy remains Center → Project → Category → Tags, with contextual icons and separate existing semantic accent colors. No entity/model or priority enum remapping is authorized.
- **Coverage status:** foundation implemented; exhaustive conversion of every custom BoxDecoration/card-like surface across all screens and physical visual acceptance remain IN_PROGRESS / NOT VERIFIED. Do not describe the entire app as uniformly migrated until the cross-screen inventory and visual tests pass.
- Governance unchanged: PR #3052 OPEN / DRAFT / UNMERGED; main untouched; no merge/release; BLOCKED — RELEASE: NO-GO.
