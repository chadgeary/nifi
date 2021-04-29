# mgmt load balancer
resource "aws_lb" "tf-nifi-mgmt-nlb" {
  name                    = "${var.name_prefix}-mgmt-nlb-${random_string.tf-nifi-random.result}"
  subnets                 = [aws_subnet.tf-nifi-pubnet1.id, aws_subnet.tf-nifi-pubnet2.id, aws_subnet.tf-nifi-pubnet3.id]
  load_balancer_type      = "network"
  tags                    = {
    Name                    = "${var.name_prefix}-mgmt-nlb-${random_string.tf-nifi-random.result}"
  }
}

resource "aws_lb_listener" "tf-nifi-mgmt-listen-tcp" {
  port                    = var.web_port
  protocol                = "TCP"
  load_balancer_arn       = aws_lb.tf-nifi-mgmt-nlb.arn
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.tf-nifi-mgmt-target-tcp.arn
  }
}

resource "aws_lb_target_group" "tf-nifi-mgmt-target-tcp" {
  port                    = var.web_port
  name                    = "${var.name_prefix}-mgmt-${var.web_port}-${random_string.tf-nifi-random.result}"
  protocol                 = "TCP"
  vpc_id                  = aws_vpc.tf-nifi-vpc.id
  preserve_client_ip      = "true"
  health_check {
    enabled                 = "true"
    healthy_threshold       = 3
    unhealthy_threshold     = 3
    interval                = 10
    protocol                 = "TCP"
  } 
}
