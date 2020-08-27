# zookeepers
resource "aws_ssm_association" "tf-nifi-zookeepers-ssm-assoc" {
  association_name        = "tf-nifi-zookeepers"
  name                    = "AWS-ApplyAnsiblePlaybooks"
  targets {
    key                   = "tag:NiFi"
    values                = ["zookeeper"]
  }
  output_location {
    s3_bucket_name          = aws_s3_bucket.tf-nifi-bucket.id
    s3_key_prefix           = "ssm"
  }
  parameters              = {
    Check                   = "False"
    ExtraVariables          = "SSM=True zk_version=${var.zk_version} nifi_version=${var.nifi_version} mirror_host=${var.mirror_host} node1_ip=${var.node1_ip} node2_ip=${var.node2_ip} node3_ip=${var.node3_ip} elb_dns=${aws_elb.tf-nifi-elb.dns_name} s3_bucket=${aws_s3_bucket.tf-nifi-bucket.id} kms_key_id=${aws_kms_key.tf-nifi-kmscmk-s3.key_id} ec2_name_prefix=${var.ec2_name_prefix}"
    InstallDependencies     = "True"
    PlaybookFile            = "zookeepers.yml"
    SourceInfo              = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.tf-nifi-bucket.id}/nifi/zookeepers/\"}"
    SourceType              = "S3"
    Verbose                 = "-v"
  }
  depends_on              = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3,aws_s3_bucket_object.tf-nifi-zookeepers-files]
}

# nodes
# zookeepers
resource "aws_ssm_association" "tf-nifi-nodes-ssm-assoc" {
  association_name        = "tf-nifi-nodes"
  name                    = "AWS-ApplyAnsiblePlaybooks"
  targets {
    key                   = "tag:NiFi"
    values                = ["node"]
  }
  output_location {
    s3_bucket_name          = aws_s3_bucket.tf-nifi-bucket.id
    s3_key_prefix           = "ssm"
  }
  parameters              = {
    Check                   = "False"
    ExtraVariables          = "SSM=True nifi_version=${var.nifi_version} mirror_host=${var.mirror_host} node1_ip=${var.node1_ip} node2_ip=${var.node2_ip} node3_ip=${var.node3_ip} elb_dns=${aws_elb.tf-nifi-elb.dns_name} s3_bucket=${aws_s3_bucket.tf-nifi-bucket.id} kms_key_id=${aws_kms_key.tf-nifi-kmscmk-s3.key_id} ec2_name_prefix=${var.ec2_name_prefix}"
    InstallDependencies     = "True"
    PlaybookFile            = "nodes.yml"
    SourceInfo              = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.tf-nifi-bucket.id}/nifi/nodes/\"}"
    SourceType              = "S3"
    Verbose                 = "-v"
  }
  depends_on              = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3,aws_s3_bucket_object.tf-nifi-nodes-files]
}
