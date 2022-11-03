data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = var.vpc_name
  cidr                 = "172.32.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.32.1.0/24", "172.32.2.0/24", "172.32.3.0/24"]
  public_subnets       = ["172.32.4.0/24", "172.32.5.0/24", "172.32.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {

  }

}