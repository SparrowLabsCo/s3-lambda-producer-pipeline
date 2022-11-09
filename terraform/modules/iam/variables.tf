
variable "default_tags" {
    type = map
}


variable "region" {
    type = string
}

variable "bucket_arns" {
    type = list
}

variable "input_sqs_queue" {
    type = string
}