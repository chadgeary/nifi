# A
resource "aws_ecs_cluster" "zk-ecs-cluster" {
  name                     = "${var.name_prefix}-ecscluster-${random_string.zk-random.result}"
  capacity_providers       = ["FARGATE"]
  setting {
    name                     = "containerInsights"
    value                    = "enabled"
  }
}

resource "aws_ecs_task_definition" "zk-ecs-taskA" {
  family                   = "${var.name_prefix}-ecsservice-${random_string.zk-random.result}"
  container_definitions    = templatefile("${path.module}/service/serviceA.tpl", {
    name_prefix             = var.name_prefix,
    aws_suffix              = random_string.zk-random.result,
    aws_repo_url            = aws_ecr_repository.zk-repo.repository_url,
    service_cpu             = var.service_cpu
    service_memory          = var.service_memory
    service_port            = var.service_port
    lb_A                    = aws_lb.zk-lbA.dns_name
    lb_B                    = aws_lb.zk-lbB.dns_name
    lb_C                    = aws_lb.zk-lbC.dns_name
  })
  cpu                      = var.service_cpu
  memory                   = var.service_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.zk-ecs-role.arn
  execution_role_arn       = aws_iam_role.zk-ecs-role.arn
  depends_on               = [aws_iam_role_policy_attachment.zk-ecs-iam-attach-1, aws_iam_role_policy_attachment.zk-ecs-iam-attach-2]
}
 
resource "aws_ecs_service" "zk-ecs-serviceA" {
  name                     = "${var.name_prefix}-ecsservice-${random_string.zk-random.result}"
  cluster                  = aws_ecs_cluster.zk-ecs-cluster.id
  task_definition          = aws_ecs_task_definition.zk-ecs-taskA.arn
  desired_count            = var.service_count
  launch_type                = "FARGATE"
  load_balancer {
    target_group_arn         = aws_lb_target_group.zk-lbtgSVC.arn
    container_name           = "${var.name_prefix}-containerA-${random_string.zk-random.result}"
    container_port           = var.service_port
  }
  network_configuration {
    subnets                  = [aws_subnet.zk-netC.id, aws_subnet.zk-netD.id]
    security_groups          = [aws_security_group.zk-sg-private.id]
    assign_public_ip         = false
  }
}
