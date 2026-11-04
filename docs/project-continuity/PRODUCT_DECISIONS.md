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
