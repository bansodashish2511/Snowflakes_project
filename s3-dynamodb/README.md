1. Prerequisites
Ensure you have Terraform installed.
Your data should be in S3 in JSON, CSV, or Parquet format.
The target DynamoDB table should exist.
An IAM Role for AWS Glue should be created with appropriate permissions.

2. Run the following Terraform commands:
terraform init
terraform plan
terraform apply

3. Run the AWS Glue Job:
After deployment, manually start the Glue job via:

aws glue start-job-run --job-name s3-to-dynamodb-glue-job

