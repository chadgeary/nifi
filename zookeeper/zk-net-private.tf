resource "aws_route_table" "zk-routeAC" {
  vpc_id                  = aws_vpc.zk-vpc.id
  route {
    cidr_block              = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.zk-natgwAC.id
  }
  tags                    = {
    Name                  = "${var.name_prefix}-routeC-${random_string.zk-random.result}"
  }
}

resource "aws_route_table" "zk-routeBD" {
  vpc_id                  = aws_vpc.zk-vpc.id
  route {
    cidr_block              = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.zk-natgwBD.id
  }
  tags                    = {
    Name                  = "${var.name_prefix}-routeD-${random_string.zk-random.result}"
  }
}

resource "aws_subnet" "zk-netC" {
  vpc_id                  = aws_vpc.zk-vpc.id
  availability_zone       = data.aws_availability_zones.zk-azs.names[var.aws_az]
  cidr_block              = var.subnetC_cidr
  tags                    = {
    Name                  = "${var.name_prefix}-netC-${random_string.zk-random.result}"
  }
  depends_on              = [aws_nat_gateway.zk-natgwAC]
}

resource "aws_subnet" "zk-netD" {
  vpc_id                  = aws_vpc.zk-vpc.id
  availability_zone       = data.aws_availability_zones.zk-azs.names[var.aws_az + 1]
  cidr_block              = var.subnetD_cidr
  tags                    = {
    Name                  = "${var.name_prefix}-netD-${random_string.zk-random.result}"
  }
  depends_on              = [aws_nat_gateway.zk-natgwBD]
}

resource "aws_route_table_association" "zk-route-netC" {
  subnet_id               = aws_subnet.zk-netC.id
  route_table_id          = aws_route_table.zk-routeAC.id
}

resource "aws_route_table_association" "zk-route-netD" {
  subnet_id               = aws_subnet.zk-netD.id
  route_table_id          = aws_route_table.zk-routeBD.id
}
