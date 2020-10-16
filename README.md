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
        uses: endtest-technologies/github-run-tests-action@v1.0
        env:
          ENDTEST_APP_ID: ${{ secrets.ENDTEST_APP_ID }}
          ENDTEST_APP_CODE: ${{ secrets.ENDTEST_APP_CODE }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          api-request: <your-endtest-api-request-for-starting-a-test-execution>
```

### Environment variables

- `ENDTEST_APP_ID` {string} - Your Endtest APP ID
  [available here](https://endtest.io/settings) This should
  be installed as a secret in your github repository.
- `ENDTEST_APP_CODE` {string} - Your Endtest APP Code
  [available here](https://endtest.io/settings) This should
  be installed as a secret in your github repository.
- `GITHUB_TOKEN` {string} (optional) - The Github token for your repository. If
  provided, the Endtest action will associate a pull request with the deployment if
  the commit being built is associated with any pull requests. This token is
  automatically available as a secret in your repo but must be passed in
  explicitly in order for the action to be able to access it.

### Inputs

- `api-request` {string} (optional) - The Endtest API request.


### outputs:

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
