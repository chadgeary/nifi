# zookeepers
resource "aws_ssm_association" "tf-nifi-zookeepers-ssm-assoc" {
  association_name        = "tf-nifi-zookeepers"
  name                    = "AWS-ApplyAnsiblePlaybooks"
  targets {
    key                   = "tag:Name"
    values                = ["tf-nifi-1","tf-nifi-2","tf-nifi-3"]
  }
  output_location {
    s3_bucket_name          = aws_s3_bucket.tf-nifi-bucket.id
    s3_key_prefix           = "ssm"
  }
  parameters              = {
    Check                   = "False"
    ExtraVariables          = "SSM=True zk_version=${var.zk_version} nifi_version=${var.nifi_version} mirror_host=${var.mirror_host} node1_ip=${var.node1_ip} node2_ip=${var.node2_ip} node3_ip=${var.node3_ip} efs_source=${aws_efs_file_system.tf-nifi-efs.id}.efs.${var.aws_region}.amazonaws.com elb_dns=${aws_elb.tf-nifi-elb1.dns_name} s3_bucket=${aws_s3_bucket.tf-nifi-bucket.id}"
    InstallDependencies     = "True"
    PlaybookFile            = "zookeepers.yml"
    SourceInfo              = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.tf-nifi-bucket.id}/nifi/zookeepers/\"}"
    SourceType              = "S3"
    Verbose                 = "-v"
  }
}

# nodes
# zookeepers
resource "aws_ssm_association" "tf-nifi-nodes-ssm-assoc" {
  association_name        = "tf-nifi-nodes"
  name                    = "AWS-ApplyAnsiblePlaybooks"
  targets {
    key                   = "tag:Nifi"
    values                = ["node"]
  }
  output_location {
    s3_bucket_name          = aws_s3_bucket.tf-nifi-bucket.id
    s3_key_prefix           = "ssm"
  }
  parameters              = {
    Check                   = "False"
    ExtraVariables          = "SSM=True nifi_version=${var.nifi_version} mirror_host=${var.mirror_host} node1_ip=${var.node1_ip} node2_ip=${var.node2_ip} node3_ip=${var.node3_ip} efs_source=${aws_efs_file_system.tf-nifi-efs.id}.efs.${var.aws_region}.amazonaws.com elb_dns=${aws_elb.tf-nifi-elb1.dns_name} s3_bucket=${aws_s3_bucket.tf-nifi-bucket.id}"
    InstallDependencies     = "True"
    PlaybookFile            = "nodes.yml"
    SourceInfo              = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.tf-nifi-bucket.id}/nifi/nodes/\"}"
    SourceType              = "S3"
    Verbose                 = "-v"
  }
}
