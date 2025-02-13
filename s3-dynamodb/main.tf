##Create an IAM Role for AWS Glue This role allows AWS Glue to access S3 and DynamoDB.

resource "aws_iam_role" "glue_role" {
  name = "AWSGlueS3ToDynamoDBRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "glue_s3_dynamodb_policy" {
  name = "GlueS3DynamoDBPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = ["arn:aws:s3:::your-s3-bucket", "arn:aws:s3:::your-s3-bucket/*"] ##-->>arn of s3
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem", "dynamodb:BatchWriteItem"],
        Resource = "arn:aws:dynamodb:us-east-1:YOUR_AWS_ACCOUNT_ID:table/your-dynamodb-table"  ##-->> arn of dynamodb
      },
      {
        Effect   = "Allow",
        Action   = ["glue:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_attach_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_dynamodb_policy.arn
}

##Create the AWS Glue Job This job reads JSON data from S3 and writes it to DynamoDB.

resource "aws_glue_job" "s3_to_dynamodb" {
  name     = "s3-to-dynamodb-glue-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://your-s3-bucket/scripts/glue_script.py" ##-->> update the location of the script with the name of the s3 bucket
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir"                 = "s3://your-s3-bucket/temp/" ##-->> check if you need this temp object if yes create a temp object in your S3
    "--job-language"            = "python"
    "--dynamodb.output.tableName" = "your-dynamodb-table"  ##-->> dynamodb table
  }

  glue_version = "2.0"
  worker_type  = "G.1X"
  number_of_workers = 2
}
