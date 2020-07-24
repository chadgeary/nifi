variable "aws_region" {
  type                     = string
}

variable "aws_profile" {
  type                     = string
}

variable "vpc_cidr" {
  type                     = string
}

variable "pubnet1_cidr" {
  type                     = string
}

variable "prinet1_cidr" {
  type                     = string
}

variable "pubnet2_cidr" {
  type                     = string
}

variable "prinet2_cidr" {
  type                     = string
}

variable "pubnet3_cidr" {
  type                     = string
}

variable "prinet3_cidr" {
  type                     = string
}

variable "node1_ip" {
  type                     = string
  description              = "An ip from prinet1_cidr for the first nifi node, which runs zookeeper"
}

variable "node2_ip" {
  type                     = string
  description              = "An ip from prinet2_cidr for the second nifi node, which runs zookeeper"
}

variable "node3_ip" {
  type                     = string
  description              = "An ip from prinet3_cidr for the third nifi node, which runs zookeeper"
}

variable "mgmt_cidr" {
  type                     = string
  description              = "Subnet CIDR allowed to access NiFi instance(s) via ELB, e.g. 172.16.10.0/30"
}

variable "instance_key" {
  type                     = string
  description              = "A public key for SSH access to instance(s)"
}

variable "bucket_name" {
  type                     = string
  description              = "A unique bucket name to store playbooks and output of SSM"
}

variable "mirror_host" {
  type                     = string
  description              = "Mirror host for NiFi and Zookeeper installation files, e.g. mirror.cogentco.com"
}

variable "nifi_version" {
  type                     = string
  description              = "The version of Apache NiFi, e.g. 1.11.4"
}

variable "zk_version" {
  type                     = string
  description              = "The version of Apache Zookeeper, e.g. 3.6.1"
}

provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_profile
}

# availability zones - assumes at least 3 are available
data "aws_availability_zones" "tf-nifi-azs" {
  state                    = "available"
}

# aws managed kms key for s3
data "aws_kms_key" "tf-nifi-s3kmskey" {
  key_id                  = "alias/aws/s3"
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

# s3 endpoint for private instance(s)
data "aws_vpc_endpoint_service" "tf-nifi-s3-endpoint-service" {
  service                 = "s3"
}

resource "aws_vpc_endpoint" "tf-nifi-s3-endpoint" {
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  service_name            = data.aws_vpc_endpoint_service.tf-nifi-s3-endpoint-service.service_name
  vpc_endpoint_type       = "Gateway"
  route_table_ids         = [aws_route_table.tf-nifi-prirt1.id,aws_route_table.tf-nifi-prirt2.id,aws_route_table.tf-nifi-prirt3.id]
  tags                    = {
    Name                  = "tf-nifi-s3-endpoint"
  }
}

data "aws_prefix_list" "tf-nifi-s3-prefixlist" {
  prefix_list_id          = aws_vpc_endpoint.tf-nifi-s3-endpoint.prefix_list_id
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
  from_port               = "80"
  to_port                 = "8080"
  protocol                = "tcp"
  cidr_blocks             = [var.mgmt_cidr]
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-rule1-out" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "egress"
  description             = "OUT - NiFi Listen 1"
  from_port               = "8080"
  to_port                 = "8080"
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
  cidr_blocks             = [var.mgmt_cidr]
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
  from_port               = "8080"
  to_port                 = "8080"
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

resource "aws_security_group_rule" "tf-nifi-prisg1-self-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN - SELF"
  from_port               = "2100"
  to_port                 = "2299"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-self-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT - SELF"
  from_port               = "2100"
  to_port                 = "2299"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

# s3 bucket, object, and ssm association for nifi installation
resource "aws_s3_bucket" "tf-nifi-bucket" {
  bucket                  = var.bucket_name
  acl                     = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_key.tf-nifi-s3kmskey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_object" "tf-nifi-zookeepers" {
  for_each                = fileset("zookeepers/", "*")
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  key                     = "zookeepers/${each.value}"
  source                  = "zookeepers/${each.value}"
  etag                    = filemd5("zookeepers/${each.value}")
}

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
    ExtraVariables          = "SSM=True zk_version=${var.zk_version} nifi_version=${var.nifi_version} mirror_host=${var.mirror_host} node1_ip=${var.node1_ip} node2_ip=${var.node2_ip} node3_ip=${var.node3_ip}"
    InstallDependencies     = "True"
    PlaybookFile            = "zookeepers.yml"
    SourceInfo              = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.tf-nifi-bucket.id}/zookeepers/\"}"
    SourceType              = "S3"
    Verbose                 = "-v"
  }
}

# load balancer
resource "aws_elb" "tf-nifi-elb1" {
  name                    = "tf-nifi-elb"
  subnets                 = [aws_subnet.tf-nifi-pubnet1.id, aws_subnet.tf-nifi-pubnet2.id, aws_subnet.tf-nifi-pubnet3.id]
  security_groups         = [aws_security_group.tf-nifi-pubsg1.id]
  listener {
    instance_port           = 22
    instance_protocol       = "TCP"
    lb_port                 = 22
    lb_protocol             = "TCP"
  }
  listener {
    instance_port           = 8080
    instance_protocol       = "TCP"
    lb_port                 = 8080
    lb_protocol             = "TCP"
  }
}

# Instance Role and Profile, Key, Image (Latest RHEL7), and Instance
data "aws_iam_policy" "tf-nifi-instance-policy-ssm" {
  arn                     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "tf-nifi-instance-policy-s3" {
  name                    = "tf-nifi-instance-policy"
  path                    = "/"
  description             = "Provides tf-nifi instances access to endpoint and s3 objects in SSM bucket"
  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListObjectsinBucket",
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}"]
    },
    {
      "Sid": "GetObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}/zookeepers/*"]
    },
    {
      "Sid": "PutObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}/ssm/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "tf-nifi-instance-iam-role" {
  name                    = "tf-nifi-instance-profile"
  path                    = "/"
  assume_role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
             "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-ssm" {
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn              = data.aws_iam_policy.tf-nifi-instance-policy-ssm.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-s3" {
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn              = aws_iam_policy.tf-nifi-instance-policy-s3.arn
}

resource "aws_iam_instance_profile" "tf-nifi-instance-profile" {
  name                    = "tf-nifi-instance-profile"
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
}

# Instance Key
resource "aws_key_pair" "tf-nifi-instance-key" {
  key_name                = "tf-nifi-instance-key"
  public_key              = var.instance_key
  tags                    = {
    Name                    = "tf-nifi-instance-key"
  }
}

# Latest RHEL 7
data "aws_ami" "tf-nifi-rhel-ami" {
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

# Instance(s)
resource "aws_instance" "tf-nifi-1" {
  ami                     = data.aws_ami.tf-nifi-rhel-ami.id
  instance_type           = "t3a.medium"
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  subnet_id               = aws_subnet.tf-nifi-prinet1.id
  private_ip              = var.node1_ip
  vpc_security_group_ids  = [aws_security_group.tf-nifi-prisg1.id]
  tags                    = {
    Name                    = "tf-nifi-1"
  }
  user_data               = file("userdata/tf-nifi-userdata-1.sh")
  depends_on              = [aws_nat_gateway.tf-nifi-ng1]
}

resource "aws_elb_attachment" "tf-nifi-1-elb-attach" {
  elb                     = aws_elb.tf-nifi-elb1.id
  instance                = aws_instance.tf-nifi-1.id
}

resource "aws_instance" "tf-nifi-2" {
  ami                     = data.aws_ami.tf-nifi-rhel-ami.id
  instance_type           = "t3a.medium"
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  subnet_id               = aws_subnet.tf-nifi-prinet1.id
  private_ip              = var.node2_ip
  vpc_security_group_ids  = [aws_security_group.tf-nifi-prisg1.id]
  tags                    = {
    Name                    = "tf-nifi-2"
  }
  user_data               = file("userdata/tf-nifi-userdata-2.sh")
  depends_on              = [aws_nat_gateway.tf-nifi-ng2]
}

resource "aws_elb_attachment" "tf-nifi-2-elb-attach" {
  elb                     = aws_elb.tf-nifi-elb1.id
  instance                = aws_instance.tf-nifi-2.id
}

resource "aws_instance" "tf-nifi-3" {
  ami                     = data.aws_ami.tf-nifi-rhel-ami.id
  instance_type           = "t3a.medium"
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  subnet_id               = aws_subnet.tf-nifi-prinet1.id
  private_ip              = var.node3_ip
  vpc_security_group_ids  = [aws_security_group.tf-nifi-prisg1.id]
  tags                    = {
    Name                    = "tf-nifi-3"
  }
  user_data               = file("userdata/tf-nifi-userdata-3.sh")
  depends_on              = [aws_nat_gateway.tf-nifi-ng3]
}

resource "aws_elb_attachment" "tf-nifi-3-elb-attach" {
  elb                     = aws_elb.tf-nifi-elb1.id
  instance                = aws_instance.tf-nifi-3.id
}
