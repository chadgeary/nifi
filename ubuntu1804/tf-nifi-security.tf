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

# public sg (elb) rules
resource "aws_security_group_rule" "tf-nifi-pubsg1-mgmt-ssh-in" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "ingress"
  description             = "IN FROM MGMT - SSH MGMT"
  from_port               = "22"
  to_port                 = "22"
  protocol                = "tcp"
  cidr_blocks             = [var.mgmt_cidr]
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-mgmt-ssh-out" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "egress"
  description             = "OUT TO PRI - SSH MGMT"
  from_port               = "22"
  to_port                 = "22"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-mgmt-https-in" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "ingress"
  description             = "IN FROM MGMT - HTTPS NIFI"
  from_port               = "443"
  to_port                 = "443"
  protocol                = "tcp"
  cidr_blocks             = [var.mgmt_cidr]
}

resource "aws_security_group_rule" "tf-nifi-pubsg1-mgmt-https-out" {
  security_group_id       = aws_security_group.tf-nifi-pubsg1.id
  type                    = "egress"
  description             = "OUT TO PRI - HTTPS NIFI"
  from_port               = "2170"
  to_port                 = "2170"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

# private sg (instances) rules
resource "aws_security_group_rule" "tf-nifi-prisg1-pub-ssh-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN FROM PUB - SSH MGMT"
  from_port               = "22"
  to_port                 = "22"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-pubsg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-pub-https-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN FROM PUB - HTTPS NIFI"
  from_port               = "2170"
  to_port                 = "2170"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-pubsg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-self-in" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "ingress"
  description             = "IN FROM SELF - SELF PORTS"
  from_port               = "2170"
  to_port                 = "2176"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-self-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT TO SELF - SELF PORTS"
  from_port               = "2170"
  to_port                 = "2176"
  protocol                = "tcp"
  source_security_group_id = aws_security_group.tf-nifi-prisg1.id
}

resource "aws_security_group_rule" "tf-nifi-prisg1-allhttp-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT TO WORLD - HTTP"
  from_port               = "80"
  to_port                 = "80"
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "tf-nifi-prisg1-allhttps-out" {
  security_group_id       = aws_security_group.tf-nifi-prisg1.id
  type                    = "egress"
  description             = "OUT TO WORLD - HTTPS"
  from_port               = "443"
  to_port                 = "443"
  protocol                = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
}
