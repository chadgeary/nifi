# tags for the zk asgs
locals {
  zk1-asg-tags = [
    {
      key                 = "Name"
      value               = "zk1.${var.name_prefix}${random_string.tf-nifi-random.result}.internal"
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "${var.name_prefix}_${random_string.tf-nifi-random.result}"
      propagate_at_launch = true
    }
  ]
  zk2-asg-tags = [
    {
      key                 = "Name"
      value               = "zk2.${var.name_prefix}${random_string.tf-nifi-random.result}.internal"
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "${var.name_prefix}_${random_string.tf-nifi-random.result}"
      propagate_at_launch = true
    }
  ]
  zk3-asg-tags = [
    {
      key                 = "Name"
      value               = "zk3.${var.name_prefix}${random_string.tf-nifi-random.result}.internal"
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "${var.name_prefix}_${random_string.tf-nifi-random.result}"
      propagate_at_launch = true
    }
  ]
}

# zk1 launchconf and asg
resource "aws_launch_configuration" "tf-nifi-zk1-launchconf" {
  name_prefix          = "${var.name_prefix}-zk1lconf-${random_string.tf-nifi-random.result}-"
  image_id             = data.aws_ami.tf-nifi-vendor-ami-latest.id
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
    ignore_changes = [
      image_id
    ]
  }
  user_data = <<EOF
#!/bin/bash
# set hostname
hostnamectl set-hostname zk1.${var.name_prefix}${random_string.tf-nifi-random.result}.internal
# set nodeid
echo 1 > /opt/node_id
EOF
}

resource "aws_autoscaling_group" "tf-nifi-zk1-autoscalegroup" {
  name_prefix               = "${var.name_prefix}-zk1asg-${random_string.tf-nifi-random.result}-"
  launch_configuration      = aws_launch_configuration.tf-nifi-zk1-launchconf.name
  target_group_arns         = concat(aws_lb_target_group.tf-nifi-service-target-tcp[*].arn, aws_lb_target_group.tf-nifi-service-target-udp[*].arn, aws_lb_target_group.tf-nifi-service-target-tcpudp[*].arn, [aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn, aws_lb_target_group.tf-nifi-zk-target-tcp.arn])
  vpc_zone_identifier       = [aws_subnet.tf-nifi-prinet1.id, aws_subnet.tf-nifi-prinet2.id]
  service_linked_role_arn   = aws_iam_service_linked_role.tf-nifi-autoscale-slr.arn
  termination_policies      = ["ClosestToNextInstanceHour"]
  min_size                  = var.enable_zk1
  max_size                  = var.enable_zk1
  health_check_type         = "EC2"
  health_check_grace_period = 1800
  lifecycle {
    create_before_destroy = true
  }
  dynamic "tag" {
    for_each = local.zk1-asg-tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
  depends_on = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3, aws_iam_policy.tf-nifi-instance-policy-route53, aws_cloudwatch_log_group.tf-nifi-cloudwatch-log-group-ec2]
}

# zk2 launchconf and asg
resource "aws_launch_configuration" "tf-nifi-zk2-launchconf" {
  name_prefix          = "${var.name_prefix}-zk2lconf-${random_string.tf-nifi-random.result}-"
  image_id             = data.aws_ami.tf-nifi-vendor-ami-latest.id
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
    ignore_changes = [
      image_id
    ]
  }
  user_data = <<EOF
#!/bin/bash
# set hostname
hostnamectl set-hostname zk2.${var.name_prefix}${random_string.tf-nifi-random.result}.internal
# set nodeid
echo 2 > /opt/node_id
EOF
}

resource "aws_autoscaling_group" "tf-nifi-zk2-autoscalegroup" {
  name_prefix               = "${var.name_prefix}-zk2asg-${random_string.tf-nifi-random.result}-"
  launch_configuration      = aws_launch_configuration.tf-nifi-zk2-launchconf.name
  target_group_arns         = concat(aws_lb_target_group.tf-nifi-service-target-tcp[*].arn, aws_lb_target_group.tf-nifi-service-target-udp[*].arn, aws_lb_target_group.tf-nifi-service-target-tcpudp[*].arn, [aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn, aws_lb_target_group.tf-nifi-zk-target-tcp.arn])
  vpc_zone_identifier       = [aws_subnet.tf-nifi-prinet2.id, aws_subnet.tf-nifi-prinet3.id]
  service_linked_role_arn   = aws_iam_service_linked_role.tf-nifi-autoscale-slr.arn
  termination_policies      = ["ClosestToNextInstanceHour"]
  min_size                  = var.enable_zk2
  max_size                  = var.enable_zk2
  health_check_type         = "EC2"
  health_check_grace_period = 1800
  lifecycle {
    create_before_destroy = true
  }
  dynamic "tag" {
    for_each = local.zk2-asg-tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
  depends_on = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3, aws_iam_policy.tf-nifi-instance-policy-route53, aws_cloudwatch_log_group.tf-nifi-cloudwatch-log-group-ec2]
}

# zk3 launchconf and asg
resource "aws_launch_configuration" "tf-nifi-zk3-launchconf" {
  name_prefix          = "${var.name_prefix}-zk3lconf-${random_string.tf-nifi-random.result}-"
  image_id             = data.aws_ami.tf-nifi-vendor-ami-latest.id
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
    ignore_changes = [
      image_id
    ]
  }
  user_data = <<EOF
#!/bin/bash
# set hostname
hostnamectl set-hostname zk3.${var.name_prefix}${random_string.tf-nifi-random.result}.internal
# set nodeid
echo 3 > /opt/node_id
EOF
}

resource "aws_autoscaling_group" "tf-nifi-zk3-autoscalegroup" {
  name_prefix               = "${var.name_prefix}-zk3asg-${random_string.tf-nifi-random.result}-"
  launch_configuration      = aws_launch_configuration.tf-nifi-zk3-launchconf.name
  target_group_arns         = concat(aws_lb_target_group.tf-nifi-service-target-tcp[*].arn, aws_lb_target_group.tf-nifi-service-target-udp[*].arn, aws_lb_target_group.tf-nifi-service-target-tcpudp[*].arn, [aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn, aws_lb_target_group.tf-nifi-zk-target-tcp.arn])
  vpc_zone_identifier       = [aws_subnet.tf-nifi-prinet3.id, aws_subnet.tf-nifi-prinet1.id]
  service_linked_role_arn   = aws_iam_service_linked_role.tf-nifi-autoscale-slr.arn
  termination_policies      = ["ClosestToNextInstanceHour"]
  min_size                  = var.enable_zk3
  max_size                  = var.enable_zk3
  health_check_type         = "EC2"
  health_check_grace_period = 1800
  lifecycle {
    create_before_destroy = true
  }
  dynamic "tag" {
    for_each = local.zk3-asg-tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
  depends_on = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3, aws_iam_policy.tf-nifi-instance-policy-route53, aws_cloudwatch_log_group.tf-nifi-cloudwatch-log-group-ec2]
}
