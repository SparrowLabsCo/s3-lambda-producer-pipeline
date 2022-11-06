
resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  number  = true
  upper   = false
}

resource "aws_security_group" "msk_sg" {
  name   = "msk-sg-${terraform.workspace}"
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
  from_port         = 9098
  to_port           = 9098
  protocol          = "TCP"
  source_security_group_id = aws_security_group.lambda_sg.id
  security_group_id = aws_security_group.msk_sg.id
}



resource "aws_security_group" "lambda_sg" {
  name   = "lambda-sg-${terraform.workspace}"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "lambda_msk" {
  type              = "ingress"
  from_port         = 9098
  to_port           = 9098
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda_sg.id
}



