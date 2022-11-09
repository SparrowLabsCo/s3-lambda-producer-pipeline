resource "aws_iam_policy" "iam-for-lambda" {
  name        = "iam-for-lambda-policy"
  #path        = ""
  description = "IAM Policy for Lambda execution"

  policy = data.aws_iam_policy_document.iam-for-lambda.json
}

resource "aws_iam_policy" "iam-for-lambda-ec2" {
  name        = "iam-for-lambda-policy-ec2"
  #path        = ""
  description = "EC2 IAM Policy for Lambda execution"

  policy = data.aws_iam_policy_document.iam-for-lambda-ec2.json
}

resource "aws_iam_policy" "iam-for-s3-access" {
  name        = "iam-for-s3-access"
  #path        = ""
  description = "S3 IAM Policy"

  policy = data.aws_iam_policy_document.s3-access.json
}


data "aws_iam_policy_document" "s3-access" {
  
  statement {
      sid = "s3Access"
      effect = "Allow"
      actions = [
          "s3:*"
      ]
      resources = var.bucket_arns
  }
}

data "aws_iam_policy_document" "iam-for-lambda" {
  
  statement {
      sid = "gluePermissions"
      effect = "Allow"
      actions = [
          "glue:CreateJob",
          "glue:CreateTable",
          "glue:StartCrawler",
          "glue:CreateDatabase",
          "glue:StartJobRun",
          "glue:StopCrawler",
          "glue:CreatePartition",
          "glue:GetJob",
          "glue:StartTrigger",
          "glue:CreateCrawler"
      ]
      resources = ["*"]
  }

  statement {
    sid = "AllowLambdaFunctionToCreateLogs"
    actions = [ 
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [ 
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    sid = "IAMRole"
    effect = "Allow"
    actions = [
        "iam:PassRole"
    ]
    resources = [
      aws_iam_role.glue-role.arn
    ]
  }

  statement {
    sid = "AllowSQS"
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:ListQueues",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      var.input_sqs_queue
    ]
  }
}

data "aws_iam_policy_document" "iam-for-lambda-ec2" {
statement {
    sid = "AllowLambdaFunctionExecuteEC2"
    actions = [ 
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface" 
    ]
    effect = "Allow"
    resources = [ 
      "*",
    ]
  }
}

resource "aws_iam_role" "lambda-execution-role" {
  name                = "lambda-execution-role"
  #path                = ""
  description         = "Service Role for Lambda execution"
  assume_role_policy  = <<-EOP
  {

    "Version":"2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
               "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition" : {}
        }
    ]

  }
  EOP

  tags = var.default_tags

}

resource "aws_iam_role" "glue-role" {
  name                = "glue-role"
  #path                = ""
  description         = "Service Role for Glue"
  assume_role_policy  = <<-EOP
  {

    "Version":"2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
               "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition" : {}
        }
    ]

  }
  EOP

  tags = var.default_tags

}

resource "aws_iam_role_policy_attachment" "lambda-execution-role-attach" {
  role = aws_iam_role.lambda-execution-role.name
  policy_arn = aws_iam_policy.iam-for-lambda.arn
}

resource "aws_iam_role_policy_attachment" "lambda-execution-role-attach-1" {
  role = aws_iam_role.lambda-execution-role.name
  policy_arn = aws_iam_policy.iam-for-lambda-ec2.arn
}

resource "aws_iam_role_policy_attachment" "lambda-execution-role-attach-2" {
  role = aws_iam_role.lambda-execution-role.name
  policy_arn = aws_iam_policy.iam-for-s3-access.arn
}

resource "aws_iam_role_policy_attachment" "glue-service-role-attach" {
  role = aws_iam_role.glue-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue-service-role-attach-1" {
  role = aws_iam_role.glue-role.name
  policy_arn = aws_iam_policy.iam-for-s3-access.arn
}