# load balancer
resource "aws_elb" "tf-nifi-elb2" {
  name                    = "tf-nifi-node-elb"
  subnets                 = [aws_subnet.tf-nifi-pubnet1.id, aws_subnet.tf-nifi-pubnet2.id, aws_subnet.tf-nifi-pubnet3.id]
  security_groups         = [aws_security_group.tf-nifi-pubsg1.id]
  listener {
    instance_port           = 8443
    instance_protocol       = "TCP"
    lb_port                 = 443
    lb_protocol             = "TCP"
  }
  health_check {
    healthy_threshold       = 2
    unhealthy_threshold     = 2
    timeout                 = 3
    target                  = "TCP:8443"
    interval                = 30
  }
}
