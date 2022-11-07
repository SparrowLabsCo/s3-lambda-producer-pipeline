
resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  number  = true
  upper   = false
}

resource "aws_lambda_layer_version" "dependencies" {
  filename   = data.archive_file.dependencies_zip_file.output_path
  layer_name = "s3-terraform-lambda-dependencies"
  source_code_hash =  data.archive_file.dependencies_zip_file.output_base64sha256
  compatible_runtimes = ["nodejs16.x"]
}

data "archive_file" "dependencies_zip_file" {
  type        = "zip"
  source_dir = var.dep_source_dir
  output_path = var.dep_archive_filepath
}

resource "aws_lambda_function" "lambda_s3_handler" {
  function_name    = "process-s3-new-objects"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "index.handler"
  role             = var.lambda_role_arn
  runtime          = var.runtime
  layers           = ["${aws_lambda_layer_version.dependencies.arn}"]
  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = concat(var.additional_security_group_ids, [])
  }

  environment {
    variables = {
      KAFKA_BROKERS = var.kafka_brokers
    }
  }
}

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_dir = var.source_dir
  output_path = var.archive_filepath
}

resource "aws_lambda_permission" "allow_bucket_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_s3_handler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

resource "aws_s3_bucket" "input_bucket" {
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
    lambda_function_arn = aws_lambda_function.lambda_s3_handler.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket_invoke_lambda]
}


output "input_bucket" {
  value       = aws_s3_bucket.input_bucket.bucket
  description = "The name of the bucket for file input."
}
