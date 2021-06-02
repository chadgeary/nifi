data "archive_file" "tf-nifi-lambda-getnifi-archive" {
  type        = "zip"
  source_file = "nifi-lambda-getnifi.py"
  output_path = "nifi-lambda-getnifi.zip"
}

resource "aws_lambda_function" "tf-nifi-lambda-getnifi-function" {
  filename         = "nifi-lambda-getnifi.zip"
  source_code_hash = data.archive_file.tf-nifi-lambda-getnifi-archive.output_base64sha256
  function_name    = "${var.name_prefix}-lambda-getnifi-${random_string.tf-nifi-random.result}"
  role             = aws_iam_role.tf-nifi-iam-role-lambda-getnifi.arn
  kms_key_arn      = aws_kms_key.tf-nifi-kmscmk-lambda.arn
  memory_size      = 256
  handler          = "nifi-lambda-getnifi.lambda_handler"
  runtime          = "python3.8"
  timeout          = 900
  environment {
    variables = {
      NIFIURL    = var.nifi_url
      TOOLKITURL = var.toolkit_url
      BUCKET     = aws_s3_bucket.tf-nifi-bucket.id
      REGION     = var.aws_region
      KEY        = aws_kms_key.tf-nifi-kmscmk-s3.arn
    }
  }
  depends_on = [aws_cloudwatch_log_group.tf-nifi-cloudwatch-log-group-lambda-getnifi]
}

data "aws_lambda_invocation" "tf-nifi-lambda-getnifi-invoke" {
  function_name = aws_lambda_function.tf-nifi-lambda-getnifi-function.function_name
  input         = <<JSON
{
  "terraform": "terraform"
}
JSON
}
