#!/bin/bash

set -e

export AWS_PAGER=""

regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)
for region in ${regions}; do
    aws lambda list-functions --region "${region}" \
        --query "Functions[?starts_with(Runtime, 'python')]" \
        --output json | \
        jq -r ".[] | [.FunctionName, .FunctionArn, .Runtime, .LastModified] | @csv"
done

