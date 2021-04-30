output "tf-nifi-output" {
  value = <<OUTPUT

# NiFi can take 30+ minutes to initialize a cluster, please be patient.
# The AWS State Manager will show Status: Complete, then
# The AWS Load Balancer Instances will show Status: InService

# Admin Certificate + Secret
https://s3.console.aws.amazon.com/s3/object/${aws_s3_bucket.tf-nifi-bucket.id}?region=${var.aws_region}&prefix=nifi/certificates/admin/keystore.p12
https://s3.console.aws.amazon.com/s3/object/${aws_s3_bucket.tf-nifi-bucket.id}?region=${var.aws_region}&prefix=nifi/conf/generated_password

# WebUI NLB
https://${aws_lb.tf-nifi-mgmt-nlb.dns_name}:${var.web_port}/nifi

# Service NLB
${aws_lb.tf-nifi-service-nlb.dns_name}

OUTPUT
}
