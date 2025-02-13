import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.transforms import ApplyMapping
from awsglue.job import Job

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(sys.argv[1], sys.argv)

# Read from S3 (Modify format if needed)
s3_path = "s3://your-s3-bucket/path/to/data/"  ##->> s3 
data_frame = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": [s3_path]},
    format="json"
)

# Mapping (Modify fields according to your schema)
mapped_frame = ApplyMapping.apply(
    frame=data_frame,
    mappings=[
        ("id", "string", "id", "S"),
        ("name", "string", "name", "S"),
        ("age", "int", "age", "N")
    ]
)

# Write to DynamoDB
dynamo_table_name = "your-dynamodb-table"
glueContext.write_dynamic_frame.from_options(
    frame=mapped_frame,
    connection_type="dynamodb",
    connection_options={"dynamodb.output.tableName": dynamo_table_name}
)

job.commit()
