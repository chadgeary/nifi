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
