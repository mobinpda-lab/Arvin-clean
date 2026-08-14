# Arvin reference projects

## Purpose

`Arvin-clean` is the production baseline. The repositories below are reference sources only; their code is not copied wholesale.

## 1. arvin-task-tracker

Reference: `mobinpda-lab/arvin-task-tracker`

Use this project primarily for proven product behavior around:

- Jalali/Persian date and time presentation.
- Follow-up history and follow-up-oriented task UX.
- Reminder/timezone behavior.
- Backup/restore and JSON-style persistence patterns.
- Persian typography and RTL interaction patterns.

Rule: reuse a proven pattern only after comparing it with the current `Arvin-clean` data model, tests, and migration path. The existing Arvin-clean Calendar is already stabilized, so it must not be replaced merely to match the reference project.

## 2. daftar-peygiri

Reference: `mobinpda-lab/daftar-peygiri`

This repository is a very small reference project whose current main tree contains the README plus GitHub Actions workflows (`build.yml` and `main.yml`). It therefore provides more useful evidence for CI/build organization than for application-domain implementation. The README identifies it as a follow-up office (`دفتر پیگیری امور`).

Use this project as a reference for:

- keeping build/validation automation explicit;
- separating workflow responsibilities;
- preserving reproducible Android/Flutter validation;
- treating CI as part of the project architecture, not as an afterthought.

Do not copy application code from this repository unless a future revision adds actual domain implementation that has been reviewed.

## Combined strategy

The two references complement each other:

| Area | arvin-task-tracker | daftar-peygiri | Arvin-clean decision |
|---|---|---|---|
| Follow-up UX | primary reference | domain naming/context | combine selectively |
| Jalali calendar | primary reference | not currently implemented | keep stabilized Arvin-clean Calendar |
| Reminder/timezone | primary reference | not currently implemented | reuse proven behavior after tests |
| Persistence | primary reference | not currently implemented | preserve Arvin-clean migration/backup contract |
| CI/workflows | useful secondary reference | primary current evidence | keep parallel independent waves |
| Documentation | product reference | minimal README | maintain explicit Arvin-clean project docs |

## No-regression rule

Before every code change:

1. Check current `main` and open PRs.
2. Check whether the requested behavior already exists.
3. Compare the relevant Arvin-clean implementation with both reference projects.
4. Change only the missing or defective layer.
5. Add/update focused tests.
6. Run independent commits and workflows in parallel whenever dependencies allow.
7. Never redo a previously green fix just because an older workflow run is still red.
8. Never replace a stabilized subsystem without a demonstrated regression or a clearly documented product requirement.

## Current roadmap impact

The next functional focus remains safe FollowUp integration:

`FollowUp storage -> TaskStore -> FollowUp service -> Entry UI -> Task Editor -> HomePage -> Calendar/reminder -> E2E -> APK`.

The reference projects guide implementation choices, but `Arvin-clean` remains the source of truth for its architecture, data compatibility, tests, and release pipeline.
