
variable "lambda_role_arn" {
    type = string
}

variable "source_dir" {
    type = string
}

variable "archive_filepath" {
    type = string
}

variable "dep_source_dir" {
    type = string
}

variable "dep_archive_filepath" {
    type = string
}

variable "subnet_ids" {
    type = list
}

variable "vpc_id" {
    type = string
}

variable "kafka_brokers" {
    type = string
    default = ""
}

variable "runtime" {
    type = string
    default = "nodejs16.x"
}

variable "additional_security_group_ids" {
    type = list
    default = []
}

variable "region" {
    type = string
}

variable "input_bucket_arn" {
    type = string
}