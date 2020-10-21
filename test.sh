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
     testsuitename=$( echo "$result" | jq '.test_suite_name' )
     configuration=$( echo "$result" | jq '.configuration' )
     testcases=$( echo "$result" | jq '.test_cases' )
     passed=$( echo "$result" | jq '.passed' )
     failed=$( echo "$result" | jq '.failed' )
     errors=$( echo "$result" | jq '.errors' )
     #detailedlogs=$( echo "$result" | jq '.detailed_logs' )
     #screenshotsandvideo=$( echo "$result" | jq '.screenshots_and_video' )
     starttime=$( echo "$result" | jq '.start_time' )
     endtime=$( echo "$result" | jq '.end_time' )   
     
     echo $testsuitename
     echo $configuration
     echo $testcases
     echo $passed
     echo $failed
     echo $errors
     echo $starttime
     echo $endtime
     

     echo ::set-output name=test_suite_name::$( echo "$testsuitename" )
     echo "::set-output name=configuration::$configuration"
     echo "::set-output name=test_cases::$testcases"
     echo "::set-output name=passed::$passed"
     echo "::set-output name=failed::$failed"
     echo "::set-output name=errors::$errors"
     echo "::set-output name=start_time::$starttime"
     echo "::set-output name=end_time::$endtime"
     #echo "::set-output name=detailed_logs::$detailedlogs"
     #echo "::set-output name=screenshots_and_video::$screenshotsandvideo"
     exit 0
  fi
done
exit
