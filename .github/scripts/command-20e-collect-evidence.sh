#!/usr/bin/env bash
set -uo pipefail
EVIDENCE=.github/command-20e-evidence
REPO="$GITHUB_REPOSITORY"
mkdir -p "$EVIDENCE"
cd "$GITHUB_WORKSPACE"
printf '%s\n' "$TARGET_SHA" > "$EVIDENCE/commit_sha.txt"
write_missing() {
  path="$1"; message="$2"
  if [[ ! -s "$path" ]]; then printf '%s\n' "$message" > "$path"; fi
}
write_missing "$EVIDENCE/environment_versions.txt" "Environment version capture NOT TESTED."
write_missing "$EVIDENCE/flutter_analyze.log" "Flutter Analyze NOT TESTED."
write_missing "$EVIDENCE/project_store_persistence.log" "ProjectStore test NOT TESTED."
write_missing "$EVIDENCE/calendar_restart_stage_a.log" "Calendar stage A NOT TESTED."
write_missing "$EVIDENCE/calendar_restart_stage_b.log" "Calendar stage B NOT TESTED."
write_missing "$EVIDENCE/calendar_value_comparison.json" '{"status":"NOT TESTED","reason":"Calendar comparison artifact missing"}'
write_missing "$EVIDENCE/cleanup_verification.log" "Cleanup verification NOT TESTED."
RUNS_JSON="$RUNNER_TEMP/command-20e-runs.json"
printf '{}' > "$RUNNER_TEMP/build-run.json"
printf '{}' > "$RUNNER_TEMP/device-run.json"
printf '{}' > "$RUNNER_TEMP/followup-run.json"
select_run() {
  jq -c --arg sha "$TARGET_SHA" --arg name "$1" '[.workflow_runs[] | select(.head_sha == $sha and (.name | startswith($name)) and .event == "pull_request")] | sort_by(.id) | last // {}' "$RUNS_JSON"
}
complete=false
for attempt in $(seq 1 90); do
  if ! gh api "repos/$REPO/actions/runs?head_sha=$TARGET_SHA&per_page=100" > "$RUNS_JSON"; then sleep 20; continue; fi
  build="$(select_run "Arvin Build")"
  device="$(select_run "Arvin Device Smoke")"
  followup="$(select_run "Arvin Follow-up File Persistence")"
  printf '%s\n' "$build" > "$RUNNER_TEMP/build-run.json"
  printf '%s\n' "$device" > "$RUNNER_TEMP/device-run.json"
  printf '%s\n' "$followup" > "$RUNNER_TEMP/followup-run.json"
  build_id="$(jq -r '.id // empty' <<< "$build")"
  device_id="$(jq -r '.id // empty' <<< "$device")"
  followup_id="$(jq -r '.id // empty' <<< "$followup")"
  if [[ -n "$build_id" && -n "$device_id" && -n "$followup_id" ]] &&
     [[ "$(jq -r '.status' <<< "$build")" == completed ]] &&
     [[ "$(jq -r '.status' <<< "$device")" == completed ]] &&
     [[ "$(jq -r '.status' <<< "$followup")" == completed ]]; then complete=true; break; fi
  sleep 30
done
if [[ "$complete" != true ]]; then echo EXTERNAL_RUNS_NOT_COMPLETE=1 > "$EVIDENCE/external-workflow-wait.txt"; fi
build_id="$(jq -r '.id // empty' "$RUNNER_TEMP/build-run.json")"
device_id="$(jq -r '.id // empty' "$RUNNER_TEMP/device-run.json")"
followup_id="$(jq -r '.id // empty' "$RUNNER_TEMP/followup-run.json")"
fetch_jobs() {
  run_id="$1"; output="$2"
  if [[ -n "$run_id" ]]; then gh api "repos/$REPO/actions/runs/$run_id/jobs?per_page=100" > "$output" 2>/dev/null || echo '{"jobs":[]}' > "$output"
  else echo '{"jobs":[]}' > "$output"; fi
}
fetch_jobs "$build_id" "$EVIDENCE/build-jobs.json"
fetch_jobs "$device_id" "$EVIDENCE/device-smoke-jobs.json"
fetch_jobs "$followup_id" "$EVIDENCE/follow-up-jobs.json"
job_status() { jq -r --arg name "$2" '[.jobs[] | select(.name == $name) | .conclusion] | last // "NOT TESTED"' "$1"; }
build_analyze="$(job_status "$EVIDENCE/build-jobs.json" "quality (analyze)")"
shards='[]'
for index in 0 1 2 3 4 5; do
  status="$(job_status "$EVIDENCE/build-jobs.json" "quality (test-$index)")"
  shards="$(jq --argjson i "$index" --arg s "$status" '. + [{shard:$i,conclusion:$s}]' <<< "$shards")"
done
apk_debug="$(job_status "$EVIDENCE/build-jobs.json" "apk (debug)")"
apk_release="$(job_status "$EVIDENCE/build-jobs.json" "apk (release)")"
followup_status="$(job_status "$EVIDENCE/follow-up-jobs.json" "Follow-up file-backed SQLite persistence (no APK build)")"
smokes='[]'
for name in "device-smoke (home)" "device-smoke (quick-capture)" "device-smoke (sql-persistence)" "device-smoke (sql-migration)" "device-smoke (backup-restore)" "device-smoke (people)" "device-smoke (calendar)"; do
  status="$(job_status "$EVIDENCE/device-smoke-jobs.json" "$name")"
  smokes="$(jq --arg n "$name" --arg s "$status" '. + [{job:$n,conclusion:$s}]' <<< "$smokes")"
done
printf '%s\n' "$shards" > "$EVIDENCE/test_shards_summary.json"
if [[ -n "$build_id" ]]; then gh run view "$build_id" --log > "$EVIDENCE/build-workflow.log" 2>&1 || true; fi
if [[ -n "$device_id" ]]; then
  gh run view "$device_id" --log > "$EVIDENCE/device-smoke-workflow.log" 2>&1 || true
  mkdir -p "$EVIDENCE/android-screenshots"
  gh run download "$device_id" --dir "$EVIDENCE/android-screenshots" 2>/dev/null || true
fi
if [[ -n "$followup_id" ]]; then gh run view "$followup_id" --log > "$EVIDENCE/follow-up-workflow.log" 2>&1 || true; fi
jq -n --arg sha "$TARGET_SHA" \
  --argjson build "$(cat "$RUNNER_TEMP/build-run.json")" \
  --argjson device "$(cat "$RUNNER_TEMP/device-run.json")" \
  --argjson followup "$(cat "$RUNNER_TEMP/followup-run.json")" \
  '{target_sha:$sha,workflows:{build:{id:$build.id,head_sha:$build.head_sha,status:$build.status,conclusion:$build.conclusion,url:$build.html_url},device_smoke:{id:$device.id,head_sha:$device.head_sha,status:$device.status,conclusion:$device.conclusion,url:$device.html_url},follow_up:{id:$followup.id,head_sha:$followup.head_sha,status:$followup.status,conclusion:$followup.conclusion,url:$followup.html_url}}}' \
  > "$EVIDENCE/external-workflows.json"
analyze=NOT_TESTED
if grep -q 'No issues found!' "$EVIDENCE/flutter_analyze.log"; then analyze=success
elif grep -q -E 'issues found|error •|warning •|info •' "$EVIDENCE/flutter_analyze.log"; then analyze=failure; fi
project=NOT_TESTED
if grep -q 'PROJECT_STORE_FILE_PERSISTENCE=PASS' "$EVIDENCE/project_store_persistence.log"; then project=success
elif [[ -s "$EVIDENCE/project_store_persistence.log" ]]; then project=failure; fi
calendar=NOT_TESTED
if grep -q 'CALENDAR_LINK_PROCESS_RESTART=PASS' "$EVIDENCE/calendar_restart_stage_b.log" && jq -e '.status == "PASS" and .total_values_compared == 8' "$EVIDENCE/calendar_value_comparison.json" >/dev/null 2>&1; then calendar=success
elif grep -q 'CALENDAR_STAGE_A_BEGIN' "$EVIDENCE/calendar_restart_stage_a.log"; then calendar=failure; fi
cleanup_status=NOT_TESTED
if grep -q 'CALENDAR_TEST_KEY_CLEANUP=PASS' "$EVIDENCE/cleanup_verification.log" && grep -q 'FINAL_APP_PROCESS_STOP=PASS' "$EVIDENCE/cleanup_verification.log" && grep -q 'APP_DATA_CLEAR=NOT_PERFORMED' "$EVIDENCE/cleanup_verification.log"; then cleanup_status=success
elif [[ -s "$EVIDENCE/cleanup_verification.log" ]]; then cleanup_status=failure; fi
gates="$(jq -n --arg analyze "$analyze" --arg build_analyze "$build_analyze" --arg debug "$apk_debug" --arg release "$apk_release" --arg followup "$followup_status" --arg project "$project" --arg calendar "$calendar" --arg cleanup "$cleanup_status" --argjson shards "$shards" --argjson smokes "$smokes" '{target_sha:env.TARGET_SHA,gates:{flutter_analyze:{dedicated:$analyze,build:$build_analyze},test_shards:$shards,apk_debug:$debug,apk_release:$release,project_store_file_persistence:$project,calendar_process_restart:$calendar,cleanup:$cleanup,follow_up_persistence:$followup,device_smoke:$smokes}}')"
overall=PASS
jq -e '(.gates.flutter_analyze.dedicated=="success") and (.gates.flutter_analyze.build=="success") and ([.gates.test_shards[].conclusion]|all(.=="success")) and (.gates.apk_debug=="success") and (.gates.apk_release=="success") and (.gates.project_store_file_persistence=="success") and (.gates.calendar_process_restart=="success") and (.gates.cleanup=="success") and (.gates.follow_up_persistence=="success") and ([.gates.device_smoke[].conclusion]|all(.=="success"))' <<< "$gates" >/dev/null 2>&1 || overall=NO-GO
jq --arg overall "$overall" '. + {overall:$overall}' <<< "$gates" > "$EVIDENCE/regression_summary.json"
{
  echo "# COMMAND 20-E Evidence Summary"
  echo
  echo "- Exact SHA: $TARGET_SHA"
  echo "- Overall: $overall"
  echo "- Flutter Analyze: $analyze / Build Analyze: $build_analyze"
  echo "- Test shards: $(jq -r '[.[].conclusion] | join(", ")' "$EVIDENCE/test_shards_summary.json")"
  echo "- APK Debug / Release: $apk_debug / $apk_release"
  echo "- ProjectStore: $project"
  echo "- Calendar Restart: $calendar"
  echo "- Cleanup: $cleanup_status"
  echo "- Follow-up: $followup_status"
  echo "- Device Smoke jobs: $(jq -r '[.[].conclusion] | join(", ")' <<< "$smokes")"
} > "$EVIDENCE/workflow_summary.md"
echo "EVIDENCE_COLLECTION_COMPLETE=$overall"
exit 0
