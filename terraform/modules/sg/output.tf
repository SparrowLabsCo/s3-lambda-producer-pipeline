output msk_sg_id {
    value = aws_security_group.msk_sg.id
}

output "lambda_sg_id" {
  value       = aws_security_group.lambda_sg.id
  description = "The SG for the lambda function."
}