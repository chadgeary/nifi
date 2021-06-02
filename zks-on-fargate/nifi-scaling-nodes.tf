# tags for the node asg
locals {
  node-asg-tags = [
    {
      key                 = "Name"
      value               = "node.${var.name_prefix}${random_string.tf-nifi-random.result}.internal"
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "${var.name_prefix}_${random_string.tf-nifi-random.result}"
      propagate_at_launch = true
    }
  ]
}

# launch conf
resource "aws_launch_configuration" "tf-nifi-launchconf" {
  name_prefix          = "${var.name_prefix}-lconf-${random_string.tf-nifi-random.result}-"
  image_id             = aws_ami_copy.tf-nifi-encrypted-ami.id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.tf-nifi-instance-key.key_name
  iam_instance_profile = aws_iam_instance_profile.tf-nifi-instance-profile.name
  security_groups      = [aws_security_group.tf-nifi-prisg.id]
  root_block_device {
    volume_size = var.instance_vol_size
    volume_type = "standard"
    encrypted   = "true"
  }
  lifecycle {
    create_before_destroy = true
  }
  user_data = <<EOF
#!/bin/bash
# set fqdn 
hostnamectl set-hostname $(hostname).${var.name_prefix}${random_string.tf-nifi-random.result}.internal
EOF
}

# autoscaling group
resource "aws_autoscaling_group" "tf-nifi-autoscalegroup" {
  name_prefix               = "${var.name_prefix}-asg-${random_string.tf-nifi-random.result}-"
  launch_configuration      = aws_launch_configuration.tf-nifi-launchconf.name
  target_group_arns         = concat([aws_lb_target_group.tf-nifi-service-target-web.arn], aws_lb_target_group.tf-nifi-service-target-tcp[*].arn, aws_lb_target_group.tf-nifi-service-target-udp[*].arn, aws_lb_target_group.tf-nifi-service-target-tcpudp[*].arn)
  vpc_zone_identifier       = [aws_subnet.tf-nifi-prinet1.id, aws_subnet.tf-nifi-prinet2.id, aws_subnet.tf-nifi-prinet3.id]
  service_linked_role_arn   = aws_iam_service_linked_role.tf-nifi-autoscale-slr.arn
  termination_policies      = ["ClosestToNextInstanceHour"]
  min_size                  = var.minimum_node_count
  max_size                  = var.maximum_node_count
  health_check_type         = "EC2"
  health_check_grace_period = 1800
  lifecycle {
    create_before_destroy = true
  }
  dynamic "tag" {
    for_each = local.node-asg-tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
  depends_on = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssmparameter, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3, aws_cloudwatch_log_group.tf-nifi-cloudwatch-log-group-ec2]
}

# scale up policy and metric alarm
resource "aws_autoscaling_policy" "tf-nifi-autoscalepolicy-up" {
  name                   = "${var.name_prefix}-asp-up-${random_string.tf-nifi-random.result}"
  autoscaling_group_name = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "600"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "tf-nifi-cpu-metric-alarm-up" {
  alarm_name          = "${var.name_prefix}-metric-up-${random_string.tf-nifi-random.result}"
  alarm_description   = "Alarm for NiFi autoscaling group high CPU utilization average."
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  threshold           = "75"
  evaluation_periods  = "10"
  period              = "60"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.tf-nifi-autoscalepolicy-up.arn]
  depends_on      = [aws_codebuild_project.zk-codebuild]
}

# scale down policy and metric alarm
resource "aws_autoscaling_policy" "tf-nifi-autoscalepolicy-down" {
  name                   = "${var.name_prefix}-asp-down-${random_string.tf-nifi-random.result}"
  autoscaling_group_name = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "600"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "tf-nifi-cpu-metric-alarm-down" {
  alarm_name          = "${var.name_prefix}-metric-down-${random_string.tf-nifi-random.result}"
  alarm_description   = "Alarm for NiFi autoscaling group low CPU utilization average."
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  statistic           = "Average"
  threshold           = "25"
  evaluation_periods  = "10"
  period              = "60"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.tf-nifi-autoscalepolicy-down.arn]
}
