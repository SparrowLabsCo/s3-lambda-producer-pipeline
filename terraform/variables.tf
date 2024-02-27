variable "vpc_id" {
    default = null
}

variable "region" {
    default = "us-east-1"
}

variable "tags" {
    type = map

    default = {
        "Owner"         = "Jon Ceanfaglione"
        "Managed By"    = "Terraform"
        "Project"       = "s3-terraform-lambda"
        "ContactEmail"  = "jonc@sparrowlabs.dev"
    }
}