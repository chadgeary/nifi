output "tf-nifi-output" {
  value = <<OUTPUT

# NiFi can take 15+ minutes to initialize a cluster, please be patient.
# State Manager Association will show Status: Complete, then
# NLB Target Group will show Status: healthy

# State Manager Association (Zookeepers)
https://console.aws.amazon.com/systems-manager/state-manager/${aws_ssm_association.tf-nifi-zookeepers-ssm-assoc.association_id}/executionhistory

# NLB Target Group (Zookeepers)
https://console.aws.amazon.com/ec2/v2/home?region=${var.aws_region}#TargetGroup:targetGroupArn=${aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn}

# Cloudwatch Logs
https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${var.name_prefix}_${random_string.tf-nifi-random.result}

# Admin Certificate + Secret
https://s3.console.aws.amazon.com/s3/object/${aws_s3_bucket.tf-nifi-bucket.id}?region=${var.aws_region}&prefix=nifi/certificates/admin/keystore.p12
https://s3.console.aws.amazon.com/s3/object/${aws_s3_bucket.tf-nifi-bucket.id}?region=${var.aws_region}&prefix=nifi/conf/generated_password

# NLB WebUI
https://${aws_lb.tf-nifi-zk-nlb.dns_name}:${var.web_port}/nifi

# NLB Service Ports
${aws_lb.tf-nifi-node-nlb.dns_name}

# Instance IDs in Cluster
aws ec2 describe-instances --query 'Reservations[].Instances[*].[InstanceId, LaunchTime, [Tags[?Key==`Name`].Value][0][0]]' --filters "Name=tag:Cluster,Values=${var.name_prefix}_${random_string.tf-nifi-random.result}" --region ${var.aws_region} --output text

OUTPUT
}
