#!/usr/bin/env bash
# Shared explicit-state parser for COMMAND 20-E evidence.
# Usage: classify_evidence_file FILE EXECUTION_STATE START_MARKER PASS_MARKER FAILURE_MARKER
classify_evidence_file() {
  local file="$1" execution_state="$2" start_marker="$3" pass_marker="$4" failure_marker="$5"
  local has_start=false has_pass=false has_failure=false has_not_tested=false
  if [[ -f "$file" && -s "$file" ]]; then
    if [[ -n "$start_marker" ]] && grep -Fq "$start_marker" "$file"; then has_start=true; fi
    if [[ -n "$pass_marker" ]] && grep -Fq "$pass_marker" "$file"; then has_pass=true; fi
    if [[ -n "$failure_marker" ]] && grep -Fq "$failure_marker" "$file"; then has_failure=true; fi
    if grep -Fq 'TEST_STATUS=FAILURE' "$file"; then has_failure=true; fi
    if grep -Fxq 'TEST_STATUS=NOT TESTED' "$file" ||
       grep -Fxq 'Cleanup verification NOT TESTED.' "$file" ||
       grep -Fxq 'Calendar stage A NOT TESTED.' "$file" ||
       grep -Fxq 'Calendar stage B NOT TESTED.' "$file"; then
      has_not_tested=true
    fi
    if [[ "$has_not_tested" == true ]]; then printf 'NOT TESTED'; return; fi
    if [[ "$has_pass" == true && "$has_failure" == true ]]; then printf 'INCOMPLETE EVIDENCE'; return; fi
    if [[ "$has_failure" == true ]]; then
      if grep -Fq 'TEST_STATUS=FAILURE' "$file" &&
         grep -Eq '^FAILURE_REASON=.+$|^TEST_FAILURE=.+$|^FAILURE_EVIDENCE=.+$' "$file"; then
        printf 'FAILURE'
      else
        printf 'INCOMPLETE EVIDENCE'
      fi
      return
    fi
    if [[ "$has_pass" == true && "$execution_state" == COMPLETED ]]; then printf 'PASS'; return; fi
    if [[ "$has_start" == true || "$execution_state" == STARTED || "$execution_state" == COMPLETED ]]; then
      printf 'INCOMPLETE EVIDENCE'; return
    fi
    printf 'NOT TESTED'; return
  fi
  if [[ "$execution_state" == NOT_STARTED ]]; then printf 'NOT TESTED'; else printf 'INCOMPLETE EVIDENCE'; fi
}
