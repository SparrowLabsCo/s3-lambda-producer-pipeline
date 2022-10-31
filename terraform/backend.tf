terraform {
    backend "s3" {
        bucket = "chanfi0ne-tf-state"
        key    = "s3-terraform-lambda"
        region = "us-east-1"
    }
}