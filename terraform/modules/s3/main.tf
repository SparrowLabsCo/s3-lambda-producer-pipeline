
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

