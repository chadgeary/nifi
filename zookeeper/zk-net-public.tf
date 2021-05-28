resource "aws_route_table" "zk-routeAB" {
  vpc_id                  = aws_vpc.zk-vpc.id
  route {
    cidr_block              = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.zk-gw.id
  }
  tags                    = {
    Name                  = "${var.name_prefix}-route1-${random_string.zk-random.result}"
  }
}

resource "aws_subnet" "zk-netA" {
  vpc_id                  = aws_vpc.zk-vpc.id
  availability_zone       = data.aws_availability_zones.zk-azs.names[var.aws_az]
  cidr_block              = var.subnetA_cidr
  tags                    = {
    Name                  = "${var.name_prefix}-netA-${random_string.zk-random.result}"
  }
  depends_on              = [aws_internet_gateway.zk-gw]
}

resource "aws_subnet" "zk-netB" {
  vpc_id                  = aws_vpc.zk-vpc.id
  availability_zone       = data.aws_availability_zones.zk-azs.names[var.aws_az + 1]
  cidr_block              = var.subnetB_cidr
  tags                    = {
    Name                  = "${var.name_prefix}-netB-${random_string.zk-random.result}"
  }
  depends_on              = [aws_internet_gateway.zk-gw]
}

resource "aws_route_table_association" "zk-route-netA" {
  subnet_id               = aws_subnet.zk-netA.id
  route_table_id          = aws_route_table.zk-routeAB.id
}

resource "aws_route_table_association" "zk-route-netB" {
  subnet_id               = aws_subnet.zk-netB.id
  route_table_id          = aws_route_table.zk-routeAB.id
}
