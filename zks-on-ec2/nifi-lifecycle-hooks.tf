# lifecycle hooks when scaling down to terminate an instance
resource "aws_autoscaling_lifecycle_hook" "tf-nifi-lch-zk1-scaledown" {
  name                    = "${var.name_prefix}-lch-zk1-scaledown-${random_string.tf-nifi-random.result}"
  autoscaling_group_name  = aws_autoscaling_group.tf-nifi-zk1-autoscalegroup.name
  default_result          = "ABANDON"
  heartbeat_timeout       = 3600
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = aws_sns_topic.tf-nifi-sns-scaledown.arn
  role_arn                = aws_iam_role.tf-nifi-autoscale-snsrole.arn
}

resource "aws_autoscaling_lifecycle_hook" "tf-nifi-lch-zk2-scaledown" {
  name                    = "${var.name_prefix}-lch-zk2-scaledown-${random_string.tf-nifi-random.result}"
  autoscaling_group_name  = aws_autoscaling_group.tf-nifi-zk2-autoscalegroup.name
  default_result          = "ABANDON"
  heartbeat_timeout       = 3600
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = aws_sns_topic.tf-nifi-sns-scaledown.arn
  role_arn                = aws_iam_role.tf-nifi-autoscale-snsrole.arn
}

resource "aws_autoscaling_lifecycle_hook" "tf-nifi-lch-zk3-scaledown" {
  name                    = "${var.name_prefix}-lch-zk3-scaledown-${random_string.tf-nifi-random.result}"
  autoscaling_group_name  = aws_autoscaling_group.tf-nifi-zk3-autoscalegroup.name
  default_result          = "ABANDON"
  heartbeat_timeout       = 3600
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = aws_sns_topic.tf-nifi-sns-scaledown.arn
  role_arn                = aws_iam_role.tf-nifi-autoscale-snsrole.arn
}

resource "aws_autoscaling_lifecycle_hook" "tf-nifi-lch-node-scaledown" {
  name                    = "${var.name_prefix}-lch-node-scaledown-${random_string.tf-nifi-random.result}"
  autoscaling_group_name  = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  default_result          = "ABANDON"
  heartbeat_timeout       = 3600
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = aws_sns_topic.tf-nifi-sns-scaledown.arn
  role_arn                = aws_iam_role.tf-nifi-autoscale-snsrole.arn
}
