

output "input_bucket_arn" {
  value       = aws_s3_bucket.input_bucket.arn
  description = "The name of the bucket for file input."
}

output "output_bucket_arn" {
  value       = aws_s3_bucket.output_bucket.arn
  description = "The name of the bucket for parquet output."
}

output "crawler_name" {
  value = aws_glue_crawler.crawler.name
}