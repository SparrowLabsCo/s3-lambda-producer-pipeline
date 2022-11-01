
variable "lambda_role_arn" {
    type = string
}

variable "source_dir" {
    type = string
}

variable "archive_filepath" {
    type = string
}

variable "runtime" {
    type = string
    default = "nodejs16.x"
}