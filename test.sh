#!/bin/bash
set -e
hash=$(curl -X GET --header "Accept: */*" "${3}")
for run in {1.."${4}"}
do
  sleep 30
  result=$(curl -X GET --header "Accept: */*" "https://endtest.io/api.php?action=getResults&appId=${1}&appCode=${2}&hash=${hash}&format=json")
  if [ "$result" == "Test is still running." ]
  then
    status=$result
    # Don't print anything
  elif [ "$result" == "Processing video recording." ]
  then
    status=$result
    # Don't print anything
  elif [ "$result" == "Stopping." ]
  then
    status=$result
  elif [ "$result" == "Erred." ]
  then
    status=$result
    echo $status
  elif [ "$result" == "" ]
  then
    status=$result
    # Don't print anything
  else
     testsuitename=$( echo $result | jq '.test_suite_name' )
     configuration=$( echo "$result" | jq '.configuration' )
     testcases=$( echo "$result" | jq '.test_cases' )
     passed=$( echo "$result" | jq '.passed' )
     failed=$( echo "$result" | jq '.failed' )
     errors=$( echo "$result" | jq '.errors' )
     #detailedlogs=$( echo "$result" | jq '.detailed_logs' )
     #screenshotsandvideo=$( echo "$result" | jq '.screenshots_and_video' )
     starttime=$( echo "$result" | jq '.start_time' )
     endtime=$( echo "$result" | jq '.end_time' ) 
     
     results=https://endtest.io/results?hash="$hash"
     
     echo Test Suite Name: $testsuitename
     echo Configuration: $configuration
     echo Test Cases: $testcases
     echo Passed: $passed
     echo Failed: $failed
     echo Errors: $errors
     echo Start Time: $starttime
     echo End Time: $endtime
     echo Hash: $hash
     echo Results: $results
     
     echo ::set-output name=test_suite_name::$( echo "$testsuitename" )
     echo ::set-output name=configuration::$( echo "$configuration" )
     echo ::set-output name=test_cases::$( echo "$testcases" )
     echo ::set-output name=passed::$( echo "$passed" )
     echo ::set-output name=failed::$( echo "$failed" )
     echo ::set-output name=errors::$( echo "$errors" )
     echo ::set-output name=start_time::$( echo "$starttime" )
     echo ::set-output name=end_time::$( echo "$endtime" )
     echo ::set-output name=detailed_logs::$( echo "$detailedlogs" )
     echo ::set-output name=screenshots_and_video::$( echo "$screenshotsandvideo" )
     echo ::set-output name=hash::$( echo "$hash" )
     echo ::set-output name=results::$( echo "$results" )
     exit 0
  fi
done
exit
