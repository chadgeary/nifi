resource "aws_lb" "zk-lb" {
  name               = "${var.name_prefix}-zk-lb-${random_string.tf-nifi-random.result}"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.tf-nifi-prinet1.id, aws_subnet.tf-nifi-prinet2.id, aws_subnet.tf-nifi-prinet3.id]
}

resource "aws_lb_target_group" "zk-lbtg-nifi" {
  name        = "${var.name_prefix}-zk-lbtg-nifi-${random_string.tf-nifi-random.result}"
  port        = 2181
  protocol    = "TCP"
  vpc_id      = aws_vpc.tf-nifi-vpc.id
  deregistration_delay = 10
  target_type = "ip"
}

resource "aws_lb_listener" "zk-lb-listen" {
  load_balancer_arn = aws_lb.zk-lb.arn
  port              = var.zk_portnifi
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.zk-lbtg-nifi.arn
  }
}

resource "aws_lb_target_group" "zkA-lbtg2" {
  name        = "${var.name_prefix}-zkA-lbtg2-${random_string.tf-nifi-random.result}"
  port        = 2888
  protocol    = "TCP"
  vpc_id      = aws_vpc.tf-nifi-vpc.id
  deregistration_delay = 10
  target_type = "ip"
  health_check {
    port = 2181
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "zkA-listen2" {
  load_balancer_arn = aws_lb.zk-lb.arn
  port              = var.zkA_port2
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.zkA-lbtg2.arn
  }
}

resource "aws_lb_target_group" "zkA-lbtg3" {
  name        = "${var.name_prefix}-zkA-lbtg3-${random_string.tf-nifi-random.result}"
  port        = 3888
  protocol    = "TCP"
  vpc_id      = aws_vpc.tf-nifi-vpc.id
  deregistration_delay = 10
  target_type = "ip"
}

resource "aws_lb_listener" "zkA-listen3" {
  load_balancer_arn = aws_lb.zk-lb.arn
  port              = var.zkA_port3
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.zkA-lbtg3.arn
  }
}

resource "aws_lb_target_group" "zkB-lbtg2" {
  name        = "${var.name_prefix}-zkB-lbtg2-${random_string.tf-nifi-random.result}"
  port        = 2888
  protocol    = "TCP"
  vpc_id      = aws_vpc.tf-nifi-vpc.id
  deregistration_delay = 10
  target_type = "ip"
  health_check {
    port = 2181
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "zkB-listen2" {
  load_balancer_arn = aws_lb.zk-lb.arn
  port              = var.zkB_port2
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.zkB-lbtg2.arn
  }
}

resource "aws_lb_target_group" "zkB-lbtg3" {
  name        = "${var.name_prefix}-zkB-lbtg3-${random_string.tf-nifi-random.result}"
  port        = 3888
  protocol    = "TCP"
  vpc_id      = aws_vpc.tf-nifi-vpc.id
  deregistration_delay = 10
  target_type = "ip"
}

resource "aws_lb_listener" "zkB-listen3" {
  load_balancer_arn = aws_lb.zk-lb.arn
  port              = var.zkB_port3
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.zkB-lbtg3.arn
  }
}

resource "aws_lb_target_group" "zkC-lbtg2" {
  name        = "${var.name_prefix}-zkC-lbtg2-${random_string.tf-nifi-random.result}"
  port        = 2888
  protocol    = "TCP"
  vpc_id      = aws_vpc.tf-nifi-vpc.id
  deregistration_delay = 10
  target_type = "ip"
  health_check {
    port = 2181
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "zkC-listen2" {
  load_balancer_arn = aws_lb.zk-lb.arn
  port              = var.zkC_port2
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.zkC-lbtg2.arn
  }
}

resource "aws_lb_target_group" "zkC-lbtg3" {
  name        = "${var.name_prefix}-zkC-lbtg3-${random_string.tf-nifi-random.result}"
  port        = 3888
  protocol    = "TCP"
  vpc_id      = aws_vpc.tf-nifi-vpc.id
  deregistration_delay = 10
  target_type = "ip"
}

resource "aws_lb_listener" "zkC-listen3" {
  load_balancer_arn = aws_lb.zk-lb.arn
  port              = var.zkC_port3
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.zkC-lbtg3.arn
  }
}
