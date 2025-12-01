#!/bin/bash

set -e

export AWS_PAGER=""

regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)
start_time=$(date -u -d "1 year ago" +"%Y-%m-%dT%H:%M:%SZ")
end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo '"Function name","ARN","Runtime version","Last modified","Ran in a year"'
for region in ${regions}; do
    functions=$(aws lambda list-functions --region "${region}" \
        --query "Functions[?starts_with(Runtime, 'python')]" \
        --output json | \
        jq -r ".[] | [.FunctionName, .FunctionArn, .Runtime, .LastModified] | @csv")

    for func_data in $functions; do 
        func_name=$(echo "${func_data}" | tr -d '"' | awk -F ',' '{print $1}')
        func_arn=$(echo "${func_data}" | tr -d '"' | awk -F ',' '{print $2}')
        func_runtime=$(echo "${func_data}" | tr -d '"' | awk -F ',' '{print $3}')
        func_lastmod=$(echo "${func_data}" | tr -d '"' | awk -F ',' '{print $4}')
    
        func_metrics=$(aws cloudwatch get-metric-statistics \
            --namespace AWS/Lambda \
            --metric-name Invocations \
            --dimensions Name=FunctionName,Value="${func_name}" \
            --start-time "$start_time" \
            --end-time "$end_time" \
            --period 86400 \
            --statistics Sum | jq '.Datapoints | length')
        
        ran_in_a_year="yes"
        if [ $func_metrics -eq 0 ]; then
            ran_in_a_year="no"
        fi

        printf '"%s","%s","%s","%s","%s"\n' "$func_name" "$func_arn" "$func_runtime" "$func_lastmod" "$ran_in_a_year"
    done
done

