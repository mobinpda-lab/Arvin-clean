# Jalali Task Report Contract — 2026-08-28

Issue: #373

## Owner requirement
All user-visible Task report dates in Arvin PDF/Print/Share output are Persian/Jalali. Time remains hour/minute and digits are Persian.

## Canonical implementation
- reuse `PersianDateFormatter`
- reuse `TaskReportProjection`
- reuse `TaskReportPdfRenderer`
- no second PDF/Print renderer or calendar converter

## Covered dates
- report generated-at timestamp
- Task reminder timestamps represented by the report projection
- every canonical FollowUp `dateTime`

## Report scopes preserved
- single Task detail
- selected/multiple Tasks
- all/applicable Task list
- FollowUps stay associated with their owning Task

## Safety
Export/print is read-only and must not mutate Task/FollowUp data.

## Evidence required
Focused deterministic Jalali conversion test, PDF-byte regression, exact-head CI/APK/device/interaction validation as applicable, then post-merge current-main validation before closure.
