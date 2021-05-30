# lambda function source code
data "archive_file" "tf-nifi-lambda-file-scaledown" {
  type        = "zip"
  source_file = "nifi-lambda-scaledown.py"
  output_path = "nifi-lambda-scaledown.zip"
}

# lambda function conf
resource "aws_lambda_function" "tf-nifi-lambda-scaledown" {
  filename         = "nifi-lambda-scaledown.zip"
  source_code_hash = data.archive_file.tf-nifi-lambda-file-scaledown.output_base64sha256
  function_name    = "${var.name_prefix}-lambda-scaledown-${random_string.tf-nifi-random.result}"
  role             = aws_iam_role.tf-nifi-iam-role-lambda-scaledown.arn
  kms_key_arn      = aws_kms_key.tf-nifi-kmscmk-lambda.arn
  handler          = "nifi-lambda-scaledown.lambda_handler"
  runtime          = "python3.8"
  timeout          = 120
  environment {
    variables = {
      SSMDOCUMENTNAME = aws_ssm_document.tf-nifi-ssmdoc-scaledown.name
    }
  }
  depends_on = [aws_cloudwatch_log_group.tf-nifi-cloudwatch-log-group-lambda-scaledown]
}

# allow sns to call lambda
resource "aws_lambda_permission" "tf-nifi-lambda-permission-scaledown" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf-nifi-lambda-scaledown.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.tf-nifi-sns-scaledown.arn
}
