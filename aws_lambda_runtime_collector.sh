#!/bin/bash

export AWS_PAGER=""

regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)
for region in ${regions}; do
    aws lambda list-functions --region "${region}" \
        --query "Functions[].join(',', ['${region}',FunctionName,FunctionArn,Runtime,LastModified])" \
        --output text
done

