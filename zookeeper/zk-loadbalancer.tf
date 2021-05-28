# Service
resource "aws_lb" "zk-lbSVC" {
  name                    = "${var.name_prefix}-lbSVC-${random_string.zk-random.result}"
  internal                = false
  load_balancer_type      = "network"
  subnets                 = [aws_subnet.zk-netA.id, aws_subnet.zk-netB.id]
}

resource "aws_lb_target_group" "zk-lbtgSVC" {
  name                    = "${var.name_prefix}-lbtgSVC-${var.service_port}-${random_string.zk-random.result}"
  port                    = var.zk_port
  protocol                = var.service_protocol
  vpc_id                  = aws_vpc.zk-vpc.id
  target_type             = "ip"
}

resource "aws_lb_listener" "zk-lb-listenSVC" {
  load_balancer_arn       = aws_lb.zk-lbSVC.arn
  port                    = var.service_port
  protocol                = var.service_protocol
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.zk-lbtgSVC.arn
  }
}

# Internal
resource "aws_lb" "zk-lbA" {
  name                    = "${var.name_prefix}-lbA-${random_string.zk-random.result}"
  internal                = false
  load_balancer_type      = "network"
  subnets                 = [aws_subnet.zk-netC.id, aws_subnet.zk-netD.id]
}

resource "aws_lb_target_group" "zk-lbtgA" {
  name                    = "${var.name_prefix}-lbtgA-${var.service_port}-${random_string.zk-random.result}"
  port                    = var.zk_port
  protocol                = var.service_protocol
  vpc_id                  = aws_vpc.zk-vpc.id
  target_type             = "ip"
}

resource "aws_lb_listener" "zk-lb-listenA2888" {
  load_balancer_arn       = aws_lb.zk-lbA.arn
  port                    = 2888
  protocol                = "TCP"
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.zk-lbtgA.arn
  }
}

resource "aws_lb_listener" "zk-lb-listenA3888" {
  load_balancer_arn       = aws_lb.zk-lbA.arn
  port                    = 3888
  protocol                = "TCP"
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.zk-lbtgA.arn
  }
}

# B
resource "aws_lb" "zk-lbB" {
  name                    = "${var.name_prefix}-lbB-${random_string.zk-random.result}"
  internal                = false
  load_balancer_type      = "network"
  subnets                 = [aws_subnet.zk-netC.id, aws_subnet.zk-netD.id]
}

resource "aws_lb_target_group" "zk-lbtgB" {
  name                    = "${var.name_prefix}-lbtgB-${var.service_port}-${random_string.zk-random.result}"
  port                    = var.zk_port
  protocol                = var.service_protocol
  vpc_id                  = aws_vpc.zk-vpc.id
  target_type             = "ip"
}

resource "aws_lb_listener" "zk-lb-listenB" {
  load_balancer_arn       = aws_lb.zk-lbB.arn
  port                    = var.service_port
  protocol                = var.service_protocol
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.zk-lbtgB.arn
  }
}

resource "aws_lb_listener" "zk-lb-listenB2888" {
  load_balancer_arn       = aws_lb.zk-lbB.arn
  port                    = 2888
  protocol                = "TCP"
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.zk-lbtgB.arn
  }
}

resource "aws_lb_listener" "zk-lb-listenB3888" {
  load_balancer_arn       = aws_lb.zk-lbB.arn
  port                    = 3888
  protocol                = "TCP"
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.zk-lbtgB.arn
  }
}

# C
resource "aws_lb" "zk-lbC" {
  name                    = "${var.name_prefix}-lbC-${random_string.zk-random.result}"
  internal                = false
  load_balancer_type      = "network"
  subnets                 = [aws_subnet.zk-netC.id, aws_subnet.zk-netD.id]
}

resource "aws_lb_target_group" "zk-lbtgC" {
  name                    = "${var.name_prefix}-lbtgC-${var.service_port}-${random_string.zk-random.result}"
  port                    = var.zk_port
  protocol                = var.service_protocol
  vpc_id                  = aws_vpc.zk-vpc.id
  target_type             = "ip"
}

resource "aws_lb_listener" "zk-lb-listenC" {
  load_balancer_arn       = aws_lb.zk-lbC.arn
  port                    = var.service_port
  protocol                = var.service_protocol
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.zk-lbtgC.arn
  }
}

resource "aws_lb_listener" "zk-lb-listenC2888" {
  load_balancer_arn       = aws_lb.zk-lbC.arn
  port                    = 2888
  protocol                = "TCP"
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.zk-lbtgC.arn
  }
}

resource "aws_lb_listener" "zk-lb-listenC3888" {
  load_balancer_arn       = aws_lb.zk-lbC.arn
  port                    = 3888
  protocol                = "TCP"
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.zk-lbtgC.arn
  }
}
