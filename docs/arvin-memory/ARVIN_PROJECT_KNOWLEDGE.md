# Arvin Project Knowledge

Updated: 2026-10-11
Repository: https://github.com/mobinpda-lab/Arvin-clean

## Authoritative continuation rule
Always re-fetch current main, PR heads/bases, issues, source files and exact-head workflow results before acting. A chat summary is only a pointer; GitHub is authoritative. Do not infer current CI state from a previous commit.

## Product and architecture invariants
- Task is the canonical actionable entity and source of truth.
- Quick Add and Full Task Form create/edit the same Task.
- Canonical taxonomy concepts are Project, Category and Tag. Category and Group are one concept; technical name `Category`, Persian UI term «دسته». No independent Group entity/store.
- Checklist and repeat belong to Task. Repeating does not create duplicate root Tasks; past execution/history remains immutable.
- Calendar is a projection of Task, not an owner. Create one external event and then update by stable Task/external event identity; never deduplicate by title/date.
- Home, Reports, Calendar, widgets and backup/restore must not become independent sources of truth.
- Fix existing paths; avoid parallel storage, backup formats, repositories or engines.
- Before migration or data-risk changes, require backup, rollback strategy and restore evidence.

## Backup/restore knowledge from live code review
- Canonical Category and Tag catalogs are independent of whether any Task currently uses them; backups must preserve unassigned values.
- Restore spans Task, Project, Calendar-link, settings and taxonomy stores. A failure can leave partial state unless rollback covers each mutated store.
- Commit [05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354) adds Category/Tag snapshots and rollback cleanup for newly imported catalog entries in both Home and BackupPage, plus failure-injection test seams.
- Exact-head Build and Android smoke were not complete at last check. This is an implementation checkpoint, not a validated fix yet.
- Old backup compatibility must be preserved; missing/null optional data must not be confused with an explicitly empty collection.

## Taxonomy and relationship caution
- Current decision is in [ADR-2026-10-10-PCTADP](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md), Issue #2582.
- Do not assume the conceptual Project → Category → Task drawing proves a database foreign key from Category to Project. Verify the actual model/schema.
- Issue #2580 remains open until the full cross-surface conformance audit is evidenced.

## User experience memory
- User reported missing «ثبت در تقویم گوشی» and «ویرایش» actions in Arvin's Calendar task view on 2026-10-09. Treat as an open user-reported regression until inspected and validated; do not silently mark fixed.
- Reports should be product-centered and plain Persian, distinguish verified facts from pending/unproven work, and include GitHub Read/Write status for each autonomous run.

## Release quality
Green CI and emulator tests are necessary but insufficient. Release evidence must include physical device/file-provider backup/restore, Calendar no-duplicate identity, and Golden Flow acceptance, plus user/install docs and known issues.
