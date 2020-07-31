# load balancer
resource "aws_elb" "tf-nifi-elb1" {
  name                    = "tf-nifi-elb"
  subnets                 = [aws_subnet.tf-nifi-pubnet1.id, aws_subnet.tf-nifi-pubnet2.id, aws_subnet.tf-nifi-pubnet3.id]
  security_groups         = [aws_security_group.tf-nifi-pubsg1.id]
  listener {
    instance_port           = 22
    instance_protocol       = "TCP"
    lb_port                 = 22
    lb_protocol             = "TCP"
  }
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

# zookeeper attachments
resource "aws_elb_attachment" "tf-nifi-1-elb-attach" {
  elb                     = aws_elb.tf-nifi-elb1.id
  instance                = aws_instance.tf-nifi-1.id
}

resource "aws_elb_attachment" "tf-nifi-2-elb-attach" {
  elb                     = aws_elb.tf-nifi-elb1.id
  instance                = aws_instance.tf-nifi-2.id
}

resource "aws_elb_attachment" "tf-nifi-3-elb-attach" {
  elb                     = aws_elb.tf-nifi-elb1.id
  instance                = aws_instance.tf-nifi-3.id
}
