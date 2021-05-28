resource "aws_route53_zone" "tf-nifi-r53-zone" {
  name = "${var.name_prefix}${random_string.tf-nifi-random.result}.internal"
  vpc {
    vpc_id = aws_vpc.tf-nifi-vpc.id
  }
  force_destroy = true
}
