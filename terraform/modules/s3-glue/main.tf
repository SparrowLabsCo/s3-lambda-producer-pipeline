
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
  bucket = "output-bucket-${terraform.workspace}-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket" "glue_bucket" {
  bucket = "glue-bucket-${terraform.workspace}-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "input_bucket_acl" {
  bucket = aws_s3_bucket.input_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "output_bucket_acl" {
  bucket = aws_s3_bucket.output_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "glue_bucket_acl" {
  bucket = aws_s3_bucket.glue_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = var.crawler_s3_handler_arn
    events              = ["s3:ObjectCreated:*"]
  }

}

resource "aws_cloudwatch_event_rule" "glue-crawler-state-change" {
  name        = "glue-crawler-state-change"
  description = "Glue Crawler State Change Event"
  is_enabled = true
  
  event_pattern = <<EOF
  {
    "detail-type": [
      "Glue Crawler State Change"
    ],
    "source": [
      "aws.glue"
    ],
    "detail": {
      "crawlerName": [
        "${aws_glue_crawler.crawler.name}"
      ],
      "state": [
        "Succeeded"
      ]
    }
  }
  EOF

}

resource "aws_cloudwatch_event_target" "conversion-lambda-target" {
  arn = var.conversion_lambda_function_arn
  rule = aws_cloudwatch_event_rule.glue-crawler-state-change.name
}

resource "aws_lambda_permission" "allow-cloudwatch-to-call-conversion-lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = var.conversion_lambda_function_arn
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.glue-crawler-state-change.arn
}

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "raw_catalog_${random_string.random.result}"
}

resource "aws_glue_crawler" "crawler" {
  name = "crawler-${random_string.random.result}"
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  role = var.glue_role
  table_prefix = "${random_string.random.result}-"
  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      }
      CrawlerOutput = {
        Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      }
      Version = 1
    }
  )

  s3_target {
    path = "s3://${aws_s3_bucket.input_bucket.bucket}/patients"
  }
}

data "template_file" "glue_job_transform" {
  template = "${file("${path.module}/scripts/transform.py")}"
  vars = {
    glue_catalog_database   = aws_glue_catalog_database.aws_glue_catalog_database.name
    glue_catalog_table      = "${random_string.random.result}-patients"
    target_s3               = "s3://${aws_s3_bucket.output_bucket.bucket}/patients/"
  }
}

resource "aws_s3_object" "glue_transform_job" {
  bucket = aws_s3_bucket.glue_bucket.bucket
  key = "scripts/transform.py"
  
  content = data.template_file.glue_job_transform.rendered
}