resource "aws_cloudwatch_event_rule" "tf-nifi-cloudwatch-event-rule-health" {
  name                = "${var.name_prefix}-event-rule-health-${random_string.tf-nifi-random.result}"
  schedule_expression = "rate(${var.health_check_count} ${var.health_check_unit})"
  is_enabled          = var.health_check_enable
}

resource "aws_cloudwatch_event_target" "tf-nifi-cloudwatch-event-target-health" {
  arn  = aws_lambda_alias.tf-nifi-lambda-health-alias.arn
  rule = aws_cloudwatch_event_rule.tf-nifi-cloudwatch-event-rule-health.id
}
