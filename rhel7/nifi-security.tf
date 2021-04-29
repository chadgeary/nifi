# ssh key
resource "aws_key_pair" "tf-nifi-instance-key" {
  key_name                = "${var.name_prefix}-instance-key-${random_string.tf-nifi-random.result}"
  public_key              = var.instance_key
  tags                    = {
    Name                    = "${var.name_prefix}-instance-key-${random_string.tf-nifi-random.result}"
  }
}

# security group
resource "aws_security_group" "tf-nifi-prisg" {
  name                    = "${var.name_prefix}-pri-sg-${random_string.tf-nifi-random.result}"
  description             = "Security group for private traffic"
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  tags = {
    Name = "tf-nifi-prisg"
  }
}

# egress
resource "aws_security_group_rule" "tf-nifi-prisg-allhttp-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  type                    = "egress"
  description             = "OUT TO WORLD - HTTP"
  from_port               = "80"
  to_port                 = "80"
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "tf-nifi-prisg-allhttps-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  type                    = "egress"
  description             = "OUT TO WORLD - HTTPS"
  from_port               = "443"
  to_port                 = "443"
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "tf-nifi-prisg-web-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  type                    = "egress"
  description             = "OUT TO PUB PRI NAT - HTTPS NIFI"
  from_port               = var.web_port
  to_port                 = var.web_port
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

# ingress
resource "aws_security_group_rule" "tf-nifi-prisg-web-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  type                    = "ingress"
  description             = "IN FROM PUB PRI NAT - HTTPS NIFI"
  from_port               = var.web_port
  to_port                 = var.web_port
  protocol                = "tcp"
  cidr_blocks             = concat(var.mgmt_cidrs, [var.pubnet1_cidr, var.pubnet2_cidr, var.pubnet3_cidr, var.prinet1_cidr, var.prinet2_cidr, var.prinet3_cidr, "${aws_eip.tf-nifi-ng-eip1.public_ip}/32","${aws_eip.tf-nifi-ng-eip2.public_ip}/32","${aws_eip.tf-nifi-ng-eip3.public_ip}/32"])
}

resource "aws_security_group_rule" "tf-nifi-prisg-tcp-service-in" {
  count                   = length(var.tcp_service_ports)
  type                    = "ingress"
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  description             = "IN FROM SERVICE - TCP ${var.tcp_service_ports[count.index]}"
  from_port               = var.tcp_service_ports[count.index]
  to_port                 = var.tcp_service_ports[count.index]
  protocol                = "tcp"
  cidr_blocks             = concat(var.client_cidrs, [var.pubnet1_cidr, var.pubnet2_cidr, var.pubnet3_cidr, var.prinet1_cidr, var.prinet2_cidr, var.prinet3_cidr])
}

resource "aws_security_group_rule" "tf-nifi-prisg-udp-service-in" {
  count                   = length(var.udp_service_ports)
  type                    = "ingress"
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  description             = "IN FROM SERVICE - UDP ${var.udp_service_ports[count.index]}"
  from_port               = var.udp_service_ports[count.index]
  to_port                 = var.udp_service_ports[count.index]
  protocol                = "udp"
  cidr_blocks             = concat(var.client_cidrs, [var.pubnet1_cidr, var.pubnet2_cidr, var.pubnet3_cidr, var.prinet1_cidr, var.prinet2_cidr, var.prinet3_cidr])
}

resource "aws_security_group_rule" "tf-nifi-prisg-tcpudp-service-in" {
  count                   = length(var.tcpudp_service_ports)
  type                    = "ingress"
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  description             = "IN FROM SERVICE - TCPUDP ${var.tcpudp_service_ports[count.index]}"
  from_port               = var.tcpudp_service_ports[count.index]
  to_port                 = var.tcpudp_service_ports[count.index]
  protocol                = "all"
  cidr_blocks             = concat(var.client_cidrs, [var.pubnet1_cidr, var.pubnet2_cidr, var.pubnet3_cidr, var.prinet1_cidr, var.prinet2_cidr, var.prinet3_cidr])
}

# self
resource "aws_security_group_rule" "tf-nifi-prisg-self-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  type                    = "ingress"
  description             = "IN FROM SELF - SELF PORTS"
  from_port               = "2171"
  to_port                 = "2176"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg.id
}

resource "aws_security_group_rule" "tf-nifi-prisg-self-in-web" {
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  type                    = "ingress"
  description             = "IN FROM SELF - WEB PORT SG"
  from_port               = var.web_port
  to_port                 = var.web_port
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg.id
}

resource "aws_security_group_rule" "tf-nifi-prisg-self-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  type                    = "egress"
  description             = "OUT TO SELF - SELF PORTS"
  from_port               = "2171"
  to_port                 = "2176"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg.id
}

resource "aws_security_group_rule" "tf-nifi-prisg-self-out-websg" {
  security_group_id       = aws_security_group.tf-nifi-prisg.id
  type                    = "egress"
  description             = "OUT TO SELF - WEB PORT SG"
  from_port               = var.web_port
  to_port                 = var.web_port
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg.id
}
