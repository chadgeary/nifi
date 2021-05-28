resource "aws_vpc" "zk-vpc" {
  cidr_block              = var.vpc_cidr
  enable_dns_support      = "true"
  enable_dns_hostnames    = "true"
  tags                    = {
    Name                  = "${var.name_prefix}-vpc-${random_string.zk-random.result}"
  }
}

resource "aws_internet_gateway" "zk-gw" {
  vpc_id                  = aws_vpc.zk-vpc.id
  tags                    = {
    Name                  = "${var.name_prefix}-gw-${random_string.zk-random.result}"
  }
}

resource "aws_eip" "zk-natipA" {
  vpc                     = true
}

resource "aws_eip" "zk-natipB" {
  vpc                     = true
}

resource "aws_nat_gateway" "zk-natgwAC" {
  allocation_id           = aws_eip.zk-natipA.id
  subnet_id               = aws_subnet.zk-netA.id
  depends_on              = [aws_internet_gateway.zk-gw]
}

resource "aws_nat_gateway" "zk-natgwBD" {
  allocation_id           = aws_eip.zk-natipB.id
  subnet_id               = aws_subnet.zk-netB.id
  depends_on              = [aws_internet_gateway.zk-gw]
}

resource "aws_vpc_endpoint" "zk-vpc-s3-endpointABCD" {
  vpc_id                  = aws_vpc.zk-vpc.id
  service_name            = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids         = [aws_route_table.zk-routeAB.id, aws_route_table.zk-routeAC.id, aws_route_table.zk-routeBD.id]
}

resource "aws_vpc_endpoint" "zk-vpc-logs-endpointCD" {
  vpc_id                  = aws_vpc.zk-vpc.id
  service_name            = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type       = "Interface"
  security_group_ids      = [aws_security_group.zk-sg-private.id]
  private_dns_enabled     = true
  subnet_ids              = [aws_subnet.zk-netC.id, aws_subnet.zk-netD.id]
}
