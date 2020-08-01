# Instance Key
resource "aws_key_pair" "tf-nifi-instance-key" {
  key_name                = "tf-nifi-instance-key"
  public_key              = var.instance_key
  tags                    = {
    Name                    = "tf-nifi-instance-key"
  }
}

# Latest RHEL 7
data "aws_ami" "tf-nifi-latest-rhel-ami" {
  most_recent             = true
  owners                  = ["309956199498"]
  filter {
    name                    = "name"
    values                  = ["RHEL-7.*GA*"]
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

# Instance from Latest RHEL7 (Redhat doesnt allow AMI copies)
resource "aws_instance" "tf-nifi-latest" {
  ami                     = data.aws_ami.tf-nifi-latest-rhel-ami.id
  instance_type           = var.instance_type
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  subnet_id               = aws_subnet.tf-nifi-prinet1.id
  vpc_security_group_ids  = [aws_security_group.tf-nifi-prisg1.id]
  tags                    = {
    Name                    = "tf-nifi-latest-ami"
  }
  root_block_device {
    encrypted               = "true"
    kms_key_id              = aws_kms_key.tf-nifi-kmscmk.arn
  }
  user_data               = file("userdata/tf-nifi-userdata-latest-ami.sh")
}


# Create AMI from Latest instance (now encrypted)
resource "aws_ami_from_instance" "tf-nifi-ami" {
  name                    = "tf-nifi-rhel7"
  description             = "KMS CMK encrypted copy of RHEL7 official AMI (${data.aws_ami.tf-nifi-latest-rhel-ami.id})"
  source_instance_id      = aws_instance.tf-nifi-latest.id
  tags                    = {
    Name                    = "tf-nifi-ami"
  }
}

# Instance(s)
resource "aws_instance" "tf-nifi-1" {
  ami                     = aws_ami_from_instance.tf-nifi-ami.id
  instance_type           = var.instance_type
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  subnet_id               = aws_subnet.tf-nifi-prinet1.id
  private_ip              = var.node1_ip
  vpc_security_group_ids  = [aws_security_group.tf-nifi-prisg1.id]
  tags                    = {
    Name                    = "tf-nifi-1"
    Nifi                    = "zookeeper"
  }
  user_data               = file("userdata/tf-nifi-userdata-1.sh")
  depends_on              = [aws_nat_gateway.tf-nifi-ng1,aws_ssm_association.tf-nifi-zookeepers-ssm-assoc,aws_efs_mount_target.tf-nifi-efs-mounttarget-1]
}

resource "aws_instance" "tf-nifi-2" {
  ami                     = aws_ami_from_instance.tf-nifi-ami.id
  instance_type           = var.instance_type
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  subnet_id               = aws_subnet.tf-nifi-prinet2.id
  private_ip              = var.node2_ip
  vpc_security_group_ids  = [aws_security_group.tf-nifi-prisg1.id]
  tags                    = {
    Name                    = "tf-nifi-2"
    Nifi                    = "zookeeper"
  }
  user_data               = file("userdata/tf-nifi-userdata-2.sh")
  depends_on              = [aws_nat_gateway.tf-nifi-ng2,aws_ssm_association.tf-nifi-zookeepers-ssm-assoc,aws_efs_mount_target.tf-nifi-efs-mounttarget-2]
}

resource "aws_instance" "tf-nifi-3" {
  ami                     = aws_ami_from_instance.tf-nifi-ami.id
  instance_type           = var.instance_type
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  subnet_id               = aws_subnet.tf-nifi-prinet3.id
  private_ip              = var.node3_ip
  vpc_security_group_ids  = [aws_security_group.tf-nifi-prisg1.id]
  tags                    = {
    Name                    = "tf-nifi-3"
    Nifi                    = "zookeeper"
  }
  user_data               = file("userdata/tf-nifi-userdata-3.sh")
  depends_on              = [aws_nat_gateway.tf-nifi-ng3,aws_ssm_association.tf-nifi-zookeepers-ssm-assoc,aws_efs_mount_target.tf-nifi-efs-mounttarget-3]
}
