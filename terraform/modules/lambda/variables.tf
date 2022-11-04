
variable "lambda_role_arn" {
    type = string
}

variable "source_dir" {
    type = string
}

variable "archive_filepath" {
    type = string
}

variable "subnet_ids" {
    type = list
}

variable "vpc_id" {
    type = string
}

variable "runtime" {
    type = string
    default = "nodejs16.x"
}

variable "additional_security_group_ids" {
    type = list
    default = []
}