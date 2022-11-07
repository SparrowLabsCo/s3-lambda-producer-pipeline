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

data "aws_iam_policy_document" "iam-for-lambda" {
  
  statement {
    sid = "AllowLambdaFunctionToCreateLogs"
    actions = [ 
      "logs:*" 
    ]
    effect = "Allow"
    resources = [ 
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    sid = "AllowLambdaFunctionMSKCluster"
    actions = [ 
      "kafka-cluster:Connect",
      "kafka-cluster:AlterCluster",
      "kafka-cluster:DescribeCluster"
    ]
    effect = "Allow"
    resources = [ 
      "${var.msk_arn}"
    ]
  }

   statement {
    sid = "AllowLambdaFunctionMSKTopic"
    actions = [ 
      "kafka-cluster:*Topic*",
      "kafka-cluster:WriteData",
      "kafka-cluster:ReadData"
    ]
    effect = "Allow"
    resources = [ 
      "${var.msk_arn}/*"
    ]
  }

  statement {
    sid = "AllowLambdaFunctionMSKGroup"
    actions = [ 
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup"
    ]
    effect = "Allow"
    resources = [ 
      "${var.msk_arn}/*"
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

resource "aws_iam_role_policy_attachment" "lambda-execution-role-attach" {
  role = aws_iam_role.lambda-execution-role.name
  policy_arn = aws_iam_policy.iam-for-lambda.arn
}

resource "aws_iam_role_policy_attachment" "lambda-execution-role-attach-1" {
  role = aws_iam_role.lambda-execution-role.name
  policy_arn = aws_iam_policy.iam-for-lambda-ec2.arn
}