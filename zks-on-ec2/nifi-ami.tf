# Vendor AMI
data "aws_ami" "tf-nifi-vendor-ami-latest" {
  most_recent = true
  owners      = [var.vendor_ami_account_number]
  filter {
    name   = "name"
    values = [var.vendor_ami_name_string]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["arm64", "x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
