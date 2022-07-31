data "archive_file" "tf-nifi-lambda-health-archive" {
  type        = "zip"
  source_file = "nifi-lambda-health.py"
  output_path = "nifi-lambda-health.zip"
}

resource "aws_lambda_function" "tf-nifi-lambda-health-function" {
  filename         = "nifi-lambda-health.zip"
  source_code_hash = data.archive_file.tf-nifi-lambda-health-archive.output_base64sha256
  function_name    = "${var.name_prefix}-lambda-health-${random_string.tf-nifi-random.result}"
  role             = aws_iam_role.tf-nifi-iam-role-lambda-health.arn
  kms_key_arn      = aws_kms_key.tf-nifi-kmscmk-lambda.arn
  memory_size      = 256
  handler          = "nifi-lambda-health.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300
  environment {
    variables = {
      WEB_PORT = var.web_port
      PREFIX   = var.name_prefix
      SUFFIX   = random_string.tf-nifi-random.result
      REGION   = var.aws_region
    }
  }
  vpc_config {
    security_group_ids = [aws_security_group.tf-nifi-prisg.id]
    subnet_ids         = [aws_subnet.tf-nifi-prinet1.id]
  }
  depends_on = [aws_cloudwatch_log_group.tf-nifi-cloudwatch-log-group-lambda-health]
}

resource "aws_lambda_alias" "tf-nifi-lambda-health-alias" {
  name             = "${var.name_prefix}-lambda-health-alias-${random_string.tf-nifi-random.result}"
  description      = "Latest function"
  function_name    = aws_lambda_function.tf-nifi-lambda-health-function.function_name
  function_version = aws_lambda_function.tf-nifi-lambda-health-function.version
}

resource "aws_lambda_permission" "tf-nifi-lambda-health-permit-cloudwatch" {
  statement_id  = "AllowExecutionFromCloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf-nifi-lambda-health-function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.tf-nifi-cloudwatch-event-rule-health.arn
  qualifier     = aws_lambda_alias.tf-nifi-lambda-health-alias.name
}
