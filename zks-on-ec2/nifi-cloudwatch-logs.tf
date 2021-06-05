resource "aws_cloudwatch_log_group" "tf-nifi-cloudwatch-log-group-ec2" {
  name              = "/aws/ec2/${var.name_prefix}_${random_string.tf-nifi-random.result}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.tf-nifi-kmscmk-cloudwatch.arn
  tags = {
    Name = "/aws/ec2/${var.name_prefix}_${random_string.tf-nifi-random.result}"
  }
}

resource "aws_cloudwatch_log_group" "tf-nifi-cloudwatch-log-group-lambda-certs" {
  name              = "/aws/lambda/${var.name_prefix}-lambda-certs-${random_string.tf-nifi-random.result}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.tf-nifi-kmscmk-cloudwatch.arn
  tags = {
    Name = "/aws/lambda/${var.name_prefix}-lambda-certs-${random_string.tf-nifi-random.result}"
  }
}

resource "aws_cloudwatch_log_group" "tf-nifi-cloudwatch-log-group-lambda-getnifi" {
  name              = "/aws/lambda/${var.name_prefix}-lambda-getnifi-${random_string.tf-nifi-random.result}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.tf-nifi-kmscmk-cloudwatch.arn
  tags = {
    Name = "/aws/lambda/${var.name_prefix}-lambda-getnifi-${random_string.tf-nifi-random.result}"
  }
}

resource "aws_cloudwatch_log_group" "tf-nifi-cloudwatch-log-group-lambda-health" {
  name              = "/aws/lambda/${var.name_prefix}-lambda-health-${random_string.tf-nifi-random.result}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.tf-nifi-kmscmk-cloudwatch.arn
  tags = {
    Name = "/aws/lambda/${var.name_prefix}-lambda-health-${random_string.tf-nifi-random.result}"
  }
}

resource "aws_cloudwatch_log_group" "tf-nifi-cloudwatch-log-group-lambda-scaledown" {
  name              = "/aws/lambda/${var.name_prefix}-lambda-scaledown-${random_string.tf-nifi-random.result}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.tf-nifi-kmscmk-cloudwatch.arn
  tags = {
    Name = "/aws/lambda/${var.name_prefix}-lambda-scaledown-${random_string.tf-nifi-random.result}"
  }
}
