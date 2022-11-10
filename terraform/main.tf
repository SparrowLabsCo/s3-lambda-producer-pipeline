
module "iam" {
  source = "./modules/iam"
  region = var.region
  default_tags = var.octo_tags
  
  bucket_arns = [
    "${module.s3.input_bucket_arn}/*",
    "${module.s3.input_bucket_arn}/data/*",
    "${module.s3.output_bucket_arn}/*"
  ]

  input_sqs_queue = module.sqs.input_processing_queue_arn
}

module "s3" {
  source = "./modules/s3-glue"
  crawler_s3_handler_arn = module.lambda.crawler_lambda_arn
  glue_role = module.iam.glue_role.arn
  conversion_lambda_function_arn = module.lambda.conversion_s3_lambda_arn
}

module "sqs" {
  source = "./modules/sqs"
  tags = var.octo_tags
}

module "lambda" {
  source = "./modules/lambda"
  source_dir = "../functions/dist"
  archive_filepath = "../functions/output/lambda.zip"
  dep_source_dir = "../layers/common-dependencies/"
  dep_archive_filepath = "../layers/common-dependencies/common-dependencies.zip"
  lambda_role_arn = module.iam.lambda_execution_role.arn
  subnet_ids = [for s in data.aws_subnet.private : s.id]
  additional_security_group_ids = [module.sg.lambda_sg_id]
  vpc_id = var.vpc_id
  crawler_name = module.s3.crawler_name
  region = var.region
  input_bucket_arn = module.s3.input_bucket_arn
  output_bucket_arn = module.s3.output_bucket_arn

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