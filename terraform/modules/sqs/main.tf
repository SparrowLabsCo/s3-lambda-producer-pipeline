resource "aws_sqs_queue" "processing_queue" {
  name                      = "processing-queue"
  delay_seconds             = 300
  max_message_size          = 2048
  visibility_timeout_seconds = 300
#  message_retention_seconds = 86400
#  receive_wait_time_seconds = 10
 
#   redrive_policy = jsonencode({
#     deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
#     maxReceiveCount     = 4
#   })

  tags = var.tags
}

variable tags {
    type = map
}

output input_processing_queue_arn {
    value = aws_sqs_queue.processing_queue.arn
}