resource "aws_security_group" "zk-sg-public" {
  name                    = "${var.name_prefix}-sg-public-${random_string.zk-random.result}"
  description             = "Security group for public"
  vpc_id                  = aws_vpc.zk-vpc.id
  tags = {
    Name = "${var.name_prefix}-sg-public-${random_string.zk-random.result}"
  }
}

resource "aws_security_group_rule" "zk-sg-public-tcp-out" {
  security_group_id       = aws_security_group.zk-sg-public.id
  type                    = "egress"
  description             = "OUT TO WORLD - TCP"
  from_port               = 0
  to_port                 = 65535
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "zk-sg-public-udp-out" {
  security_group_id       = aws_security_group.zk-sg-public.id
  type                    = "egress"
  description             = "OUT TO WORLD - UDP"
  from_port               = 0
  to_port                 = 65535
  protocol                = "udp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "zk-sg-public-service-private" {
  security_group_id       = aws_security_group.zk-sg-public.id
  type                    = "egress"
  description             = "OUT TO PRIVATE"
  from_port               = var.service_port
  to_port                 = var.service_port
  protocol                = var.service_protocol
  source_security_group_id = aws_security_group.zk-sg-private.id
}

resource "aws_security_group_rule" "zk-sg-public-service-client" {
  security_group_id       = aws_security_group.zk-sg-public.id
  type                    = "ingress"
  description             = "IN FROM CLIENT"
  from_port               = var.service_port
  to_port                 = var.service_port
  protocol                = var.service_protocol
  cidr_blocks             = var.client_cidrs
}
