# 1. Create a new Terraform file (main.tf) with the IAM configurations
provider "aws" {
  region = "your-region"
}

# Glue IAM Role
resource "aws_iam_role" "glue_role" {
  name = "glue-snowflake-dynamodb-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

# Required policies attachment
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# DynamoDB permissions
resource "aws_iam_role_policy" "dynamodb_access" {
  name = "dynamodb-access"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem"
      ]
      Resource = ["arn:aws:dynamodb:*:*:table/*"]
    }]
  })
}

# S3 bucket for Glue scripts
resource "aws_s3_bucket" "glue_scripts" {
  bucket = "your-glue-scripts-bucket"
}

# Glue Job Definition
resource "aws_glue_job" "snowflake_to_dynamodb" {
  name     = "snowflake-to-dynamodb-migration"
  role_arn = aws_iam_role.glue_role.arn
  
  command {
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/scripts/migration_script.py"
    python_version  = "3"
  }
}

# 2. Create Glue Connection for Snowflake
resource "aws_glue_connection" "snowflake_connection" {
  name = "snowflake-connection"
  
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:snowflake://your-account.snowflakecomputing.com/"
    USERNAME           = "your-username"
    PASSWORD           = "your-password"
  }
}