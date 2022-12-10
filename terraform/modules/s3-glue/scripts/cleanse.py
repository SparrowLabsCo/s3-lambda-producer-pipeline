import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import functions as f
from pyspark.sql.functions import udf


def ascii_ignore(x):
    return x.encode('ascii', 'ignore').decode('ascii')

ascii_udf = udf(ascii_ignore)

def trim_to_null(c):
  return (
    f.lower(
      f.when(f.trim(f.col(c)) == '', None)
      .when(f.trim(f.col(c)) == 'null', None)
      .otherwise(f.trim(f.col(c)))
    )
  )

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

job.init(args["JOB_NAME"], args)

patients = spark.read.parquet("${source_s3}")

keep_cols = ['id', 'birth_date', 'first_name', 'surname', 'social_sec_num','suffix']

people_bronze = patients.select(*keep_cols)
people_bronze = people_bronze.withColumn("first_name", ascii_udf('first_name'))
people_bronze = people_bronze.withColumn("last_name", ascii_udf('surname'))
people_bronze = people_bronze.withColumn("suffix", f.lower(trim_to_null("suffix")))
people_bronze = people_bronze.drop(people_bronze.surname)
people_bronze.printSchema()
people_bronze.write.format("parquet").mode("overwrite").save("${target_s3}/parquet")
people_bronze.write.format("delta").mode("overwrite").save("${target_s3}/delta")

job.commit()