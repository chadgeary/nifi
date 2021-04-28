# Vendor AMI
data "aws_ami" "tf-nifi-vendor-ami-latest" {
  most_recent             = true
  owners                  = [var.vendor_ami_account_number]
  filter {
    name                    = "name"
    values                  = [var.vendor_ami_name_string]
  }
  filter {
    name                    = "virtualization-type"
    values                  = ["hvm"]
  }
  filter {
    name                    = "architecture"
    values                  = ["x86_64"]
  }
  filter {
    name                    = "root-device-type"
    values                  = ["ebs"]
  }
}

# Create instance from AMI
resource "aws_instance" "tf-nifi-encrypted-instance" {
  ami                     = data.aws_ami.tf-nifi-vendor-ami-latest.id
  instance_type           = var.instance_type
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  subnet_id               = aws_subnet.tf-nifi-prinet1.id
  private_ip              = var.encrypted_ami_ip
  vpc_security_group_ids  = [aws_security_group.tf-nifi-prisg.id]
  tags                    = {
    Name                    = "${var.name_prefix}-encrypted-instance-${random_string.tf-nifi-random.result}"
    NiFi                    = "none"
  }
  user_data               = <<EOF
#!/bin/bash
init 0
EOF
  root_block_device {
    volume_size             = var.instance_vol_size
    volume_type             = "standard"
    encrypted               = "true"
    kms_key_id              = aws_kms_key.tf-nifi-kmscmk-ec2.arn
  }
}

resource "time_sleep" "wait_for_ami_instance" {
  create_duration         = "120s"
  depends_on              = [aws_instance.tf-nifi-encrypted-instance]
}

# Create AMI with KMS CMK from encrypted instance
resource "aws_ami_from_instance" "tf-nifi-encrypted-ami" {
  name                    = "${var.name_prefix}-encrypted-ami-${random_string.tf-nifi-random.result}"
  description             = "KMS CMK-encrypted AMI of latest official vendor AMI"
  source_instance_id      = aws_instance.tf-nifi-encrypted-instance.id
  tags                    = {
    Name                    = "${var.name_prefix}-encrypted-ami-${random_string.tf-nifi-random.result}"
  }
  depends_on              = [time_sleep.wait_for_ami_instance]
}
