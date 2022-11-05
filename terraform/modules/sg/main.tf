
resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  number  = true
  upper   = false
}

resource "aws_security_group" "msk_sg" {
  name   = "msk-lambda-ingress-${terraform.workspace}-${random_string.random.result}"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "msk_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.msk_sg.id
}

resource "aws_security_group_rule" "lambda_ingress" {
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "TCP"
  source_security_group_id = var.lambda_sg_id
  security_group_id = aws_security_group.msk_sg.id
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

