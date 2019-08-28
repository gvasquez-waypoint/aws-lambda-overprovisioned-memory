#!/bin/bash
namespace='Waypoint/Lambda'

aws sts get-caller-identity
query_string='filter @type = "REPORT" | stats max(@memorySize / 1024 / 1024) as provisonedMemoryMB,     min(@maxMemoryUsed / 1024 / 1024) as smallestMemoryRequestMB,     avg(@maxMemoryUsed / 1024 / 1024) as avgMemoryUsedMB,    max(@maxMemoryUsed / 1024 / 1024) as maxMemoryUsedMB,     provisonedMemoryMB - maxMemoryUsedMB as overProvisionedMB'
start_time=$(date -v -7d '+%s')
end_time=$(date '+%s')

logs=$(aws logs describe-log-groups --log-group-name-prefix '/aws/lambda'|jq -r '.logGroups[] | select(.storedBytes > 0) | .logGroupName')

while read -r log_name; do
	echo "log: <$log_name>"
	lambda=$(echo $log_name|cut -c 13-)
	query_id=$(aws logs start-query --log-group-name "$log_name" --start-time $start_time --end-time $end_time --query-string "$query_string"|jq -r '.queryId')
	if [ $query_id != "" ]
	then
		echo "id: <$query_id>"
		until [  $(aws logs get-query-results --query-id $query_id|jq -r '.status') = "Complete" ];
			do
			  sleep 1s
			  status=$(aws logs get-query-results --query-id $query_id|jq -r '.status')
			done
		value=$(aws logs get-query-results --query-id $query_id|jq -r '.results[0][4].value')
	
		if [ "$value" != "null" ]
		then
			echo $value
			aws cloudwatch put-metric-data --namespace "$namespace" --metric-name overProvisionedMB --dimensions functionName=$lambda --value $value
		fi
	fi
	echo
done <<< "$logs"