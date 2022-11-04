
resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  number  = true
  upper   = false
}

resource "aws_msk_serverless_cluster" "s3_streaming" {
  cluster_name = "s3-streaming"

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = concat(var.additional_security_group_ids,[aws_security_group.msk_sg.id])
  }

  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }
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
