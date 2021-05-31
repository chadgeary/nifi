resource "aws_security_group" "zk-prisg" {
  name        = "${var.name_prefix}-sg-zk-${random_string.tf-nifi-random.result}"
  description = "Security group for zk"
  vpc_id      = aws_vpc.tf-nifi-vpc.id
  tags = {
    Name = "${var.name_prefix}-sg-zk-${random_string.tf-nifi-random.result}"
  }
}

# self zookeeper
resource "aws_security_group_rule" "zk-sg-zk-in" {
  for_each                 = toset(["2181", "2888", "3888"])
  security_group_id        = aws_security_group.zk-prisg.id
  type                     = "ingress"
  description              = "IN FROM SELF ZK ${each.key}"
  from_port                = each.key
  to_port                  = each.key
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.zk-prisg.id
}

resource "aws_security_group_rule" "zk-sg-zk-out" {
  for_each                 = toset(["2181", "2888", "3888"])
  security_group_id        = aws_security_group.zk-prisg.id
  type                     = "egress"
  description              = "OUT FROM SELF ZK ${each.key}"
  from_port                = each.key
  to_port                  = each.key
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.zk-prisg.id
}

# self endpoints
resource "aws_security_group_rule" "zk-sg-https-in" {
  security_group_id        = aws_security_group.zk-prisg.id
  type                     = "ingress"
  description              = "IN FROM ZK TO SELF HTTPS"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.zk-prisg.id
}

resource "aws_security_group_rule" "zk-sg-https-out" {
  security_group_id        = aws_security_group.zk-prisg.id
  type                     = "egress"
  description              = "OUT FROM ZK TO SELF HTTPS"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.zk-prisg.id
}

# world
resource "aws_security_group_rule" "zk-prisg-tcp-out" {
  security_group_id = aws_security_group.zk-prisg.id
  type              = "egress"
  description       = "OUT TO WORLD - TCP"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "zk-prisg-udp-out" {
  security_group_id = aws_security_group.zk-prisg.id
  type              = "egress"
  description       = "OUT TO WORLD - UDP"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# nifi
resource "aws_security_group_rule" "zk-sg-nifi-in" {
  security_group_id        = aws_security_group.zk-prisg.id
  type                     = "ingress"
  description              = "IN FROM NIFI"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg.id
}
