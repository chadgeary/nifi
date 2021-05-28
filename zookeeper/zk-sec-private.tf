resource "aws_security_group" "zk-sg-private" {
  name                    = "${var.name_prefix}-sg-private-${random_string.zk-random.result}"
  description             = "Security group for private"
  vpc_id                  = aws_vpc.zk-vpc.id
  tags = {
    Name = "${var.name_prefix}-sg-private-${random_string.zk-random.result}"
  }
}

resource "aws_security_group_rule" "zk-sg-private-tcp-out" {
  security_group_id       = aws_security_group.zk-sg-private.id
  type                    = "egress"
  description             = "OUT TO WORLD - TCP"
  from_port               = 0
  to_port                 = 65535
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "zk-sg-private-udp-out" {
  security_group_id       = aws_security_group.zk-sg-private.id
  type                    = "egress"
  description             = "OUT TO WORLD - UDP"
  from_port               = 0
  to_port                 = 65535
  protocol                = "udp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "zk-sg-private-service-public-in" {
  security_group_id       = aws_security_group.zk-sg-private.id
  type                    = "ingress"
  description             = "IN FROM PUBLIC SRVC"
  from_port               = var.service_port
  to_port                 = var.service_port
  protocol                = var.service_protocol
  cidr_blocks             = [var.subnetA_cidr, var.subnetB_cidr]
}

resource "aws_security_group_rule" "zk-sg-private-service-self-in" {
  security_group_id       = aws_security_group.zk-sg-private.id
  type                    = "ingress"
  description             = "IN FROM SELF SRVC"
  from_port               = var.service_port
  to_port                 = var.service_port
  protocol                = "tcp"
  source_security_group_id = aws_security_group.zk-sg-private.id
}

resource "aws_security_group_rule" "zk-sg-private-service-self-out" {
  security_group_id       = aws_security_group.zk-sg-private.id
  type                    = "egress"
  description             = "OUT TO SELF SRVC"
  from_port               = var.service_port
  to_port                 = var.service_port
  protocol                = "tcp"
  source_security_group_id = aws_security_group.zk-sg-private.id
}

resource "aws_security_group_rule" "zk-sg-private-logs-self-in" {
  security_group_id       = aws_security_group.zk-sg-private.id
  type                    = "ingress"
  description             = "IN FROM SELF HTTPS"
  from_port               = "443"
  to_port                 = "443"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.zk-sg-private.id
}

resource "aws_security_group_rule" "zk-sg-private-logs-self-out" {
  security_group_id       = aws_security_group.zk-sg-private.id
  type                    = "egress"
  description             = "OUT TO SELF HTTPS"
  from_port               = "443"
  to_port                 = "443"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.zk-sg-private.id
}
