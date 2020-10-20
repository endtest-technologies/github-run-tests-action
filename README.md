![endtest logo](https://endtest.io/images/endtest_logo_small.svg)

# Endtest GitHub Run Tests Deployment Action

This GitHub Action creates an Endtest deployment event, triggering any functional
tests associated with that deployment and waiting for their results.

### Example workflow:

```
on: [push]

name: endtest

jobs:
  test:
    name: Endtest Functional Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master

      - name: Functional test deployment
        id: endtest-test-deployment
        uses: endtest-technologies/github-run-tests-action@v1.2.3
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          app-id: <your-endtest-app-id>
          app-code: <your-endtest-app-code>
          api-request: <your-endtest-api-request-for-starting-a-test-execution>
          number-of-loops: <the-number-of-times-the-API-request-for-fetching-the-results-will-be-sent-once-every-30-seconds>
```

### Environment variables

- `GITHUB_TOKEN` {string} (optional) - The Github token for your repository. If
  provided, the Endtest action will associate a pull request with the deployment if
  the commit being built is associated with any pull requests. This token is
  automatically available as a secret in your repo but must be passed in
  explicitly in order for the action to be able to access it.

### Inputs

- `app-id` {string} - The App ID for your Endtest account ([available here](https://endtest.io/settings)).
- `app-code` {string} - The App Code for your Endtest account ([available here](https://endtest.io/settings)).
- `api-request` {string} - The Endtest API request.
- `number-of-loops` {int32} - The number of times the API request for fetching the results will be sent once every 30 seconds.


### Outputs:

* test_suite_name {string} - The name of the test suite.
* configuration {string} - The configuration of the machine or mobile device on which the test was executed.
* test_cases {int32} - The number of test cases.
* passed {int32} - The number of assertions that have passed.
* failed {int32} - The number of assertions that have failed.
* errors {int32} - The number of errors that have been encountered.
* start_time {timestamp} - The timestamp for the start of the test execution.
* end_time {timestamp} - The timestamp for the end of the test execution.
* detailed_logs {string} - The detailed logs for the test execution.
* screenshots_and_video {string} - The URL for the screenshots and the video recording of the test execution.
