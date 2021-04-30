# zk1 launchconf and asg
resource "aws_launch_configuration" "tf-nifi-zk1-launchconf" {
  name_prefix             = "${var.name_prefix}-zk1lconf-${random_string.tf-nifi-random.result}-"
  image_id                = aws_ami_from_instance.tf-nifi-encrypted-ami.id
  instance_type           = var.instance_type
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  security_groups         = [aws_security_group.tf-nifi-prisg.id]
  root_block_device {
    volume_size             = var.instance_vol_size
    volume_type             = "standard"
    encrypted               = "true"
  }
  lifecycle {
    create_before_destroy   = true
  }
  user_data               = <<EOF
#!/bin/bash
# set hostname
hostnamectl set-hostname ${var.name_prefix}-zk1-${random_string.tf-nifi-random.result}
# set nodeid
echo 1 > /opt/node_id
# install ssm
yum install -y https://s3.${var.aws_region}.amazonaws.com/amazon-ssm-${var.aws_region}/latest/linux_amd64/amazon-ssm-agent.rpm
# start/enable ssm
sytemctl start amazon-ssm-agent && systemctl enable amazon-ssm-agent
EOF
}

resource "aws_autoscaling_group" "tf-nifi-zk1-autoscalegroup" {
  name_prefix             = "${var.name_prefix}-zk1asg-${random_string.tf-nifi-random.result}-"
  launch_configuration    = aws_launch_configuration.tf-nifi-zk1-launchconf.name
  target_group_arns       = concat(aws_lb_target_group.tf-nifi-service-target-tcp[*].arn,aws_lb_target_group.tf-nifi-service-target-udp[*].arn,aws_lb_target_group.tf-nifi-service-target-tcpudp[*].arn,[aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn])
  vpc_zone_identifier     = [aws_subnet.tf-nifi-prinet1.id]
  service_linked_role_arn = aws_iam_service_linked_role.tf-nifi-autoscale-slr.arn
  termination_policies    = ["ClosestToNextInstanceHour"]
  min_size                = 1
  max_size                = 1
  lifecycle {
    create_before_destroy   = true
  }
  tags =                  concat(
    [
      {
        key                     = "Name"
        value                   = "${var.name_prefix}-zk1-${random_string.tf-nifi-random.result}"
        propagate_at_launch     = true
      }
    ]
  )
  depends_on              = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3, aws_iam_policy.tf-nifi-instance-policy-route53]
}

# zk2 launchconf and asg
resource "aws_launch_configuration" "tf-nifi-zk2-launchconf" {
  name_prefix             = "${var.name_prefix}-zk2lconf-${random_string.tf-nifi-random.result}-"
  image_id                = aws_ami_from_instance.tf-nifi-encrypted-ami.id
  instance_type           = var.instance_type
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  security_groups         = [aws_security_group.tf-nifi-prisg.id]
  root_block_device {
    volume_size             = var.instance_vol_size
    volume_type             = "standard"
    encrypted               = "true"
  }
  lifecycle {
    create_before_destroy   = true
  }
  user_data               = <<EOF
#!/bin/bash
# set hostname
hostnamectl set-hostname ${var.name_prefix}-zk2-${random_string.tf-nifi-random.result}
# set nodeid
echo 2 > /opt/node_id
# install ssm
yum install -y https://s3.${var.aws_region}.amazonaws.com/amazon-ssm-${var.aws_region}/latest/linux_amd64/amazon-ssm-agent.rpm
# start/enable ssm
sytemctl start amazon-ssm-agent && systemctl enable amazon-ssm-agent
EOF
}

resource "aws_autoscaling_group" "tf-nifi-zk2-autoscalegroup" {
  name_prefix             = "${var.name_prefix}-zk2asg-${random_string.tf-nifi-random.result}-"
  launch_configuration    = aws_launch_configuration.tf-nifi-zk2-launchconf.name
  target_group_arns       = concat(aws_lb_target_group.tf-nifi-service-target-tcp[*].arn,aws_lb_target_group.tf-nifi-service-target-udp[*].arn,aws_lb_target_group.tf-nifi-service-target-tcpudp[*].arn,[aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn])
  vpc_zone_identifier     = [aws_subnet.tf-nifi-prinet2.id]
  service_linked_role_arn = aws_iam_service_linked_role.tf-nifi-autoscale-slr.arn
  termination_policies    = ["ClosestToNextInstanceHour"]
  min_size                = 1
  max_size                = 1
  lifecycle {
    create_before_destroy   = true
  }
  tags =                  concat(
    [
      {
        key                     = "Name"
        value                   = "${var.name_prefix}-zk2-${random_string.tf-nifi-random.result}"
        propagate_at_launch     = true
      }
    ]
  )
  depends_on              = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3, aws_iam_policy.tf-nifi-instance-policy-route53]
}

# zk3 launchconf and asg
resource "aws_launch_configuration" "tf-nifi-zk3-launchconf" {
  name_prefix             = "${var.name_prefix}-zk3lconf-${random_string.tf-nifi-random.result}-"
  image_id                = aws_ami_from_instance.tf-nifi-encrypted-ami.id
  instance_type           = var.instance_type
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  security_groups         = [aws_security_group.tf-nifi-prisg.id]
  root_block_device {
    volume_size             = var.instance_vol_size
    volume_type             = "standard"
    encrypted               = "true"
  }
  lifecycle {
    create_before_destroy   = true
  }
  user_data               = <<EOF
#!/bin/bash
# set hostname
hostnamectl set-hostname ${var.name_prefix}-zk3-${random_string.tf-nifi-random.result}
# set nodeid
echo 3 > /opt/node_id
# install ssm
yum install -y https://s3.${var.aws_region}.amazonaws.com/amazon-ssm-${var.aws_region}/latest/linux_amd64/amazon-ssm-agent.rpm
# start/enable ssm
sytemctl start amazon-ssm-agent && systemctl enable amazon-ssm-agent
EOF
}

resource "aws_autoscaling_group" "tf-nifi-zk3-autoscalegroup" {
  name_prefix             = "${var.name_prefix}-zk3asg-${random_string.tf-nifi-random.result}-"
  launch_configuration    = aws_launch_configuration.tf-nifi-zk3-launchconf.name
  target_group_arns       = concat(aws_lb_target_group.tf-nifi-service-target-tcp[*].arn,aws_lb_target_group.tf-nifi-service-target-udp[*].arn,aws_lb_target_group.tf-nifi-service-target-tcpudp[*].arn,[aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn])
  vpc_zone_identifier     = [aws_subnet.tf-nifi-prinet3.id]
  service_linked_role_arn = aws_iam_service_linked_role.tf-nifi-autoscale-slr.arn
  termination_policies    = ["ClosestToNextInstanceHour"]
  min_size                = 1
  max_size                = 1
  lifecycle {
    create_before_destroy   = true
  }
  tags =                  concat(
    [
      {
        key                     = "Name"
        value                   = "${var.name_prefix}-zk3-${random_string.tf-nifi-random.result}"
        propagate_at_launch     = true
      }
    ]
  )
  depends_on              = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3, aws_iam_policy.tf-nifi-instance-policy-route53]
}
