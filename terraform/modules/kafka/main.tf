
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
    security_group_ids = concat(var.additional_security_group_ids,[])
  }

  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }
}

output cluster_bootstrap_arn {
   value = aws_msk_serverless_cluster.s3_streaming.arn
}