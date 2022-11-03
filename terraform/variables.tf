variable "vpc_id" {
    default = null
}

variable "region" {
    default = "us-east-1"
}

variable "octo_tags" {
    type = map

    default = {
        "Owner"         = "Jon Ceanfaglione"
        "Managed By"    = "Terraform"
        "Project"       = "s3-terraform-lambda"
        "ContactEmail"  = "jon.ceanfaglione@gmail.com"
    }
}