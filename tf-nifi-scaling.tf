# launch conf
resource "aws_launch_configuration" "tf-nifi-launchconf" {
  name_prefix             = "tf-nifi-launchconf-"
  image_id                = aws_ami_from_instance.tf-nifi-ami.id
  instance_type           = var.instance_type
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  security_groups         = [aws_security_group.tf-nifi-prisg1.id]
  user_data               = file("userdata/tf-nifi-userdata-nodes.sh")
  root_block_device {
    encrypted               = "true"
  }
  lifecycle {
    create_before_destroy   = true
  }
  depends_on              = [aws_nat_gateway.tf-nifi-ng2,aws_ssm_association.tf-nifi-zookeepers-ssm-assoc,aws_efs_mount_target.tf-nifi-efs-mounttarget-2]
}

# autoscaling group
resource "aws_autoscaling_group" "tf-nifi-autoscalegroup" {
  name_prefix             = "tf-nifi-autoscalegroup-"
  launch_configuration    = aws_launch_configuration.tf-nifi-launchconf.name
  load_balancers          = [aws_elb.tf-nifi-elb1.name]
  vpc_zone_identifier     = [aws_subnet.tf-nifi-prinet1.id, aws_subnet.tf-nifi-prinet2.id, aws_subnet.tf-nifi-prinet3.id]
  service_linked_role_arn = aws_iam_service_linked_role.tf-nifi-autoscale-slr.arn
  desired_capacity        = var.desired_node_count
  min_size                = var.minimum_node_count
  max_size                = var.maximum_node_count
  lifecycle {
    create_before_destroy   = true
  }
  tags =                  concat(
    [
      {
        key                     = "Name"
        value                   = "tf-nifi-node"
        propagate_at_launch     = true
      },
      {
        key                     = "Nifi"
        value                   = "node"
        propagate_at_launch     = true
      }
    ]
  )
  depends_on              = [aws_instance.tf-nifi-1,aws_instance.tf-nifi-2,aws_instance.tf-nifi-3]
}
