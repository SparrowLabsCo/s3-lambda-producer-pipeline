
resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  number  = true
  upper   = false
}

resource "aws_s3_bucket" "input_bucket" {
  bucket = "input-bucket-${terraform.workspace}-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "input-bucket-${terraform.workspace}-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "input_bucket_acl" {
  bucket = aws_s3_bucket.input_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = var.lambda_s3_handler_arn
    events              = ["s3:ObjectCreated:*"]
  }

}

resource "aws_cloudwatch_event_rule" "glue-crawler-state-change" {
  name        = "glue-crawler-state-change"
  description = "Glue Crawler State Change Event"
  is_enabled = true
  
  event_pattern = <<EOP
  {
    "crawlerName": ["${aws_glue_crawler.crawler.name}"],
    "state": [
        "Succeeded"
    ]
  }
  EOP

}

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "raw_catalog_${random_string.random.result}"
}

resource "aws_glue_crawler" "crawler" {
  name = "crawler-${random_string.random.result}"
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  role = var.glue_role

  s3_target {
    path = aws_s3_bucket.input_bucket.bucket
  }
}