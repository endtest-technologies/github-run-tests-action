#!/usr/bin/env bash
set -euo pipefail

APP_ID="${1:-}"
APP_CODE="${2:-}"
API_REQUEST="${3:-}"
NUMBER_OF_LOOPS="${4:-}"
RESULTS_FORMAT="${5:-json}"
POLL_INTERVAL_SECONDS="${ENDTEST_POLL_INTERVAL_SECONDS:-30}"

if [[ -z "$APP_ID" || -z "$APP_CODE" || -z "$API_REQUEST" || -z "$NUMBER_OF_LOOPS" ]]; then
  echo "Missing required arguments: app_id, app_code, api_request, and number_of_loops." >&2
  exit 1
fi

if ! [[ "$NUMBER_OF_LOOPS" =~ ^[1-9][0-9]*$ ]]; then
  echo "number_of_loops must be a positive integer." >&2
  exit 1
fi

if [[ "$RESULTS_FORMAT" != "json" && "$RESULTS_FORMAT" != "json-light" ]]; then
  echo "results_format must be either json or json-light." >&2
  exit 1
fi

if ! [[ "$POLL_INTERVAL_SECONDS" =~ ^[0-9]+$ ]]; then
  echo "ENDTEST_POLL_INTERVAL_SECONDS must be a non-negative integer." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but was not found on the runner." >&2
  exit 1
fi

write_output() {
  local name="$1"
  local value="$2"

  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    local delimiter="ENDTEST_${name}_$$_${RANDOM}"
    {
      printf '%s<<%s\n' "$name" "$delimiter"
      printf '%s\n' "$value"
      printf '%s\n' "$delimiter"
    } >> "$GITHUB_OUTPUT"
  else
    printf '%s=%s\n' "$name" "$value"
  fi
}

trigger_response=$(curl --silent --show-error --fail --request GET --header "Accept: */*" "$API_REQUEST")
hash=$(printf '%s' "$trigger_response" | tr -d '\r\n' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

if [[ -z "$hash" ]]; then
  echo "Endtest did not return an execution hash." >&2
  exit 1
fi

if ! [[ "$hash" =~ ^[A-Za-z0-9_-]+(,[A-Za-z0-9_-]+)*$ ]]; then
  echo "Endtest returned an unexpected execution hash response: $hash" >&2
  exit 1
fi

hashes_json=$(printf '%s' "$hash" | jq -R -c 'split(",")')
hash_count=$(printf '%s' "$hashes_json" | jq 'length')

echo "Triggered $hash_count Endtest test execution(s)."

last_status=""
normalized_results=""

for ((loop = 1; loop <= NUMBER_OF_LOOPS; loop++)); do
  sleep "$POLL_INTERVAL_SECONDS"

  result=$(curl --silent --show-error --fail --get "https://app.endtest.io/api.php" \
    --data-urlencode "action=getResults" \
    --data-urlencode "appId=$APP_ID" \
    --data-urlencode "appCode=$APP_CODE" \
    --data-urlencode "hash=$hash" \
    --data-urlencode "format=$RESULTS_FORMAT")

  case "$result" in
    "Test is still running."|"Processing video recording."|"Stopping."|"")
      last_status="$result"
      continue
      ;;
    "Erred.")
      echo "Endtest reported that the test execution erred." >&2
      exit 1
      ;;
  esac

  if ! normalized_results=$(printf '%s' "$result" | jq -c '
    if type == "array" then .
    elif type == "object" then [.]
    else error("Expected an Endtest result object or array")
    end
  ' 2>/dev/null); then
    echo "Endtest returned an unexpected results response: $result" >&2
    exit 1
  fi

  execution_count=$(printf '%s' "$normalized_results" | jq 'length')

  if [[ "$execution_count" -lt "$hash_count" ]]; then
    last_status="Received $execution_count of $hash_count execution results."
    continue
  fi

  test_suite_name=$(printf '%s' "$normalized_results" | jq -r '
    if length == 1 then .[0].test_suite_name // ""
    else map(.test_suite_name // "") | @json
    end
  ')
  configuration=$(printf '%s' "$normalized_results" | jq -r '
    if length == 1 then .[0].configuration // ""
    else map(.configuration // "") | @json
    end
  ')
  test_cases=$(printf '%s' "$normalized_results" | jq '[.[] | (.test_cases // 0 | tonumber? // 0)] | add // 0')
  passed=$(printf '%s' "$normalized_results" | jq '[.[] | (.passed // 0 | tonumber? // 0)] | add // 0')
  failed=$(printf '%s' "$normalized_results" | jq '[.[] | (.failed // 0 | tonumber? // 0)] | add // 0')
  errors=$(printf '%s' "$normalized_results" | jq '[.[] | (.errors // 0 | tonumber? // 0)] | add // 0')
  detailed_logs=$(printf '%s' "$normalized_results" | jq -c '[.[] | (.detailed_logs // [])[]?]')
  screenshots_and_video=$(printf '%s' "$normalized_results" | jq -c '[.[] | (.screenshots_and_video // [])[]?]')
  start_time=$(printf '%s' "$normalized_results" | jq -r '[.[] | .start_time // empty] | min // ""')
  end_time=$(printf '%s' "$normalized_results" | jq -r '[.[] | .end_time // empty] | max // ""')
  result_urls=$(printf '%s' "$hashes_json" | jq -c 'map("https://app.endtest.io/results?hash=" + .)')

  if [[ "$execution_count" -eq 1 ]]; then
    results=$(printf '%s' "$result_urls" | jq -r '.[0]')
  else
    results="$result_urls"
  fi

  echo "Endtest executions: $execution_count"
  echo "Test Suite Name(s): $test_suite_name"
  echo "Configuration(s): $configuration"
  echo "Test Cases: $test_cases"
  echo "Passed: $passed"
  echo "Failed: $failed"
  echo "Errors: $errors"
  echo "Start Time: $start_time"
  echo "End Time: $end_time"
  echo "Hash(es): $hash"
  echo "Results: $results"

  write_output "test_suite_name" "$test_suite_name"
  write_output "configuration" "$configuration"
  write_output "test_cases" "$test_cases"
  write_output "passed" "$passed"
  write_output "failed" "$failed"
  write_output "errors" "$errors"
  write_output "start_time" "$start_time"
  write_output "end_time" "$end_time"
  write_output "detailed_logs" "$detailed_logs"
  write_output "screenshots_and_video" "$screenshots_and_video"
  write_output "hash" "$hash"
  write_output "results" "$results"
  write_output "execution_count" "$execution_count"
  write_output "hashes" "$hashes_json"
  write_output "result_urls" "$result_urls"
  write_output "test_executions" "$normalized_results"
  exit 0
done

if [[ -n "$last_status" ]]; then
  echo "Timed out while waiting for Endtest results. Last status: $last_status" >&2
else
  echo "Timed out while waiting for Endtest results." >&2
fi
exit 1
