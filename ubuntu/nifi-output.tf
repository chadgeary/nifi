output "tf-nifi-output" {
  value = <<OUTPUT

# NiFi can take 15+ minutes to initialize a cluster, please be patient.
# The AWS State Manager will show Status: Complete, then
# The mgmt Load Balancer Target Group will show Status: healthy

# Admin Certificate + Secret
https://s3.console.aws.amazon.com/s3/object/${aws_s3_bucket.tf-nifi-bucket.id}?region=${var.aws_region}&prefix=nifi/certificates/admin/keystore.p12
https://s3.console.aws.amazon.com/s3/object/${aws_s3_bucket.tf-nifi-bucket.id}?region=${var.aws_region}&prefix=nifi/conf/generated_password

# Cloudwatch Logs (NiFi & System)
https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${var.name_prefix}_${random_string.tf-nifi-random.result}

# Mgmt Target Group
https://console.aws.amazon.com/ec2/v2/home?region=${var.aws_region}#TargetGroup:targetGroupArn=${aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn}

# WebUI NLB
https://${aws_lb.tf-nifi-mgmt-nlb.dns_name}:${var.web_port}/nifi

# Service NLB
${aws_lb.tf-nifi-service-nlb.dns_name}

OUTPUT
}
