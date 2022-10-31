resource "aws_iam_policy" "iam-for-lambda" {
  name        = "iam-for-lambda-policy"
  #path        = ""
  description = "IAM Policy for Lambda execution"

  policy = data.aws_iam_policy_document.iam-for-lambda-doc.json
}

data "aws_iam_policy_document" "iam-for-lambda-doc" {
  statement {
    sid = "AllowLambdaFunctionToCreateLogs"
    actions = [ 
      "logs:*" 
    ]
    effect = "Allow"
    resources = [ 
      "arn:aws:logs:*:*:*" 
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

resource "aws_iam_role_policy_attachment" "amplify-role-attach" {
  role = aws_iam_role.lambda-execution-role.name
  policy_arn = aws_iam_policy.iam-for-lambda.arn
}