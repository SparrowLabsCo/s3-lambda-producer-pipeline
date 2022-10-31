
module "iam" {
  source = "./modules/iam"
  region = var.region
  default_tags = var.octo_tags
}


module "lambda" {
  source = "./modules/lambda"
  lambda_source = "../src/index.js"
  archive_filepath = "../src/dist/lambda.zip"
  lambda_role_arn = module.iam.lambda_execution_role.arn
}