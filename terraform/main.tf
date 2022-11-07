
module "iam" {
  source = "./modules/iam"
  region = var.region
  default_tags = var.octo_tags
}


module "lambda" {
  source = "./modules/lambda"
  source_dir = "../src/dist"
  archive_filepath = "../src/dist/lambda.zip"
  dep_source_dir = "../nodmodules"
  dep_archive_filepath = "../node_modules.zip"
  lambda_role_arn = module.iam.lambda_execution_role.arn
  subnet_ids = [for s in data.aws_subnet.private : s.id]
  additional_security_group_ids = [module.sg.msk_sg_id]
  vpc_id = var.vpc_id
  kafka_brokers =  module.msk.cluster_ep

  depends_on = [
    module.sg,
    module.msk
  ]
}

module "msk" {
  source = "./modules/kafka"
  subnet_ids = [for s in data.aws_subnet.private : s.id]
  #additional_security_group_ids = []
  vpc_id = var.vpc_id
  lambda_sg_id = module.sg.lambda_sg_id

  depends_on = [
    module.sg
  ]
}

module "sg" {
  source = "./modules/sg"
  vpc_id = var.vpc_id
}


/***** Optional *********/
module "vpc" {
  count = var.vpc_id == null ? 1 : 0
  source = "./modules/vpc"
  vpc_name   = "${terraform.workspace}-s3-terraform-lambda-vpc"
}