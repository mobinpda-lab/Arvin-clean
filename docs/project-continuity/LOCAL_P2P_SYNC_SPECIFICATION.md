# Arvin Local P2P Sync — Phase 1 Design Specification

- Reference: `ARVIN-EXEC-1405/08/14-LOCAL-P2P-SYNC`
- Repository: `mobinpda-lab/Arvin-clean`
- Authorized branch: `fix/recovery-calendar-device-smoke-2026-10-31`
- PR: `#3052` (must remain OPEN / DRAFT / UNMERGED)
- Design status: **PHASE 1 DESIGN DRAFT — IMPLEMENTATION NOT VERIFIED**
- Release status: **BLOCKED — RELEASE: NO-GO**
- Document scope: Phase 1 local-network device-to-device synchronization only

## 1. Executive summary and scope

Phase 1 defines direct, user-authorized synchronization between two Arvin installations over a shared local Wi-Fi network. Both devices retain their own local SQLite database and remain usable offline. The network is a temporary transport between paired devices; it is not a replacement for local persistence.

Phase 1 MUST NOT require Internet access, a cloud account, Dropbox, a hosted relay, or a remote synchronization server. A phone hotspot is in scope only when both devices can reach one another over that local network. The protocol must tolerate temporary disconnection without losing locally committed work.

This document specifies intended behavior and safety constraints. It does not claim that discovery, pairing, transport, journaling, conflict handling, or synchronization code exists. All implementation and acceptance status remains **NOT VERIFIED** until evidenced on an exact candidate SHA.

## 2. Phase boundary

### 2.1 Phase 1 — Local P2P

In scope:
- Two explicitly paired Arvin devices on the same reachable local Wi-Fi network.
- Direct local discovery and authenticated device-to-device transport.
- First-time pairing by scanning a QR code or entering a four-digit PIN.
- Bidirectional, resumable exchange of validated Arvin changes.
- Durable local change tracking, idempotent apply, acknowledgements and conflict visibility.
- User-controlled trusted-device revocation.
- Non-destructive persistence and migration compatibility.

### 2.2 Phase 2 — Cloud / Dropbox (deferred)

Cloud/Dropbox is a separate future phase and is not a dependency, fallback, relay, bootstrap service, or hidden requirement of Phase 1. Phase 1 must continue to work with Internet disabled. OAuth, cloud accounts, remote storage, provider APIs, cloud conflict coordination and cloud recovery are out of scope here and require a separate specification and owner authorization.

## 3. Operating assumptions and network model

- Both devices run a compatible Arvin protocol version and are connected to a common local network.
- The network may block client-to-client traffic, multicast or broadcast. Discovery failure must be reported as unavailable; it must not trigger cloud fallback.
- Internet availability is irrelevant to the Phase 1 success path.
- Either device may initiate a session; each device remains independently usable during disconnection.
- The transport must bind the session to the authenticated paired-device identity, not merely to an IP address, hostname, SSID or user-entered display name.
- Network discovery, transport framework, port allocation, Android foreground/background execution policy and retry/backoff values remain implementation decisions requiring platform review. Do not assume a specific discovery protocol or fixed port without that review.

## 4. Pairing and trust establishment

### 4.1 User experience

1. The user opens **Devices / Local Sync** and chooses “Pair a device”.
2. The initiating device displays a one-time QR code and a four-digit PIN for the same pairing session.
3. The receiving device scans the QR code or enters the four-digit PIN.
4. Both devices display the peer identity and require explicit confirmation before trust is established.
5. The devices establish authenticated encrypted transport and verify the pairing transcript before exchanging application data.
6. Each device records the paired peer as ACTIVE and shows the last successful connection/sync state.
7. The user can suspend or revoke a peer from the device-management screen.

The QR and PIN are alternative bootstrap UX paths for one short-lived pairing session; neither is a reusable account password or long-term device credential.

### 4.2 Four-digit PIN security constraints

A four-digit PIN has only 10,000 possible values and is not sufficient by itself to authenticate a peer or protect data. Therefore:
- PIN validity must be short-lived and bound to one pairing session.
- Enforce strict attempt limits, progressive delay and session invalidation after repeated failures.
- Never expose a PIN in logs, analytics, crash reports or persistent storage.
- Do not permit PIN-only pairing over an untrusted network without an authenticated key-establishment protocol and explicit peer confirmation.
- Prefer QR bootstrap where practical because it can carry stronger, high-entropy, one-time session material.
- The QR payload must also expire, be single-use, and be bound to the intended pairing session.
- The exact entropy, expiry, retry budget and confirmation UX require security review before implementation.

### 4.3 Device trust lifecycle

Proposed states:
- PENDING — pairing started but not confirmed.
- ACTIVE — pairing completed and peer is trusted.
- SUSPENDED — temporarily disallowed from syncing.
- REVOKED — trust removed; future sessions rejected.

Revocation must take effect locally immediately. A revoked peer must not be able to reconnect using a previously captured QR/PIN or stale session credential. Recovery/re-pairing is a new explicit user action.

## 5. Security and privacy requirements

- Pairing and all data transfer must use authenticated encryption.
- Authenticate the peer cryptographically; never trust a network address as identity.
- Validate protocol version, message type, payload size, schema and entity ownership before applying data.
- Reject malformed, oversized, replayed, unauthenticated or unsupported operations without mutating application records or advancing a sync cursor.
- Store long-lived private keys and credentials only in platform-secure storage. Never commit secrets or test credentials.
- Minimize metadata disclosure: do not transmit unrelated device information, contact lists, advertising identifiers or location.
- Do not log task titles, descriptions, reminder contents, follow-up notes, PINs, QR secrets, private keys or full synchronization payloads.
- Provide a clear user-visible paired-device list and revoke action.
- Use explicit user consent for first pairing. No silent trust based solely on the same Wi-Fi network.
- Threat model must include hostile peers on shared/public Wi-Fi, replay, tampering, downgrade, device loss, credential theft, clock skew, network interruption and accidental cross-device pairing.
- Cipher suite, key agreement, identity format, certificate/pinning model, key rotation and recovery must be selected in a separate security-reviewed technical contract. This document does not prescribe an unreviewed cryptographic primitive.

## 6. Data ownership and exchange model

### 6.1 Canonical domain boundaries

Phase 1 may synchronize only explicitly approved Arvin domain data through existing canonical application/domain and repository/store pathways. Initial candidate scope:
- Task records and their canonical metadata.
- Independent TaskReminder records.
- Recurrence definitions/projections only as defined by the canonical recurrence model.
- Historical FollowUp records.
- Arvin-owned calendar data that is explicitly included in the approved sync contract.

The following concepts must remain independent:
- Task due date is not a Reminder.
- TaskReminder is independent of Task due date and Follow-up history.
- Recurrence is not a historical FollowUp.
- FollowUp history is not a future scheduling field.
- External phone-owned calendar events must not silently become Arvin-owned records.

Do not reintroduce deprecated future-follow-up scheduling semantics or treat legacy compatibility columns as the new source of truth. Preserve the canonical FollowUp date/time semantics already established by the product.

### 6.2 Excluded data until explicitly approved

Do not sync:
- Authentication secrets, local encryption keys or pairing credentials.
- OS notifications, alarm runtime state, transient UI state or device-local permissions.
- Arbitrary files/attachments unless a separate content-transfer contract is approved.
- External calendar content that Arvin does not own.
- Analytics, location, contacts or unrelated device metadata.

### 6.3 Logical operation envelope

Each exchanged change should use a versioned logical envelope. The following is a conceptual contract, not a committed database schema:

| Field | Purpose |
|---|---|
| protocolVersion | Negotiated wire-protocol compatibility |
| operationId | Globally unique, immutable idempotency key |
| originDeviceId | Stable pseudonymous identity of the originating paired device |
| entityType | Allow-listed canonical entity kind |
| entityId | Stable canonical entity identifier |
| operationKind | CREATE, UPDATE or DELETE |
| entityVersion | Domain/entity version or causal metadata |
| payloadSchemaVersion | Version of the validated entity payload |
| payload | Minimal canonical data required to apply the operation |
| integrity/authentication data | Bound to the authenticated encrypted session |

A transport sequence number/cursor may be used for resumability, but it is not a substitute for entity causality or a global wall-clock ordering. Exact field encoding, identifiers and compatibility rules remain to be finalized in the protocol implementation contract.

### 6.4 Local change journal

- A local mutation must be committed through the canonical repository/store and recorded durably for outbound sync as one atomic logical operation.
- A network failure must never roll back or discard an already committed local change.
- The journal must support retry after process death and app restart.
- Operation IDs must remain stable across retries.
- Acknowledgement and cursor advancement occur only after the receiver has validated and durably applied the operation, or safely recognized it as an already-applied duplicate.
- Retention/compaction must not remove an unacknowledged operation needed by any active trusted peer.
- Journal schema and transaction boundaries must be reviewed against the existing SQLite/Drift migration contract before implementation.

### 6.5 Receive and apply transaction

For each incoming operation:
1. Authenticate the session and verify the peer is ACTIVE.
2. Validate protocol version, envelope, payload size, schema and allow-listed entity type.
3. Check operation identity for duplicate/replay handling.
4. Validate domain invariants and referenced entities.
5. Apply the mutation and record the applied operation identity atomically in the local database.
6. Commit the transaction.
7. Only then acknowledge the operation and advance the durable receive cursor.

If validation or persistence fails, do not partially mutate records, acknowledge the operation, or advance the cursor. The sender must be able to retry safely.

## 7. Non-destructive synchronization and data safety

- Each device's existing local SQLite database remains authoritative for its locally committed data.
- Do not copy, replace, overwrite or swap whole SQLite database files over the network.
- Do not create a parallel database, duplicate domain model or bypass repository/DAO boundaries.
- Apply accepted operations transactionally through canonical repositories/DAOs.
- Preserve existing records and backward-compatible migrations. No destructive schema migration is permitted as part of sync enablement.
- A failed sync must leave the last committed local state intact.
- Sync must not silently delete records, reset local identifiers, rewrite unrelated fields or overwrite data merely because a peer has an older snapshot.
- Before any migration or journal activation, define backup/recovery behavior and verify preservation of legacy fields and user records.
- Any schema evolution must use non-destructive migrations with explicit tests for existing database fixtures and real-data backup/restore procedures.
- Snapshot/bootstrap transfer, if needed for first sync, must be validated and merged through the same safe domain rules; it must not replace the receiver's database.

## 8. Conflict detection and resolution

- Conflicts must be detected and represented explicitly; silent loss of a locally committed change is prohibited.
- Do not use device-local wall-clock time as the sole winner-selection rule. Device clocks can be skewed, changed or unsynchronized.
- LWW is not approved as a universal conflict policy. Tombstones are a candidate deletion mechanism, not an approved implementation contract.
- Prefer domain-specific merge rules only where semantics are deterministic, documented and covered by tests.
- When safe automatic resolution is unavailable, retain both competing versions/operations and surface a user-resolvable conflict rather than silently discarding either.
- Deletion versus concurrent edit, parent/child deletion, reminder edits, recurrence changes, FollowUp history and calendar ownership require explicit per-entity rules.
- Tombstone identity, retention, acknowledgement from all relevant peers and safe garbage collection must be specified before deletion propagation is implemented.
- Conflict metadata and resolution must be persisted transactionally and remain recoverable after app restart.

## 9. Discovery, transfer, retry and resume

- Discovery is limited to the local network and must reveal only the minimum metadata needed to identify an already paired peer.
- Discovery results are hints, not proof of identity; authenticate before data exchange.
- A sync session negotiates supported protocol and payload schema versions before transfer.
- Transfer is bounded and paginated; avoid loading the entire journal or dataset into memory.
- Use acknowledgements and durable cursors so interrupted transfers can resume.
- Retries must be idempotent and use bounded backoff; repeated failure must not block ordinary local app use.
- If the local network isolates clients, show a useful “device not reachable on this network” state. Never fall back to cloud in Phase 1.
- Background execution is subject to Android lifecycle and battery restrictions; user-visible status and a safe foreground/manual retry path may be required. Exact scheduling behavior requires platform validation.

## 10. Observability and user controls

User-visible states should distinguish:
- Not paired.
- Pairing pending / confirmation required.
- Paired and reachable.
- Syncing.
- Up to date.
- Waiting for network / peer unavailable.
- Conflict needs attention.
- Sync failed; retry available.
- Suspended or revoked.

Diagnostics must use redacted identifiers and aggregate counts/status only. Never include sensitive payloads or pairing secrets.

## 11. Compatibility and migration

- Negotiate protocol and payload schema versions explicitly.
- Unknown required fields or unsupported major versions must fail closed without destructive writes.
- Minor-version compatibility must be specified and tested before release.
- Keep database migrations additive/non-destructive wherever possible.
- Preserve Task, TaskReminder, recurrence and FollowUp semantics and existing migration compatibility.
- Do not remove legacy columns until real database inventory, backup, conversion, rollback and exact acceptance tests have been completed and separately authorized.

## 12. Required test and acceptance matrix

| Area | Minimum evidence |
|---|---|
| Pairing | QR and four-digit PIN paths; expiry; replay rejection; rate limiting; wrong-peer confirmation |
| Security | Authenticated encrypted channel; unauthorized peer rejection; tamper and downgrade rejection; credential redaction |
| Offline | Initial pairing and sync with Internet disabled |
| Network | Same Wi-Fi, hotspot, client isolation, network loss and reconnect |
| Durability | App restart/process death during outbound and inbound transfer |
| Idempotency | Duplicate operation delivery and retry produce no duplicate or extra mutation |
| Data integrity | Invalid payload does not partially write or advance cursor |
| Conflicts | Concurrent edits, delete/edit, parent/child and each supported entity type |
| Revocation | Revoked device cannot reconnect or submit operations |
| Persistence | Existing database fixtures and non-destructive migration/backup/restore |
| Domain semantics | Task due date, TaskReminder, recurrence and FollowUp remain independent |
| Physical devices | At least two real Android devices, exact app/protocol build, documented network conditions |
| Regression | Existing unit/widget/integration tests remain intact and pass on the same exact candidate SHA |

A green compile or single-device test is not evidence of P2P synchronization acceptance.

## 13. Delivery waves and gates

1. **P2P-0 — Contract:** threat model, ownership matrix, protocol envelope, compatibility and conflict matrix; obtain explicit owner/security approval.
2. **P2P-1 — Pairing:** local discovery, QR/PIN session, authenticated key establishment, trust lifecycle and revocation.
3. **P2P-2 — Durability:** journal, operation identity, transactional write and migration tests.
4. **P2P-3 — Transport:** bidirectional transfer, acknowledgement, retry and resume.
5. **P2P-4 — Conflict:** detection, persistence, user visibility and approved per-entity resolution.
6. **P2P-5 — Recovery:** deletion retention, backup/restore and interrupted-session recovery.
7. **P2P-6 — Acceptance:** security review, multi-device simulation and physical Android tests.
8. **P2P-7 — Controlled release:** only after exact-SHA CI, owner acceptance and all existing Arvin release gates pass.

No implementation wave is authorized merely by the existence of this design document. The pairing UX requested here is recorded as a design requirement; cryptographic protocol, conflict algorithm and schema remain subject to technical/security review.

## 14. Explicit non-claims and current status

- Local P2P code: **NOT VERIFIED**.
- QR pairing implementation: **NOT VERIFIED**.
- Four-digit PIN pairing implementation/security: **NOT VERIFIED**.
- Local discovery and encrypted transport: **NOT VERIFIED**.
- Journal, acknowledgement and resume: **NOT VERIFIED**.
- Conflict/tombstone implementation: **NOT VERIFIED**.
- Two-device physical acceptance: **NOT VERIFIED**.
- Cloud/Dropbox Phase 2: **DEFERRED; NOT PART OF PHASE 1**.

## 15. Governance

- Work only on `fix/recovery-calendar-device-smoke-2026-10-31`.
- Keep PR #3052 OPEN / DRAFT / UNMERGED.
- Do not modify `main`, merge, rebase, force-push, publish or release.
- Do not delete, weaken, skip or bypass tests.
- Official app font remains bundled **Vazirmatn** only.
- Release remains **BLOCKED — RELEASE: NO-GO** until all required gates pass on one exact candidate SHA and product-owner acceptance is recorded.

---
Document reference: `ARVIN-EXEC-1405/08/14-LOCAL-P2P-SYNC`


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
