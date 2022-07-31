resource "aws_lambda_function" "tf-nifi-lambda-certs-function" {
  filename         = "nifi-lambda-certs.zip"
  source_code_hash = filebase64sha256("nifi-lambda-certs.zip")
  function_name    = "${var.name_prefix}-lambda-certs-${random_string.tf-nifi-random.result}"
  role             = aws_iam_role.tf-nifi-iam-role-lambda-certs.arn
  kms_key_arn      = aws_kms_key.tf-nifi-kmscmk-lambda.arn
  memory_size      = 256
  handler          = "nifi-lambda-certs.lambda_handler"
  runtime          = "python3.8"
  timeout          = 900
  environment {
    variables = {
      BUCKET = aws_s3_bucket.tf-nifi-bucket.id
      KEY    = aws_kms_key.tf-nifi-kmscmk-s3.arn
      PREFIX = var.name_prefix
      SUFFIX = random_string.tf-nifi-random.result
      REGION = var.aws_region
    }
  }
  depends_on = [aws_cloudwatch_log_group.tf-nifi-cloudwatch-log-group-lambda-certs]
}

data "aws_lambda_invocation" "tf-nifi-lambda-certs-invoke" {
  function_name = aws_lambda_function.tf-nifi-lambda-certs-function.function_name
  input         = <<JSON
{
  "terraform": "terraform"
}
JSON
}

