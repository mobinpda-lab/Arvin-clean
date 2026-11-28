#!/usr/bin/env bash
set -uo pipefail
E=.github/command-20e-evidence
REPO="$GITHUB_REPOSITORY"
SHA="$TARGET_SHA"
BRANCH=recovery-02/main-based-integration
REPO_ID=1331763954
[[ -n "$REPO" && -n "$SHA" && -n "$GITHUB_RUN_ID" && -n "$GITHUB_RUN_ATTEMPT" ]] || exit 2
mkdir -p "$E"
cd "$GITHUB_WORKSPACE"
source .github/scripts/command-20e-evidence-parser.sh
missing(){ [[ -s "$1" ]] || printf '%s\n' "$2" > "$1"; }
missing "$E/environment_versions.txt" 'Environment version capture NOT TESTED.'
missing "$E/flutter_analyze.log" 'Flutter Analyze NOT TESTED.'
missing "$E/project_store_persistence.log" 'ProjectStore test NOT TESTED.'
missing "$E/calendar_restart_stage_a.log" 'Calendar stage A NOT TESTED.'
missing "$E/calendar_restart_stage_b.log" 'Calendar stage B NOT TESTED.'
missing "$E/calendar_value_comparison.json" '{"status":"NOT TESTED"}'
missing "$E/cleanup_verification.log" 'Cleanup verification NOT TESTED.'
select_run(){ jq -c --arg sha "$SHA" --arg n "$1" '[.workflow_runs[]|select(.head_sha==$sha and (.name|startswith($n)) and .event=="pull_request")]|sort_by(.id)|last // {}' "$RUNNER_TEMP/runs.json"; }
for f in build device followup; do printf '{}' > "$RUNNER_TEMP/$f-run.json"; done
complete=false; discovered=false
for attempt in $(seq 1 690); do
  if ! gh api "repos/$REPO/actions/runs?head_sha=$SHA&per_page=100" > "$RUNNER_TEMP/runs.json"; then
    [[ $attempt -ge 10 ]] && break
    sleep 30; continue
  fi
  select_run 'Arvin Build' > "$RUNNER_TEMP/build-run.json"
  select_run 'Arvin Device Smoke' > "$RUNNER_TEMP/device-run.json"
  select_run 'Arvin Follow-up File Persistence' > "$RUNNER_TEMP/followup-run.json"
  b=$(jq -r '.id // empty' "$RUNNER_TEMP/build-run.json")
  d=$(jq -r '.id // empty' "$RUNNER_TEMP/device-run.json")
  f=$(jq -r '.id // empty' "$RUNNER_TEMP/followup-run.json")
  if [[ -n $b && -n $d && -n $f ]]; then
    discovered=true
    if [[ $(jq -r '.status' "$RUNNER_TEMP/build-run.json") == completed && $(jq -r '.status' "$RUNNER_TEMP/device-run.json") == completed && $(jq -r '.status' "$RUNNER_TEMP/followup-run.json") == completed ]]; then complete=true; break; fi
  elif [[ $attempt -ge 10 ]]; then break; fi
  sleep 30
done
b=$(jq -r '.id // empty' "$RUNNER_TEMP/build-run.json"); d=$(jq -r '.id // empty' "$RUNNER_TEMP/device-run.json"); f=$(jq -r '.id // empty' "$RUNNER_TEMP/followup-run.json")
fetch(){ local id="$1" url="$2" out="$3" status="$4"; if [[ -n $id ]] && gh api "$url" > "$out"; then echo SUCCESS > "$status"; else echo '{"jobs":[],"artifacts":[]}' > "$out"; echo FAILURE > "$status"; fi; }
fetch "$b" "repos/$REPO/actions/runs/$b/jobs?per_page=100" "$E/build-jobs.json" "$E/build-jobs-fetch.txt"
fetch "$d" "repos/$REPO/actions/runs/$d/jobs?per_page=100" "$E/device-jobs.json" "$E/device-jobs-fetch.txt"
fetch "$f" "repos/$REPO/actions/runs/$f/jobs?per_page=100" "$E/followup-jobs.json" "$E/followup-jobs-fetch.txt"
fetch "$b" "repos/$REPO/actions/runs/$b/artifacts?per_page=100" "$E/build-artifacts.json" "$E/build-artifacts-fetch.txt"
fetch "$d" "repos/$REPO/actions/runs/$d/artifacts?per_page=100" "$E/device-artifacts.json" "$E/device-artifacts-fetch.txt"
fetch "$f" "repos/$REPO/actions/runs/$f/artifacts?per_page=100" "$E/followup-artifacts.json" "$E/followup-artifacts-fetch.txt"
fetch "$GITHUB_RUN_ID" "repos/$REPO/actions/runs/$GITHUB_RUN_ID/jobs?per_page=100" "$E/command-20e-jobs.json" "$E/command-20e-jobs-fetch.txt"
fetch "$GITHUB_RUN_ID" "repos/$REPO/actions/runs/$GITHUB_RUN_ID/artifacts?per_page=100" "$E/command-20e-artifacts.json" "$E/command-20e-artifacts-fetch.txt"
if gh api "repos/$REPO" > "$E/repository-metadata.json"; then echo SUCCESS > "$E/repository-fetch.txt"; else echo FAILURE > "$E/repository-fetch.txt"; printf '{"id":null,"full_name":null}' > "$E/repository-metadata.json"; fi
job_record(){
  local file="$1" name="$2" raw rs rc state
  raw=$(jq -c --arg n "$name" '[.jobs[]|select(.name==$n)]|last // empty' "$file")
  if [[ -z $raw ]]; then jq -cn --arg n "$name" '{job_id:null,job_name:$n,raw_status:null,raw_conclusion:null,state:"NOT_RUN",started_at:null,completed_at:null,html_url:null}'; return; fi
  rs=$(jq -r '.status // ""' <<< "$raw"); rc=$(jq -r '.conclusion // ""' <<< "$raw")
  state=$(classify_github_execution_state "$rs" "$rc" true)
  jq -c --arg state "$state" '{job_id:.id,job_name:.name,raw_status:.status,raw_conclusion:.conclusion,state:$state,started_at:.started_at,completed_at:.completed_at,html_url:.html_url}' <<< "$raw"
}
workflow_record(){
  local name="$1" runfile="$2" jobsfile="$3" artfile="$4" raw id rs rc state
  raw=$(cat "$runfile"); id=$(jq -r '.id // empty' <<< "$raw")
  if [[ -z $id ]]; then jq -cn --arg n "$name" '{workflow_name:$n,workflow_run_id:null,run_attempt:null,repository_id:null,repository_full_name:null,head_sha:null,head_branch:null,event:null,raw_status:null,raw_conclusion:null,state:"NOT_RUN",jobs:[],artifacts:[]}'; return; fi
  rs=$(jq -r '.status // ""' <<< "$raw"); rc=$(jq -r '.conclusion // ""' <<< "$raw"); state=$(classify_github_execution_state "$rs" "$rc" true)
  jq -cn --arg n "$name" --arg state "$state" --arg repo "$REPO" --arg sha "$SHA" --arg branch "$BRANCH" --arg collector "$GITHUB_RUN_ID" --arg attempt "$GITHUB_RUN_ATTEMPT" --argjson repo_id "$REPO_ID" --slurpfile r "$runfile" --slurpfile j "$jobsfile" --slurpfile a "$artfile" '
    $r[0] as $x | {workflow_name:$n,workflow_run_id:$x.id,run_attempt:$x.run_attempt,repository_id:$repo_id,repository_full_name:$repo,head_repository_id:($x.head_repository.id // null),head_sha:$x.head_sha,head_branch:$x.head_branch,event:$x.event,raw_status:$x.status,raw_conclusion:$x.conclusion,state:$state,url:$x.html_url,
    jobs:(($j[0].jobs // [])|map({job_id:.id,job_name:.name,raw_status:.status,raw_conclusion:.conclusion,started_at:.started_at,completed_at:.completed_at,html_url:.html_url})),
    artifacts:(($a[0].artifacts // [])|map({artifact_id:.id,name:.name,digest:.digest,size_in_bytes:.size_in_bytes,expired:.expired,created_at:.created_at,expires_at:.expires_at})),
    evidence_provenance:{source:"GitHub Actions REST API",target_sha:$sha,authorized_branch:$branch,collector_run_id:$collector,collector_run_attempt:($attempt|tonumber)}}'
}
build=$(workflow_record build "$RUNNER_TEMP/build-run.json" "$E/build-jobs.json" "$E/build-artifacts.json")
device=$(workflow_record device_smoke "$RUNNER_TEMP/device-run.json" "$E/device-jobs.json" "$E/device-artifacts.json")
follow=$(workflow_record follow_up "$RUNNER_TEMP/followup-run.json" "$E/followup-jobs.json" "$E/followup-artifacts.json")
jq -n --arg sha "$SHA" --arg repo "$REPO" --argjson repo_id "$REPO_ID" --argjson b "$build" --argjson d "$device" --argjson f "$follow" '{repository:{full_name:$repo,repository_id:$repo_id},target_sha:$sha,workflows:{build:$b,device_smoke:$d,follow_up:$f}}' > "$E/external-workflows.json"
fetch_log(){ local id="$1" out="$2" status="$3"; if [[ -n $id ]] && gh run view "$id" --log > "$out" 2>&1; then echo SUCCESS > "$status"; else echo FAILURE > "$status"; fi; }
fetch_log "$b" "$E/build-workflow.log" "$E/build-log-fetch.txt"
fetch_log "$d" "$E/device-workflow.log" "$E/device-log-fetch.txt"
fetch_log "$f" "$E/followup-workflow.log" "$E/followup-log-fetch.txt"
mkdir -p "$E/android-screenshots"
if [[ -n $d ]] && gh run download "$d" --dir "$E/android-screenshots" 2> "$E/device-download.log"; then echo SUCCESS > "$E/device-download-fetch.txt"; else echo FAILURE > "$E/device-download-fetch.txt"; fi
ba=$(job_record "$E/build-jobs.json" 'quality (analyze)')
tr=$(job_record "$E/build-jobs.json" 'trace JSONL evidence')
dbg=$(job_record "$E/build-jobs.json" 'apk (debug)')
rel=$(job_record "$E/build-jobs.json" 'apk (release)')
fu=$(job_record "$E/followup-jobs.json" 'Follow-up file-backed SQLite persistence (no APK build)')
shards='[]'
for i in 0 1 2 3 4 5; do r=$(job_record "$E/build-jobs.json" "quality (test-$i)"); shards=$(jq --argjson i "$i" --argjson r "$r" '. + [($r+{shard:$i})]' <<< "$shards"); done
smokes='[]'
for n in 'device-smoke (home)' 'device-smoke (quick-capture)' 'device-smoke (sql-persistence)' 'device-smoke (sql-migration)' 'device-smoke (backup-restore)' 'device-smoke (people)' 'device-smoke (calendar)'; do r=$(job_record "$E/device-jobs.json" "$n"); smokes=$(jq --argjson r "$r" '. + [$r]' <<< "$smokes"); done
artifact(){ jq -c --arg n "$2" '[.artifacts[]|select(.name==$n)]|last // {}|{artifact_id:(.id//null),artifact_name:(.name//null),artifact_digest:(.digest//null),artifact_expired:(if has("expired") then .expired else null end)}' "$1"; }
trace_art=$(jq -c --arg p "arvin-trace-$SHA-" '[.artifacts[]|select(.name|startswith($p))]|last // {}|{artifact_id:(.id//null),artifact_name:(.name//null),artifact_digest:(.digest//null),artifact_expired:(if has("expired") then .expired else null end)}' "$E/build-artifacts.json")
debug_art=$(artifact "$E/build-artifacts.json" arvin-debug-apk)
release_art=$(artifact "$E/build-artifacts.json" arvin-release-apk)
trace_state=$(jq -r '.state' <<< "$tr")
if [[ $trace_state == SUCCESS && -n $(jq -r '.artifact_id // empty' <<< "$trace_art") && -n $(jq -r '.artifact_digest // empty' <<< "$trace_art") && $(jq -r '.artifact_expired' <<< "$trace_art") == false ]]; then trace_gate=SUCCESS; else [[ $trace_state == SUCCESS ]] && trace_gate=UNKNOWN || trace_gate=$trace_state; fi
analyze=UNKNOWN
if grep -q 'No issues found!' "$E/flutter_analyze.log"; then analyze=SUCCESS; elif grep -qE 'issues found|error •|warning •|info •' "$E/flutter_analyze.log"; then analyze=FAILURE; fi
storage=$(job_record "$E/command-20e-jobs.json" storage-persistence)
analyze_record=$(jq -cn --arg s "$analyze" --argjson j "$storage" --arg run "$GITHUB_RUN_ID" '{job_id:$j.job_id,job_name:"Flutter Analyze (storage-persistence)",raw_status:$j.raw_status,raw_conclusion:$j.raw_conclusion,state:$s,source_workflow_run_id:$run,source_file:"flutter_analyze.log"}')
ps=NOT_STARTED; grep -q 'TEST_STARTED=1' "$E/project_store_persistence.log" && ps=STARTED; grep -Eq 'TEST_STATUS=(PASS|FAILURE)' "$E/project_store_persistence.log" && ps=COMPLETED
pr=$(classify_evidence_file "$E/project_store_persistence.log" "$ps" 'TEST_STARTED=1' 'TEST_STATUS=PASS' 'TEST_STATUS=FAILURE')
case "$pr" in PASS) project=PASS;; FAILURE) project=FAILURE;; 'NOT TESTED') project=NOT_TESTED;; *) project=INCOMPLETE_EVIDENCE;; esac
cr=$(classify_calendar_restart_evidence "$E/calendar_restart_stage_a.log" "$E/calendar_restart_stage_b.log" "$E/cleanup_verification.log" "$E/calendar_value_comparison.json")
case "$cr" in PASS) calendar=PASS;; FAILURE) calendar=FAILURE;; 'NOT TESTED') calendar=NOT_TESTED;; *) calendar=INCOMPLETE_EVIDENCE;; esac
cs=NOT_STARTED; grep -q 'CLEANUP_TEST_STARTED=1' "$E/cleanup_verification.log" && cs=STARTED; grep -Eq 'TEST_STATUS=(PASS|FAILURE)' "$E/cleanup_verification.log" && cs=COMPLETED
clr=$(classify_evidence_file "$E/cleanup_verification.log" "$cs" 'CLEANUP_TEST_STARTED=1' 'CALENDAR_TEST_KEY_CLEANUP=PASS' 'TEST_STATUS=FAILURE')
case "$clr" in PASS) cleanup=PASS;; FAILURE) cleanup=FAILURE;; 'NOT TESTED') cleanup=NOT_TESTED;; *) cleanup=INCOMPLETE_EVIDENCE;; esac
phase_art=$(jq -c '[.artifacts[]|select(.name|startswith("arvin-command-20e-phase-"))]|last // {}|{artifact_id:(.id//null),artifact_name:(.name//null),artifact_digest:(.digest//null),artifact_expired:(if has("expired") then .expired else null end)}' "$E/command-20e-artifacts.json")
repo_ok=false; [[ $(jq -r '.id // empty' "$E/repository-metadata.json") == "$REPO_ID" && $(jq -r '.full_name // empty' "$E/repository-metadata.json") == "$REPO" ]] && repo_ok=true
phase_ok=false; [[ -n $(jq -r '.artifact_id // empty' <<< "$phase_art") && -n $(jq -r '.artifact_digest // empty' <<< "$phase_art") && $(jq -r '.artifact_expired' <<< "$phase_art") == false ]] && phase_ok=true
collection=INCOMPLETE
if [[ $complete == true && $discovered == true && $repo_ok == true && $phase_ok == true ]] && ! grep -q FAILURE "$E"/*-fetch.txt 2>/dev/null; then collection=COMPLETED; fi
if [[ $collection != COMPLETED ]]; then
  { echo "EXTERNAL_RUNS_NOT_COMPLETE=$([[ $complete == true ]] && echo 0 || echo 1)"; echo "ALL_RUNS_DISCOVERED=$discovered"; for x in build device followup; do key=$(printf '%s' "$x" | tr '[:lower:]' '[:upper:]'); printf '%s_RAW_STATUS=%s\n' "$key" "$(jq -r '.status // "MISSING"' "$RUNNER_TEMP/$x-run.json")"; printf '%s_RAW_CONCLUSION=%s\n' "$key" "$(jq -r '.conclusion // "MISSING"' "$RUNNER_TEMP/$x-run.json")"; done; echo "EVIDENCE_COLLECTION_STATUS=$collection"; } > "$E/external-workflow-wait.txt"
fi
collector_jobs=$(jq -c '[.jobs[]|select(.name=="storage-persistence" or .name=="complete-evidence")|{job_id:.id,job_name:.name,raw_status:.status,raw_conclusion:.conclusion}]' "$E/command-20e-jobs.json")
jq -n --arg sha "$SHA" --arg repo "$REPO" --arg branch "$BRANCH" --arg collection "$collection" --arg run "$GITHUB_RUN_ID" --arg attempt "$GITHUB_RUN_ATTEMPT" --arg repo_ok "$repo_ok" --arg phase_ok "$phase_ok" --argjson repo_id "$REPO_ID" --argjson phase "$phase_art" --argjson cj "$collector_jobs" --argjson b "$build" --argjson d "$device" --argjson f "$follow" '{repository:{full_name:$repo,repository_id:$repo_id},target_sha:$sha,authorized_branch:$branch,evidence_collection:{status:$collection,repository_identity_valid:($repo_ok=="true"),phase_artifact_valid:($phase_ok=="true"),phase_artifact:$phase,collector_workflow_run_id:$run,collector_run_attempt:($attempt|tonumber),collector_jobs:$cj,source:"GitHub Actions REST API and downloaded logs/artifacts"},workflow_completion:{build:$b,device_smoke:$d,follow_up:$f}}' > "$E/regression-input.json"
jq -n --argjson tr "$tr" --arg trace_state "$trace_gate" --argjson trace_art "$trace_art" --argjson analyze "$analyze_record" --argjson ba "$ba" --argjson dbg "$dbg" --argjson dbg_art "$debug_art" --argjson rel "$rel" --argjson rel_art "$release_art" --argjson shards "$shards" --argjson fu "$fu" --argjson smokes "$smokes" --arg project "$project" --arg calendar "$calendar" --arg cleanup "$cleanup" --argjson storage "$storage" --arg run "$GITHUB_RUN_ID" '{trace_aggregation:($tr+{state:$trace_state}+$trace_art),flutter_analyze:{dedicated:$analyze,build:$ba},test_shards:$shards,apk_debug:($dbg+$dbg_art),apk_release:($rel+$rel_art),project_store_file_persistence:{state:$project,source_file:"project_store_persistence.log",source_workflow_run_id:$run,source_job_id:$storage.job_id},calendar_process_restart:{state:$calendar,source_files:["calendar_restart_stage_a.log","calendar_restart_stage_b.log","calendar_value_comparison.json"],source_workflow_run_id:$run,source_job_id:$storage.job_id},cleanup:{state:$cleanup,source_file:"cleanup_verification.log",source_workflow_run_id:$run,source_job_id:$storage.job_id},follow_up_persistence:$fu,device_smoke:$smokes}' > "$E/regression-gates.json"
jq -s '.[0]+{gates:.[1]}' "$E/regression-input.json" "$E/regression-gates.json" > "$E/regression-summary-input.json"
write_command20e_regression_summary "$E/regression-summary-input.json" "$E/regression_summary.json" "$SHA"
overall=$(jq -r '.overall' "$E/regression_summary.json")
jq '.gates.test_shards' "$E/regression_summary.json" > "$E/test_shards_summary.json"
jq '.workflow_completion' "$E/regression_summary.json" > "$E/workflow-completion.json"
{
 echo '# COMMAND 20-E Evidence Summary'; echo; echo "- Repository: $REPO ($REPO_ID)"; echo "- Branch: $BRANCH"; echo "- SHA: $SHA"; echo "- Run / Attempt: $GITHUB_RUN_ID / $GITHUB_RUN_ATTEMPT"; echo "- Evidence collection: $collection"; echo "- Overall: $overall"; echo "- Build: $(jq -r '.workflow_completion.build.workflow_run_id // "NOT_RUN"' "$E/regression_summary.json") / $(jq -r '.workflow_completion.build.state' "$E/regression_summary.json")"; echo "- Device: $(jq -r '.workflow_completion.device_smoke.workflow_run_id // "NOT_RUN"' "$E/regression_summary.json") / $(jq -r '.workflow_completion.device_smoke.state' "$E/regression_summary.json")"; echo "- Follow-up: $(jq -r '.workflow_completion.follow_up.workflow_run_id // "NOT_RUN"' "$E/regression_summary.json") / $(jq -r '.workflow_completion.follow_up.state' "$E/regression_summary.json")"; echo "- Shards: $(jq -r '[.gates.test_shards[]|(.shard|tostring)+":"+.state]|join(", ")' "$E/regression_summary.json")"; echo "- Trace artifact: $(jq -r '.gates.trace_aggregation.artifact_id // "MISSING"' "$E/regression_summary.json")"; echo "- Debug / Release artifacts: $(jq -r '.gates.apk_debug.artifact_id // "MISSING"' "$E/regression_summary.json") / $(jq -r '.gates.apk_release.artifact_id // "MISSING"' "$E/regression_summary.json")"; echo "- ProjectStore / Calendar / Cleanup: $project / $calendar / $cleanup";
} > "$E/workflow_summary.md"
echo "EVIDENCE_COLLECTION_STATUS=$collection"
echo "COMMAND_20E_OVERALL=$overall"
[[ $overall == PASS ]]
