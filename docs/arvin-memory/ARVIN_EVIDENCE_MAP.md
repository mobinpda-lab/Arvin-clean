# Arvin Evidence Map

Updated: 2026-10-11 (owner-approved backup expansion; reconciliation and portable settings implementation)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write verified.

| Feature / gate | Evidence | Current status | Limitation / next proof |
|---|---|---|---|
| Mainline | [main commit 72a2f4c](https://github.com/mobinpda-lab/Arvin-clean/commit/72a2f4cc24df7a38eff9856ce403461615db5280) | Base snapshot previously confirmed; documentation-only PCTADP registration | Recheck live base/head before merge |
| Calendar linked-event edit | [PR #2570](https://github.com/mobinpda-lab/Arvin-clean/pull/2570); [commit 34a6cee](https://github.com/mobinpda-lab/Arvin-clean/commit/34a6cee9ae05ad1cf632960b96e98f2a5448e128) | Merged; automated regression expects update=1/create=0 and stable external event ID | Physical-device same-event/no-duplicate proof remains NOT VERIFIED |
| Backup/restore reconciliation | [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585); current checkpoint head [5f59d7c](https://github.com/mobinpda-lab/Arvin-clean/commit/5f59d7c7edb12217a2aa3f7a139a042676dc0e76) | OPEN / NOT MERGED. Stable-ID Task reconciliation, Project merge preserving local-only memberships, and settings-key merge implemented | Exact-head Analyze + six test shards SUCCESS; Debug APK SUCCESS; Release APK IN_PROGRESS. Device Smoke: Home/Quick Capture SUCCESS; SQL Migration/SQL Persistence IN_PROGRESS; Backup/Restore/People QUEUED |
| Catalog portability | [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580); [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) | Owner approved unused Category/Tag portability. Optional `categories`/`tags` remain backward-compatible in v1; merge is additive | Exact-head tests and physical file-provider/data-integrity acceptance required |
| Notes / Notebook checklists | [canonical Task model](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/models/task.dart); [Notebook repository](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/services/canonical_notebook_repository.dart); PR #2585 | Notes/checklists are canonical Task records; regression added for local-only note/checklist retention | Verify backup round-trip and late-failure rollback on exact head and physical device |
| Portable app settings | [AppSettingsService](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/services/app_settings_service.dart); [Daily Content preferences](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/services/daily_content_preferences_service.dart); PR #2585 | App settings, backup schedule and Daily Content preferences included in foreground and scheduled backups; missing legacy keys preserve local values; explicit nullable defaults serialize | Exact-head Analyze, six test shards and Debug APK passed; Release APK and Device Smoke still pending; confirm all supported portable settings in round-trip |
| Scheduled backup payload | [BackupBackgroundRunner](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/backup_background_runner.dart); [test](https://github.com/mobinpda-lab/Arvin-clean/blob/main/test/backup_background_runner_test.dart) | Payload now includes Tasks, Projects, portable settings/schedule, Daily Content preferences, Calendar links, Category and Tag catalogs | Exact-head Release APK and Device Smoke still in progress at latest check; no physical scheduled-backup proof |
| Restore rollback | [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) | Existing multi-store rollback retained; new settings validation happens before restore writes; snapshots include portable settings | Exact-head test shards passed; Device Smoke Backup/Restore queued; physical failed-restore recovery required |
| Calendar actions and recurrence | [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587); [P0 #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) | OPEN / NOT MERGED at `4442ce4`; prior Build #38089112669 and Device Smoke #38089112675 succeeded across six emulator lanes | Physical-device visibility, recurrence/checklist and provider behavior remain NOT VERIFIED |
| Memory documentation | [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600) | OPEN / DRAFT; state and evidence map refreshed on its existing branch | Recheck exact-head Build after documentation commit; docs-only Device Smoke is not product validation |
| Taxonomy architecture | [Canonical ADR](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md); [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) | Project, Category and Tag are separate concepts; Category/Group is one concept; conformance audit remains OPEN | Finish code/UI/docs/persistence inventory; do not infer Category-to-Project relation without source evidence |
| Legacy TagStore | [tag_store.dart](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/services/tag_store.dart); [historical commit 3073cb8](https://github.com/mobinpda-lab/Arvin-clean/commit/3073cb8593ac80783c6cb4647640dc05390375a5) | LOW-CONFIDENCE LEGACY CANDIDATE: no current caller found; SQL migration derives tags from Task.tags | Preserve key/file absent evidence of shipped use |
| Physical Android backup/restore | No linked physical-device evidence | NOT VERIFIED | Test actual Android system file picker/provider, legacy restore, failed-restore recovery and before/after data integrity |
| Calendar identity/no duplicates after restore | No linked physical-device evidence | NOT VERIFIED | Record Task ID, external event ID and event count before/after edit/re-sync and restore |
| Golden Flow | No complete end-to-end evidence | NOT VERIFIED | Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore |
| Release handover | No complete handover package evidenced | PENDING | Release notes, installation guide, user guide, known issues, architecture summary, evidence report and owner acceptance |

## Backup/restore owner contract — Issue #2580 / PR #2585

Owner-approved contract:
- Include Tasks, Notes/Notebook checklists, Projects, Calendar-link metadata, Category/Tag catalogs and all portable app settings.
- Restore validates the backup before writes, then reconciles by stable canonical IDs: matching records update; backup-only records add; local-only records remain unless the owner explicitly selects full replacement.
- Never match Tasks or Projects by title/date. Preserve history, checklist, repeat, follow-up, project membership and Calendar-link identity.
- Catalogs merge additively, retaining local-only Category/Tag entries.
- Only settings keys present in a backup update values. Omitted fields in legacy v1 backups must not reset current settings. Explicit nullable defaults in new backups are preserved.
- Include portable Daily Content preferences and backup schedule. Exclude secrets, passphrases and device-bound OS permissions/provider URIs.
- Snapshot current state and test rollback through the existing multi-store orchestration. Do not create a parallel restore engine.

Implementation checkpoint: PR #2585 current checkpoint head `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`. Exact-head Analyze SUCCESS; Build and Device Smoke not yet complete at this checkpoint. A prior head's Analyze failed on two unnecessary null assertions; the assertions were removed before the current head.

## Taxonomy audit checkpoint — Issue #2580
- `Task.category` and `Task.tags` are separate fields on the canonical Task model.
- `ProjectPlan.itemIds` references canonical Task IDs; the model itself does not declare Category ownership.
- `HomeGroup<Task>` is a presentation grouping abstraction, not a domain Group entity.
- Do not infer a physical Category-to-Project foreign key from the semantic hierarchy.
- Classify uses of “group” as domain, user-facing wording, presentation grouping, generic technical term or historical document before edits.

## Release gate
All CI/emulator successes are automated evidence only. Physical-device/file-provider data integrity, Calendar provider identity/no-duplicate behavior, full Golden Flow and explicit owner acceptance remain unproven. Keep PR #2585 and #2587 unmerged until their respective acceptance gates are satisfied.
