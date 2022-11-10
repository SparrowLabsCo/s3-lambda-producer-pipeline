import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node S3 bucket
S3bucket_node1 = glueContext.create_dynamic_frame.from_catalog(
    database="${glue_catalog_database}",
    table_name="${glue_catalog_table}",
    transformation_ctx="S3bucket_node1",
)

# Script generated for node ApplyMapping
ApplyMapping_node2 = ApplyMapping.apply(
    frame=S3bucket_node1,
    mappings=[
        ("id", "string", "id", "string"),
        ("birth_date", "string", "birth_date", "string"),
        ("death_date", "string", "death_date", "string"),
        ("social_sec_num", "string", "social_sec_num", "string"),
        ("drivers", "string", "drivers", "string"),
        ("passport", "string", "passport", "string"),
        ("prefix", "string", "prefix", "string"),
        ("first_name", "string", "first_name", "string"),
        ("surname", "string", "surname", "string"),
        ("suffix", "string", "suffix", "string"),
        ("maiden_name", "string", "maiden_name", "string"),
        ("marital", "string", "marital", "string"),
        ("race", "string", "race", "string"),
        ("ethnicity", "string", "ethnicity", "string"),
        ("gender", "string", "gender", "string"),
        ("birthplace", "string", "birthplace", "string"),
        ("address", "string", "address", "string"),
        ("postal_code", "long", "postal_code", "long"),
        ("city", "string", "city", "string"),
        ("state", "string", "state", "string"),
        ("county", "string", "county", "string"),
        ("lat", "double", "lat", "double"),
        ("lon", "double", "lon", "double"),
        ("healthcare_coverage", "double", "healthcare_coverage", "double"),
        ("healthcare_expenses", "double", "healthcare_expenses", "double"),
    ],
    transformation_ctx="ApplyMapping_node2",
)

# Script generated for node S3 bucket
S3bucket_node3 = glueContext.write_dynamic_frame.from_options(
    frame=ApplyMapping_node2,
    connection_type="s3",
    format="glueparquet",
    connection_options={
        "path": "${target_s3}",
        "partitionKeys": [],
    },
    format_options={"compression": "snappy"},
    transformation_ctx="S3bucket_node3",
)

job.commit()