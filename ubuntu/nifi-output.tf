output "tf-nifi-output" {
  value = <<OUTPUT

# NiFi can take 30+ minutes to initialize a cluster, please be patient.
# The AWS State Manager will show Status: Complete, then
# The AWS Load Balancer Instances will show Status: InService

# Admin Certificate + Secret
https://s3.console.aws.amazon.com/s3/object/${aws_s3_bucket.tf-nifi-bucket.id}?region=${var.aws_region}&prefix=nifi/certificates/admin/keystore.pkcs12
https://s3.console.aws.amazon.com/s3/object/${aws_s3_bucket.tf-nifi-bucket.id}?region=${var.aws_region}&prefix=nifi/conf/generated_password

# WebUI (ELB)
https://${aws_elb.tf-nifi-elb.dns_name}/nifi

# SSH (ELB)
ssh ec2-user@${aws_elb.tf-nifi-elb.dns_name}

OUTPUT
}
