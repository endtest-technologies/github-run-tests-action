![Endtest logo](https://app.endtest.io/images/endtest_logo_small.svg)

# Endtest GitHub Run Tests Action

This GitHub Action triggers one or more Endtest test executions, waits for all of them to finish, and exposes their results as workflow outputs.

It supports both API response shapes:

* A single execution hash, usually returned when the request uses `suite`.
* Multiple comma-separated execution hashes, usually returned when the request uses `label` and matches multiple test suites.

## Example workflow

```yaml
on: [push]

name: Endtest

jobs:
  test:
    name: Endtest functional tests
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Run tests with the Critical label
        id: endtest
        uses: endtest-technologies/github-run-tests-action@v1.9
        with:
          app_id: ${{ secrets.ENDTEST_APP_ID }}
          app_code: ${{ secrets.ENDTEST_APP_CODE }}
          api_request: >-
            https://app.endtest.io/api.php?action=runWeb&appId=${{ secrets.ENDTEST_APP_ID }}&appCode=${{ secrets.ENDTEST_APP_CODE }}&label=Critical&platform=windows&os=windows11&browser=chrome&browserVersion=latest&resolution=1280x1024&geolocation=sanfrancisco&cases=all&notes=
          number_of_loops: 60
          results_format: json-light

      - name: Show the execution summary
        env:
          EXECUTION_COUNT: ${{ steps.endtest.outputs.execution_count }}
          TEST_CASES: ${{ steps.endtest.outputs.test_cases }}
          PASSED: ${{ steps.endtest.outputs.passed }}
          FAILED: ${{ steps.endtest.outputs.failed }}
          ERRORS: ${{ steps.endtest.outputs.errors }}
          TEST_EXECUTIONS: ${{ steps.endtest.outputs.test_executions }}
        run: |
          echo "Executions: $EXECUTION_COUNT"
          echo "Test cases: $TEST_CASES"
          echo "Passed assertions: $PASSED"
          echo "Failed assertions: $FAILED"
          echo "Errors: $ERRORS"
          echo "$TEST_EXECUTIONS" | jq
```

## Inputs

* `app_id` {string}, required: The App ID for your Endtest account, available on the [Endtest Settings page](https://app.endtest.io/settings).
* `app_code` {string}, required: The App Code for your Endtest account, available on the [Endtest Settings page](https://app.endtest.io/settings).
* `api_request` {string}, required: The complete Endtest API request that starts the test execution or executions.
* `number_of_loops` {integer}, required: The maximum number of result checks. The action waits 30 seconds before each check.
* `results_format` {string}, optional: `json` for detailed logs and media URLs, or `json-light` for a smaller summary response. The default is `json`.

## Multiple execution behavior

When Endtest returns multiple hashes, the action sends all hashes in one `getResults` request and waits until the API returns a result for every hash.

The existing outputs remain convenient for single executions and behave as follows for multiple executions:

* `test_suite_name` and `configuration` become JSON arrays.
* `test_cases`, `passed`, `failed`, and `errors` are totals across all executions.
* `start_time` is the earliest start time and `end_time` is the latest end time.
* `detailed_logs` and `screenshots_and_video` are flattened JSON arrays.
* `results` becomes a JSON array of individual Endtest Results page URLs.

Use `test_executions` when you need the complete per-execution data without aggregation.

## Outputs

* `test_suite_name` {string}: One test suite name, or a JSON array of names.
* `configuration` {string}: One configuration, or a JSON array of configurations.
* `test_cases` {integer}: Total test cases across all executions.
* `passed` {integer}: Total passed assertions across all executions.
* `failed` {integer}: Total failed assertions across all executions.
* `errors` {integer}: Total errors across all executions.
* `start_time` {timestamp}: Earliest execution start time.
* `end_time` {timestamp}: Latest execution end time.
* `detailed_logs` {JSON string}: Flattened detailed logs. This is an empty array with `json-light`.
* `screenshots_and_video` {JSON string}: Flattened screenshot, log, and video URLs. This is an empty array with `json-light`.
* `hash` {string}: The original hash response, including comma-separated hashes.
* `results` {string}: One Results page URL, or a JSON array of URLs.
* `execution_count` {integer}: Number of completed executions.
* `hashes` {JSON string}: Array of execution hashes.
* `result_urls` {JSON string}: Array of Results page URLs.
* `test_executions` {JSON string}: Complete API response normalized to an array.

## Error handling

The action fails with a clear message when:

* The trigger request does not return a valid hash or comma-separated hash list.
* Endtest returns `Erred.`.
* The results response is not valid JSON.
* Not all execution results are available before `number_of_loops` is exhausted.
