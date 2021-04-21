# lambda function source code
data "archive_file" "tf-nifi-lambda-file-node-down" {
  type                    = "zip"
  source_file             = "nifi-lambda-nodedown.js"
  output_path             = "nifi-lambda-nodedown.zip"
}

# lambda function conf
resource "aws_lambda_function" "tf-nifi-lambda-node-down" {
  filename                = "nifi-lambda-nodedown.zip"
  source_code_hash        = data.archive_file.tf-nifi-lambda-file-node-down.output_base64sha256
  function_name           = "${var.name_prefix}-lambda-nodedown-${random_string.tf-nifi-random.result}"
  role                    = aws_iam_role.tf-nifi-lambda-iam-role.arn
  kms_key_arn             = aws_kms_key.tf-nifi-kmscmk-lambda.arn
  handler                 = "nifi-lambda-nodedown.handler"
  runtime                 = "nodejs12.x"
  timeout                 = 120
  environment {
    variables               = {
      SNSTARGET               = aws_sns_topic.tf-nifi-sns-node-down.arn
      SSMDOCUMENTNAME         = aws_ssm_document.tf-nifi-ssmdoc-node-down.name
    }
  }
}

# allow sns to call lambda
resource "aws_lambda_permission" "tf-nifi-lambda-permission-node-down" {
  statement_id            = "AllowExecutionFromSNS"
  action                  = "lambda:InvokeFunction"
  function_name           = aws_lambda_function.tf-nifi-lambda-node-down.function_name
  principal               = "sns.amazonaws.com"
  source_arn              = aws_sns_topic.tf-nifi-sns-node-down.arn
}
