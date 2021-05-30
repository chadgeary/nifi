resource "aws_security_group" "zk-prisg" {
  name        = "${var.name_prefix}-sg-zk-${random_string.tf-nifi-random.result}"
  description = "Security group for zk"
  vpc_id      = aws_vpc.tf-nifi-vpc.id
  tags = {
    Name = "${var.name_prefix}-sg-zk-${random_string.tf-nifi-random.result}"
  }
}

resource "aws_security_group_rule" "zk-sg-zk-in" {
  for_each          = toset([tostring(var.zk_portnifi), tostring(var.zkA_port2), tostring(var.zkA_port3), tostring(var.zkB_port2), tostring(var.zkB_port3), tostring(var.zkC_port2), tostring(var.zkC_port3), "2181", "2888", "3888"])
  security_group_id = aws_security_group.zk-prisg.id
  type              = "ingress"
  description       = "IN FROM PRINET ZK ${each.key}"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = [var.prinet1_cidr, var.prinet2_cidr, var.prinet3_cidr]
}

resource "aws_security_group_rule" "zk-sg-zk-out" {
  for_each          = toset([tostring(var.zk_portnifi), tostring(var.zkA_port2), tostring(var.zkA_port3), tostring(var.zkB_port2), tostring(var.zkB_port3), tostring(var.zkC_port2), tostring(var.zkC_port3), "2181", "2888", "3888"])
  security_group_id = aws_security_group.zk-prisg.id
  type              = "egress"
  description       = "OUT FROM PRINET ZK ${each.key}"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = [var.prinet1_cidr, var.prinet2_cidr, var.prinet3_cidr]
}

resource "aws_security_group_rule" "zk-sg-https-in" {
  security_group_id = aws_security_group.zk-prisg.id
  type              = "ingress"
  description       = "IN FROM ZK TO SELF HTTPS"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  source_security_group_id = aws_security_group.zk-prisg.id
}

resource "aws_security_group_rule" "zk-sg-https-out" {
  security_group_id = aws_security_group.zk-prisg.id
  type              = "egress"
  description       = "OUT FROM ZK TO SELF HTTPS"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  source_security_group_id = aws_security_group.zk-prisg.id
}

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
