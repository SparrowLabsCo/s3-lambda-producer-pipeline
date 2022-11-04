
resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  number  = true
  upper   = false
}

resource "aws_lambda_function" "lambda_s3_handler" {
  function_name    = "process-s3-new-objects"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "index.handler"
  role             = var.lambda_role_arn
  runtime          = var.runtime

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = concat(var.additional_security_group_ids, [aws_security_group.lambda_msk.id])
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
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_handler.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket_invoke_lambda]
}


resource "aws_security_group" "lambda_msk" {
  name   = "lambda-msk-${terraform.workspace}-${random_string.random.result}"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "lambda_msk" {
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda_msk.id
}

output "input_bucket" {
  value       = aws_s3_bucket.input_bucket.bucket
  description = "The name of the bucket for file input."
}


output "lambda_sg_id" {
  value       = aws_security_group.lambda_msk.id
  description = "The SG for the lambda function."
}
