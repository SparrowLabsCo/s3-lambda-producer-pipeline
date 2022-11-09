output "lambda_execution_role" {
    value = aws_iam_role.lambda-execution-role
}

output "glue_role" {
    value = aws_iam_role.glue-role
}