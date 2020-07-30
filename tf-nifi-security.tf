# security groups
resource "aws_security_group" "tf-nifi-pubsg1" {
  name                    = "tf-nifi-pubsg1"
  description             = "Security group for public traffic"
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  tags = {
    Name = "tf-nifi-pubsg1"
  }
}

resource "aws_security_group" "tf-nifi-prisg1" {
  name                    = "tf-nifi-prisg1"
  description             = "Security group for private traffic"
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  tags = {
    Name = "tf-nifi-prisg1"
  }
}

# security group rules
resource "aws_security_group_rule" "tf-nifi-pubsg1-rule1-in" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "ingress"
  description             = "IN FROM MGMT - HTTPS NIFI"
  from_port               = "443"
  to_port                 = "8443"
  protocol                = "tcp"
  cidr_blocks             = [var.mgmt_cidr]
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-rule1-out" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "egress"
  description             = "OUT TO PRI - HTTPS NIFI"
  from_port               = "8443"
  to_port                 = "8443"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-rule2-in" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "ingress"
  description             = "IN FROM MGMT - SSH MGMT"
  from_port               = "22"
  to_port                 = "22"
  protocol                = "tcp"
  cidr_blocks             = [var.mgmt_cidr]
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-rule2-out" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "egress"
  description             = "OUT TO PRI - SSH MGMT"
  from_port               = "22"
  to_port                 = "22"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-rule1-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN FROM PUB - HTTPS NIFI"
  from_port               = "8443"
  to_port                 = "8443"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-pubsg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-rule2-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN FROM PRI - HTTPS NIFI"
  from_port               = "8443"
  to_port                 = "8443"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-rule3-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN FROM PUB - SSH MGMT"
  from_port               = "22"
  to_port                 = "22"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-pubsg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-rule2-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT TO PRI - HTTPS NIFI"
  from_port               = "8443"
  to_port                 = "8443"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-http-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT TO WORLD - HTTP"
  from_port               = "80"
  to_port                 = "80"
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "tf-nifi-prisg1-https-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT TO WORLD - HTTPS"
  from_port               = "443"
  to_port                 = "443"
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "tf-nifi-prisg1-efs-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN FROM PRI - AWS EFS"
  from_port               = "2049"
  to_port                 = "2249"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-efs-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT TO PRI - AWS EFS"
  from_port               = "2000"
  to_port                 = "2299"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-nififlow-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN FROM PRI - NIFI FLOW PORTS"
  from_port               = "2100"
  to_port                 = "2299"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-nififlow-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT TO PRI - NIFI FLOW PORTS"
  from_port               = "2100"
  to_port                 = "2299"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}
