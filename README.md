AWS Lambda Runtime Collector

Overview
- This repository contains a single Bash script, aws_lambda_runtime_collector.sh, that inventories AWS Lambda functions 
  across all commercial AWS regions in your account.
- For every region, it outputs one comma-separated line per function with the following fields:
  region,function_name,function_arn,runtime,last_modified

What this script does
- Queries the list of available AWS regions via EC2 DescribeRegions.
- Iterates every region and calls Lambda ListFunctions.
- Prints a CSV-friendly line for each function combining select fields.
- Disables the AWS CLI pager to ensure clean, non-interactive output.

Prerequisites
- Bash (any modern Linux/macOS shell will do; works in Git Bash on Windows too).
- AWS CLI v2 installed and in PATH.
- AWS credentials configured with permission to describe regions and list Lambda functions. You can authenticate via:
  - Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN), or
  - Named profile (AWS_PROFILE), or
  - SSO profiles configured with aws configure sso.

Least-privilege IAM policy
Attach a policy like the following to the principal you use to run the script:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeRegions",
        "lambda:ListFunctions"
      ],
      "Resource": "*"
    }
  ]
}

Usage
1) Make the script executable
   chmod +x aws_lambda_runtime_collector.sh

2) Run it with your desired AWS profile (optional)
   # Using default credentials
   ./aws_lambda_runtime_collector.sh

   # Using a named profile
   AWS_PROFILE=prod ./aws_lambda_runtime_collector.sh

3) Save results to a CSV file with a header
   echo "region,function_name,function_arn,runtime,last_modified" > lambda_inventory_prod.csv
   AWS_PROFILE=prod ./aws_lambda_runtime_collector.sh >> lambda_inventory_prod.csv

Example output (one line per function)
us-east-1,my-func,arn:aws:lambda:us-east-1:123456789012:function:my-func,python3.12,2025-11-15T09:42:31.123+0000

Security considerations
- Use least-privilege IAM.
- Prefer temporary credentials (SSO or role assumption) over static long-lived keys.
- Review and store inventory outputs securely if they contain sensitive function names or ARNs.
