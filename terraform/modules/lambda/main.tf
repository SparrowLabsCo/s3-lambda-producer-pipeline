
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

  compatible_architectures = [ "x86_64" ]

}

data "archive_file" "dependencies_zip_file" {
  type        = "zip"
  source_dir = var.dep_source_dir
  output_path = var.dep_archive_filepath
}

resource "aws_lambda_function" "crawler_s3_handler" {
  function_name    = "process-s3-new-objects"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "crawler.handler"
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
      REGION        = var.region
      CRAWLER_NAME  = var.crawler_name
    }
  }
}

resource "aws_lambda_function" "conversion_handler" {
  function_name    = "convert-s3-data"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "conversion.handler"
  role             = var.lambda_role_arn
  runtime          = var.runtime
  layers           = ["${aws_lambda_layer_version.dependencies.arn}"]
  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = concat(var.additional_security_group_ids, [])
  }
  
  environment {
    variables = {
      JOB_NAME  = var.crawler_name
    }
  }
}

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_dir = var.source_dir
  output_path = var.archive_filepath
}

resource "aws_lambda_permission" "allow_crawler_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crawler_s3_handler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.input_bucket_arn
}

resource "aws_lambda_permission" "allow_conversion_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.conversion_s3_handler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.output_bucket_arn
}

output crawler_lambda_arn {
  value = aws_lambda_function.crawler_s3_handler.arn
}

output convrsion_s3_lambda_arn {
  value = aws_lambda_function.conversion_s3_handler.arn
}