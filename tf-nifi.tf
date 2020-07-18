variable "aws_region" {
  type                     = string
}

variable "aws_profile" {
  type                     = string
}

variable "vpc_cidr" {
  type                     = string
  default                  = "10.90.0.0/16"
}

variable "pubnet1_cidr" {
  type                     = string
  default                  = "10.90.1.0/24"
}

variable "prinet1_cidr" {
  type                     = string
  default                  = "10.90.2.0/24"
}

variable "pubnet2_cidr" {
  type                     = string
  default                  = "10.90.3.0/24"
}

variable "prinet2_cidr" {
  type                     = string
  default                  = "10.90.4.0/24"
}

variable "pubnet3_cidr" {
  type                     = string
  default                  = "10.90.5.0/24"
}

variable "prinet3_cidr" {
  type                     = string
  default                  = "10.90.6.0/24"
}

variable "instance_key" {
  type                     = string
}

provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_profile
}

# availability zones - assumes at least 3 are available
data "aws_availability_zones" "tf-nifi-azs" {
  state                    = "available"
}

# vpc and gateway
resource "aws_vpc" "tf-nifi-vpc" {
  cidr_block              = var.vpc_cidr
  tags                    = {
    Name                  = "tf-nifi-vpc"
  }
}

resource "aws_internet_gateway" "tf-nifi-gw" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  tags                    = {
    Name                  = "tf-nifi-gw"
  }
}

# route tables
resource "aws_route_table" "tf-nifi-pubrt" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  route {
    cidr_block              = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.tf-nifi-gw.id
  }
  tags                    = {
    Name                  = "tf-nifi-pubrt"
  }
}

resource "aws_route_table" "tf-nifi-prirt1" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  tags                    = {
    Name                  = "tf-nifi-prirt1"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-nifi-ng1.id
  }
}

resource "aws_route_table" "tf-nifi-prirt2" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  tags                    = {
    Name                  = "tf-nifi-prirt2"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-nifi-ng2.id
  }
}

resource "aws_route_table" "tf-nifi-prirt3" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  tags                    = {
    Name                  = "tf-nifi-prirt3"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-nifi-ng3.id
  }
}

# public subnets
resource "aws_subnet" "tf-nifi-pubnet1" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  availability_zone       = data.aws_availability_zones.tf-nifi-azs.names[0]
  cidr_block              = var.pubnet1_cidr
  tags                    = {
    Name                  = "tf-nifi-pubnet1"
  }
}

resource "aws_subnet" "tf-nifi-pubnet2" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  availability_zone       = data.aws_availability_zones.tf-nifi-azs.names[1]
  cidr_block              = var.pubnet2_cidr
  tags                    = {
    Name                  = "tf-nifi-pubnet2"
  }
}

resource "aws_subnet" "tf-nifi-pubnet3" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  availability_zone       = data.aws_availability_zones.tf-nifi-azs.names[2]
  cidr_block              = var.pubnet3_cidr
  tags                    = {
    Name                  = "tf-nifi-pubnet3"
  }
}

# public route table associations
resource "aws_route_table_association" "rt-assoc-pubnet1" {
  subnet_id               = aws_subnet.tf-nifi-pubnet1.id
  route_table_id          = aws_route_table.tf-nifi-pubrt.id
}

resource "aws_route_table_association" "rt-assoc-pubnet2" {
  subnet_id               = aws_subnet.tf-nifi-pubnet2.id
  route_table_id          = aws_route_table.tf-nifi-pubrt.id
}

resource "aws_route_table_association" "rt-assoc-pubnet3" {
  subnet_id               = aws_subnet.tf-nifi-pubnet3.id
  route_table_id          = aws_route_table.tf-nifi-pubrt.id
}

# nat gateways per subnet
resource "aws_eip" "tf-nifi-ng-eip1" {
  vpc                     = true
  tags                    = {
    Name                  = "tf-nifi-ng-eip1"
  }
}

resource "aws_eip" "tf-nifi-ng-eip2" {
  vpc                     = true
  tags                    = {
    Name                  = "tf-nifi-ng-eip2"
  }
}

resource "aws_eip" "tf-nifi-ng-eip3" {
  vpc                     = true
  tags                    = {
    Name                  = "tf-nifi-ng-eip3"
  }
}

resource "aws_nat_gateway" "tf-nifi-ng1" {
  allocation_id           = aws_eip.tf-nifi-ng-eip1.id
  subnet_id               = aws_subnet.tf-nifi-pubnet1.id
  tags                    = {
    Name                  = "tf-nifi-ng1"
  }
  depends_on              = [aws_internet_gateway.tf-nifi-gw]
}

resource "aws_nat_gateway" "tf-nifi-ng2" {
  allocation_id           = aws_eip.tf-nifi-ng-eip2.id
  subnet_id               = aws_subnet.tf-nifi-pubnet2.id
  tags                    = {
    Name                  = "tf-nifi-ng2"
  }
  depends_on              = [aws_internet_gateway.tf-nifi-gw]
}

resource "aws_nat_gateway" "tf-nifi-ng3" {
  allocation_id           = aws_eip.tf-nifi-ng-eip3.id
  subnet_id               = aws_subnet.tf-nifi-pubnet3.id
  tags                    = {
    Name                  = "tf-nifi-ng3"
  }
  depends_on              = [aws_internet_gateway.tf-nifi-gw]
}

# private subnets
resource "aws_subnet" "tf-nifi-prinet1" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  availability_zone       = data.aws_availability_zones.tf-nifi-azs.names[0]
  cidr_block              = var.prinet1_cidr
  tags                    = {
    Name                  = "tf-nifi-prinet1"
  }
}

resource "aws_subnet" "tf-nifi-prinet2" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  availability_zone       = data.aws_availability_zones.tf-nifi-azs.names[1]
  cidr_block              = var.prinet2_cidr
  tags                    = {
    Name                  = "tf-nifi-prinet2"
  }
}

resource "aws_subnet" "tf-nifi-prinet3" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  availability_zone       = data.aws_availability_zones.tf-nifi-azs.names[2]
  cidr_block              = var.prinet3_cidr
  tags                    = {
    Name                  = "tf-nifi-prinet3"
  }
}

# private route table associations
resource "aws_route_table_association" "rt-assoc-prinet1" {
  subnet_id               = aws_subnet.tf-nifi-prinet1.id
  route_table_id          = aws_route_table.tf-nifi-prirt1.id
}

resource "aws_route_table_association" "rt-assoc-prinet2" {
  subnet_id               = aws_subnet.tf-nifi-prinet2.id
  route_table_id          = aws_route_table.tf-nifi-prirt2.id
}

resource "aws_route_table_association" "rt-assoc-prinet3" {
  subnet_id               = aws_subnet.tf-nifi-prinet3.id
  route_table_id          = aws_route_table.tf-nifi-prirt3.id
}

# security groups
resource "aws_security_group" "tf-nifi-pubsg1" {
  name                    = "tf-nifi-pubsg1"
  description             = "Security group for public ELB"
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  tags = {
    Name = "tf-nifi-pubsg1"
  }
}

resource "aws_security_group" "tf-nifi-prisg1" {
  name                    = "tf-nifi-prisg1"
  description             = "Security group for private instances"
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  tags = {
    Name = "tf-nifi-prisg1"
  }
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-rule1-in" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "ingress"
  description             = "IN - NiFi Listen 1"
  from_port               = "3001"
  to_port                 = "3001"
  protocol                = "tcp"
  cidr_blocks             = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-rule1-out" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "egress"
  description             = "OUT - NiFi Listen 1"
  from_port               = "3001"
  to_port                 = "3001"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-rule2-in" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "ingress"
  description             = "IN - SSH MGMT"
  from_port               = "22"
  to_port                 = "22"
  protocol                = "tcp"
  cidr_blocks             = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-rule2-out" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "egress"
  description             = "OUT - SSH MGMT"
  from_port               = "22"
  to_port                 = "22"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-rule1-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN - NiFi Listen 1"
  from_port               = "3001"
  to_port                 = "3001"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-pubsg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-rule2-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN - SSH MGMT"
  from_port               = "22"
  to_port                 = "22"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-pubsg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-http-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT - HTTP"
  from_port               = "80"
  to_port                 = "80"
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "tf-nifi-prisg1-https-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT - HTTPS"
  from_port               = "443"
  to_port                 = "443"
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

# load balancer
resource "aws_elb" "tf-nifi-elb1" {
  name                    = "tf-nifi-elb1"
  subnets                 = [aws_subnet.tf-nifi-pubnet1.id, aws_subnet.tf-nifi-pubnet2.id, aws_subnet.tf-nifi-pubnet3.id]
  security_groups         = [aws_security_group.tf-nifi-pubsg1.id]
  listener {
    instance_port           = 22
    instance_protocol       = "TCP"
    lb_port                 = 22
    lb_protocol             = "TCP"
  }
  listener {
    instance_port           = 3001
    instance_protocol       = "TCP"
    lb_port                 = 3001
    lb_protocol             = "TCP"
  }
}

# Instance Key
resource "aws_key_pair" "tf-nifi-instance-key" {
  key_name   = "tf-nifi-instance-key"
  public_key = var.instance_key
  tags                    = {
    Name                  = "tf-nifi-instance-key"
  }
}

# Latest Ubuntu 18.04
data "aws_ami" "tf-nifi-ubuntu-ami" {
  most_recent             = true
  owners                  = ["099720109477"]
  filter {
    name                    = "name"
    values                  = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
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

# Instance(s)
resource "aws_instance" "tf-nifi-managedinstance1" {
  ami                       = data.aws_ami.tf-nifi-ubuntu-ami.id
  instance_type             = "t3a.micro"
  key_name                  = aws_key_pair.tf-nifi-instance-key.key_name
  subnet_id                 = aws_subnet.tf-nifi-prinet1.id
  vpc_security_group_ids    = [aws_security_group.tf-nifi-prisg1.id]
  tags                    = {
    Name                  = "tf-nifi-managedinstance1"
  }
}
