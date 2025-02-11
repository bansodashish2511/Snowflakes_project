#### First, Create the IAM Roles and Policies (using Terraform)
### Second Set up the Python ETL Script.
### Step-by-Step Deployment Process:
# 1. Initialize and apply Terraform
terraform init
terraform plan
terraform apply

# 2. Upload the Python script to S3
aws s3 cp migration_script.py s3://your-glue-scripts-bucket/scripts/

# 3. Run the Glue job
aws glue start-job-run --job-name snowflake-to-dynamodb-migration

#### Before running:

    Update the Snowflake connection parameters
    Create your DynamoDB table if not exists
    Configure VPC settings if needed
    Test Snowflake connectivity
    Verify IAM permissions


    Running Options:

    a. AWS Console:

    Go to AWS Glue Console
    Select Jobs
    Find your job and click "Run job"

    b. AWS CLI:
    bashCopyaws glue start-job-run --job-name snowflake-to-dynamodb-migration

    c. Python (using boto3):
        import boto3
        glue = boto3.client('glue')
        response = glue.start_job_run(JobName='snowflake-to-dynamodb-migration')