![endtest logo](https://endtest.io/images/endtest_logo_1_small.png)

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

- `name` {string} - The name of the test suite.
- `hash` {string} -	The unique hash for the test execution, the same one that it returned by the Endtest API call for running a test.	
- `configuration` {string} - The configuration of the machine or mobile device on which the test was executed.
- `passed` {int32} - The number of assertions that have passed.
- `failed` {int32} -	The number of assertions that have failed.
- `errors` {int32} -	The number of errors that have been encountered.
- `logs` {string} -	The detailed logs for the test execution.
- `video_url` {string}	- The URL for the video recording of the test execution.
- `variables`	{string} - All of the variables from the test execution, both system variables and the variables defined by the user.
- `source`	{string} - It will always have the value 'endtest'. You can use it in your script to identify the requests coming from our platform.
