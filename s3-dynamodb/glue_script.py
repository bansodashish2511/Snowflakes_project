import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.transforms import ApplyMapping
from awsglue.job import Job

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(sys.argv[1], sys.argv)

# S3 source configuration
s3_path = "s3://your-bucket/account/json/"  # Replace with your S3 bucket path

# Read JSON data from S3
data_frame = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={
        "paths": [s3_path],
        "recurse": True
    },
    format="json"
)

# Define mappings based on the JSON structure
mapped_frame = ApplyMapping.apply(
    frame=data_frame,
    mappings=[
        ("ToCode", "string", "ToCode", "S"),
        ("InvestmentObjectiveName", "string", "InvestmentObjectiveName", "S"),
        ("SectionName", "string", "SectionName", "S"),
        ("SectionSortOrder", "string", "SectionSortOrder", "S"),
        ("AccountSortOrder", "string", "AccountSortOrder", "S"),
        ("AccountTitle", "string", "AccountTitle", "S"),
        ("AccountId", "long", "AccountId", "N"),
        ("AccountLocationCode", "long", "AccountLocationCode", "N"),
        ("AccountNo", "long", "AccountNo", "N"),
        ("LplAccountNo", "long", "LplAccountNo", "N"),
        ("SponsorAccountNo", "long", "SponsorAccountNo", "N"),
        ("SponsorCode", "long", "SponsorCode", "N"),
        ("AccountName", "string", "AccountName", "S"),
        ("Cusip", "string", "Cusip", "S"),
        ("NickName", "string", "NickName", "S"),
        ("AccountClassName", "string", "AccountClassName", "S"),
        ("AcName", "string", "AcName", "S"),
        ("SponsorName", "string", "SponsorName", "S"),
        ("AccountStatus", "string", "AccountStatus", "S"),
        ("AccountNotes", "string", "AccountNotes", "S"),
        ("IsPerformanceEligible", "long", "IsPerformanceEligible", "N"),
        ("AccountOpenDate", "string", "AccountOpenDate", "S")
    ]
)

# Configure DynamoDB target
dynamo_table_name = "account_summary"  # Replace with your DynamoDB table name

# Write to DynamoDB with error handling
try:
    glueContext.write_dynamic_frame.from_options(
        frame=mapped_frame,
        connection_type="dynamodb",
        connection_options={
            "dynamodb.output.tableName": dynamo_table_name,
            "dynamodb.throughput.write.percent": "1.0",  # Adjust if needed
            "dynamodb.retry.count": "3"
        }
    )
    print(f"Successfully wrote data to DynamoDB table: {dynamo_table_name}")
except Exception as e:
    print(f"Error writing to DynamoDB: {str(e)}")
    raise e

job.commit()