# Arvin-clean CI Mainline Baseline Audit

Date: 2026-08-22
Repository: mobinpda-lab/Arvin-clean
Base branch: main
Base SHA: d3d5664b3261c7d92762c39ffc7526261feca074
Working branch: chore/ci-mainline-baseline-audit

## Access
- Repository is public.
- GitHub connector permissions: admin, maintain, triage, pull, push.
- Read: confirmed.
- Write: confirmed by successful branch creation and file creation on the audit branch.
- Connection: operational for repository read/write operations.

## Mainline snapshot
Latest main commit:
- SHA: d3d5664b3261c7d92762c39ffc7526261feca074
- Title: docs: formalize Arvin continuation command (#113) (#114)
- Time: 2026-08-21T07:27:57Z

## Important commits
### e66affd19bb4961410ba03daeba313eaceebcb70
The commit was requested for audit. No workflow run was returned by the commit workflow-run endpoint. Its exact role should therefore be treated as unverified by this endpoint.

### e6775c0db6101edd8299426033d6ff3e5abfb1b6
Title: fix(core): restore untouched Home implementation
The commit restores the legacy Home implementation and removes the direct TaskStore interface from the legacy TaskRepository path. A PR-merge workflow run was observed for this commit.

Observed CI:
- Arvin Build run 32382968494: failure.
- Arvin Parallel Wave run 32382968466: failure.

The actual Build failure was not Android compilation. The workflow reached Flutter analyze successfully, then flutter test failed with one widget test. The failing test was:
`HomePage loads legacy storage through the unified reader`
Expected text: `پیگیری: 2026/08/20`
Actual: zero matching widgets.
Result: 94 tests passed, 1 failed. APK build steps were skipped because the test step failed.

The Parallel Wave quality job failed at flutter test, while its Android release job and followup/calendar/backup/typography surface jobs succeeded for that run.

### 29edac0047ab116511a7388f69a5369a3ce792f4
Title: test: restore legacy follow-up migration coverage
Observed CI:
- Arvin Build run 32418254623: success.
- Arvin Parallel Wave run 32418254745: success.
This is evidence that the previously observed test regression path was later restored to green on this commit.

## Workflow audit
### .github/workflows/build.yml
- Triggers: push to main/master, pull_request to main/master, workflow_dispatch.
- Permissions: contents: read.
- Flutter: stable channel; the observed historical run resolved stable to Flutter 3.47.1.
- Steps: checkout, Flutter setup, Android platform generation, Android desugaring configuration, pub get, analyze, test, release APK build, APK existence check, release artifact upload, debug APK build/check/upload.
- Artifact paths: build/app/outputs/flutter-apk/app-release.apk and app-debug.apk.

The workflow currently executes:
`flutter create --no-pub --platforms=android --project-name arvin .`
Evidence from run 32382968494 shows that this command recreated Android project files, including MainActivity.kt, Gradle files, Android manifests/resources and related project metadata. Therefore it is not a harmless no-op. It can materially affect the CI working tree. This audit does not remove it because the project rule requires evidence before changing it.

### .github/workflows/parallel-wave.yml
- Triggers: push to wave/**, ci/**, fix/**; pull_request to main; workflow_dispatch.
- Permissions: contents: read.
- Flutter: pinned to 3.47.0.
- Jobs: quality, android-release, surface matrix.
- Quality: pub get, analyze, test.
- Android release: conditional Android generation, desugaring configuration, Android V2 audit, release APK build, APK verification, artifact upload.
- Surface matrix: followup, calendar, backup, typography focused validation.

## Current project snapshot
pubspec.yaml currently declares:
- Flutter SDK
- shared_preferences
- saf
- android_alarm_manager_plus
- flutter_local_notifications
- flutter_test
- flutter_lints

Application version in pubspec.yaml: 1.0.0+1.
SDK constraint: >=3.3.0 <4.0.0.

main.dart currently contains the legacy-facing ArvinTask/Home implementation and reads through TaskMigrationReader. The legacy TaskRepository still uses SharedPreferences with key `arvin.tasks` for writes. This confirms that storage migration is not a reason to modify this CI-only branch.

## Capabilities observed in repository/tests
The repository contains evidence for Task, FollowUp, recurrence, migration, Calendar/Jalali, official-calendar reminders, Backup/Restore, Dropbox/cloud provider tests and UI tests. Reminder dependencies are present in pubspec.yaml. A dedicated Reminder model PR (#116) is open, so Reminder implementation must not be recreated without auditing that PR first.

The following product capabilities were not fully re-verified by this baseline-only branch and remain outside scope:
- full production Reminder notification flow
- Prayer Reminder production implementation
- complete Widget implementation
- complete PDF/Print production flow
- complete Security/release validation

## Validation status for this audit branch
No local Flutter commands were executed by the GitHub connector environment. Therefore this document does not claim local results for:
- flutter --version
- dart --version
- flutter pub get
- flutter analyze
- flutter test
- flutter build apk --release
- local APK existence check

The repository's observed GitHub Actions evidence is recorded above. A green local validation result must not be inferred from that evidence.

## Merge conditions
This baseline PR should not be considered a green product release. Its purpose is to establish an evidence-backed CI baseline and record the proven failure path and later green recovery.

No product feature, storage migration, Riverpod migration, Unified Item rewrite, Reminder implementation, Widget implementation, PDF/Reports implementation, or broad UI refactor was performed in this audit.

## Next technical gate
Before any new Reminder implementation, audit PR #116 and the existing Reminder/recurrence/calendar contracts. For CI baseline work, the next focused action is to reproduce/confirm the current mainline workflow state on the audit branch and only then make the smallest CI correction supported by evidence.
