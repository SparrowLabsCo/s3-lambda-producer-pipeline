output "input_s3_bucket" {
    value = module.lambda.input_bucket
}

output "private_subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.private : s.cidr_block]
}

output "private_subnet_ids" {
  value = [for s in data.aws_subnet.private : s.id]
}