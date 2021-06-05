# load balancer
resource "aws_lb" "tf-nifi-node-nlb" {
  name                             = "${var.name_prefix}-node-nlb-${random_string.tf-nifi-random.result}"
  subnets                          = [aws_subnet.tf-nifi-pubnet1.id, aws_subnet.tf-nifi-pubnet2.id, aws_subnet.tf-nifi-pubnet3.id]
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = "true"
  tags = {
    Name = "${var.name_prefix}-node-nlb-${random_string.tf-nifi-random.result}"
  }
}

resource "aws_lb_listener" "tf-nifi-mgmt-listen-tcp" {
  port              = var.web_port
  protocol          = "TCP"
  load_balancer_arn = aws_lb.tf-nifi-node-nlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn
  }
}

resource "aws_lb_target_group" "tf-nifi-mgmt-target-tcp" {
  port                 = var.web_port
  name                 = "${var.name_prefix}-mgmt-${var.web_port}-${random_string.tf-nifi-random.result}"
  protocol             = "TCP"
  vpc_id               = aws_vpc.tf-nifi-vpc.id
  preserve_client_ip   = "true"
  deregistration_delay = 10
  stickiness {
    enabled = "true"
    type    = "source_ip"
  }
  health_check {
    enabled             = "true"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    protocol            = "TCP"
  }
}

resource "aws_lb_listener" "tf-nifi-zk-listen-tcp" {
  port              = "2173"
  protocol          = "TCP"
  load_balancer_arn = aws_lb.tf-nifi-node-nlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-nifi-zk-target-tcp.arn
  }
}

resource "aws_lb_target_group" "tf-nifi-zk-target-tcp" {
  port                 = "2173"
  name                 = "${var.name_prefix}-zk-${var.web_port}-${random_string.tf-nifi-random.result}"
  protocol             = "TCP"
  vpc_id               = aws_vpc.tf-nifi-vpc.id
  preserve_client_ip   = "true"
  deregistration_delay = 10
  stickiness {
    enabled = "true"
    type    = "source_ip"
  }
  health_check {
    enabled             = "true"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    protocol            = "TCP"
  }
}

resource "aws_lb_listener" "tf-nifi-service-listen-tcp" {
  count             = length(var.tcp_service_ports)
  port              = var.tcp_service_ports[count.index]
  protocol          = "TCP"
  load_balancer_arn = aws_lb.tf-nifi-node-nlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-nifi-service-target-tcp[count.index].arn
  }
}

resource "aws_lb_listener" "tf-nifi-service-listen-udp" {
  count             = length(var.udp_service_ports)
  port              = var.udp_service_ports[count.index]
  protocol          = "UDP"
  load_balancer_arn = aws_lb.tf-nifi-node-nlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-nifi-service-target-udp[count.index].arn
  }
}

resource "aws_lb_listener" "tf-nifi-service-listen-tcpudp" {
  count             = length(var.tcpudp_service_ports)
  port              = var.tcpudp_service_ports[count.index]
  protocol          = "TCP_UDP"
  load_balancer_arn = aws_lb.tf-nifi-node-nlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-nifi-service-target-tcpudp[count.index].arn
  }
}

resource "aws_lb_target_group" "tf-nifi-service-target-tcp" {
  count                = length(var.tcp_service_ports)
  port                 = var.tcp_service_ports[count.index]
  name                 = "${var.name_prefix}-tcp-${var.tcp_service_ports[count.index]}-${random_string.tf-nifi-random.result}"
  protocol             = "TCP"
  vpc_id               = aws_vpc.tf-nifi-vpc.id
  preserve_client_ip   = "true"
  deregistration_delay = 10
  health_check {
    enabled             = "true"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    protocol            = "TCP"
  }
}

resource "aws_lb_target_group" "tf-nifi-service-target-udp" {
  count                = length(var.udp_service_ports)
  port                 = var.udp_service_ports[count.index]
  name                 = "${var.name_prefix}-udp-${var.udp_service_ports[count.index]}-${random_string.tf-nifi-random.result}"
  protocol             = "UDP"
  vpc_id               = aws_vpc.tf-nifi-vpc.id
  preserve_client_ip   = "true"
  deregistration_delay = 10
  health_check {
    enabled             = "true"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    port                = var.web_port
    protocol            = "TCP"
  }
}

resource "aws_lb_target_group" "tf-nifi-service-target-tcpudp" {
  count                = length(var.tcpudp_service_ports)
  port                 = var.tcpudp_service_ports[count.index]
  name                 = "${var.name_prefix}-tcpudp-${var.tcpudp_service_ports[count.index]}-${random_string.tf-nifi-random.result}"
  protocol             = "TCP_UDP"
  vpc_id               = aws_vpc.tf-nifi-vpc.id
  preserve_client_ip   = "true"
  deregistration_delay = 10
  health_check {
    enabled             = "true"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    port                = var.web_port
    protocol            = "TCP"
  }
}
