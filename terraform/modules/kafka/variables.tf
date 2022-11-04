
variable "subnet_ids" {
    type = list
}

variable "vpc_id" {
    type = string
}

variable "lambda_sg_id" {
    type = string
}

variable "additional_security_group_ids" {
    type = list
    default = []
}