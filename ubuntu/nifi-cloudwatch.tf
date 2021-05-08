resource "aws_cloudwatch_log_group" "tf-nifi-cloudwatch-log-group" {
  name                    = "${var.name_prefix}_${random_string.tf-nifi-random.result}"
  retention_in_days       = var.log_retention_days
  kms_key_id              = aws_kms_key.tf-nifi-kmscmk-cloudwatch.arn
  tags                    = {
    Name                    = "${var.name_prefix}_${random_string.tf-nifi-random.result}"
  }
}
