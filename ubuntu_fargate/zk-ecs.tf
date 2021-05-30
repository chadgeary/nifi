resource "aws_ecs_cluster" "zk-ecs-cluster" {
  name               = "${var.name_prefix}-ecscluster-${random_string.tf-nifi-random.result}"
  capacity_providers = ["FARGATE"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "zk-ecs-task" {
  for_each = toset(["A", "B", "C"])
  family   = "${var.name_prefix}-ecsservice${each.key}-${random_string.tf-nifi-random.result}"
  container_definitions = templatefile("zk-service${each.key}.tpl",
    {
      name_prefix  = var.name_prefix
      aws_suffix   = random_string.tf-nifi-random.result
      aws_region   = var.aws_region
      aws_repo_url = aws_ecr_repository.zk-repo.repository_url
      zk_portnifi  = var.zk_portnifi
      zkA_port2    = var.zkA_port2
      zkA_port3    = var.zkA_port3
      zkB_port2    = var.zkB_port2
      zkB_port3    = var.zkB_port3
      zkC_port2    = var.zkC_port2
      zkC_port3    = var.zkC_port3
      zk_nlb       = aws_lb.zk-lb.dns_name
    }
  )
  cpu                      = var.zk_cpu
  memory                   = var.zk_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.zk-ecs-role.arn
  execution_role_arn       = aws_iam_role.zk-ecs-role.arn
  depends_on               = [aws_iam_role_policy_attachment.zk-ecs-iam-attach-1]
}

resource "aws_ecs_service" "zk-ecs-serviceA" {
  name            = "${var.name_prefix}-ecsA-${random_string.tf-nifi-random.result}"
  cluster         = aws_ecs_cluster.zk-ecs-cluster.id
  task_definition = aws_ecs_task_definition.zk-ecs-task["A"].arn
  desired_count   = 1
  launch_type     = "FARGATE"
  load_balancer {
    target_group_arn = aws_lb_target_group.zk-lbtg-nifi.arn
    container_name   = "${var.name_prefix}-zk1-${random_string.tf-nifi-random.result}"
    container_port   = 2181
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.zkA-lbtg2.arn
    container_name   = "${var.name_prefix}-zk1-${random_string.tf-nifi-random.result}"
    container_port   = 2888
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.zkA-lbtg3.arn
    container_name   = "${var.name_prefix}-zk1-${random_string.tf-nifi-random.result}"
    container_port   = 3888
  }
  network_configuration {
    subnets          = [aws_subnet.tf-nifi-prinet1.id]
    security_groups  = [aws_security_group.zk-prisg.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn     = aws_service_discovery_service.zk-svcdiscoveryA.arn
  }
}

resource "aws_ecs_service" "zk-ecs-serviceB" {
  name            = "${var.name_prefix}-ecsB-${random_string.tf-nifi-random.result}"
  cluster         = aws_ecs_cluster.zk-ecs-cluster.id
  task_definition = aws_ecs_task_definition.zk-ecs-task["B"].arn
  desired_count   = 1
  launch_type     = "FARGATE"
  load_balancer {
    target_group_arn = aws_lb_target_group.zk-lbtg-nifi.arn
    container_name   = "${var.name_prefix}-zk2-${random_string.tf-nifi-random.result}"
    container_port   = 2181
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.zkB-lbtg2.arn
    container_name   = "${var.name_prefix}-zk2-${random_string.tf-nifi-random.result}"
    container_port   = 2888
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.zkB-lbtg3.arn
    container_name   = "${var.name_prefix}-zk2-${random_string.tf-nifi-random.result}"
    container_port   = 3888
  }
  network_configuration {
    subnets          = [aws_subnet.tf-nifi-prinet2.id]
    security_groups  = [aws_security_group.zk-prisg.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn     = aws_service_discovery_service.zk-svcdiscoveryB.arn
  }
}

resource "aws_ecs_service" "zk-ecs-serviceC" {
  name            = "${var.name_prefix}-ecsC-${random_string.tf-nifi-random.result}"
  cluster         = aws_ecs_cluster.zk-ecs-cluster.id
  task_definition = aws_ecs_task_definition.zk-ecs-task["C"].arn
  desired_count   = 1
  launch_type     = "FARGATE"
  load_balancer {
    target_group_arn = aws_lb_target_group.zk-lbtg-nifi.arn
    container_name   = "${var.name_prefix}-zk3-${random_string.tf-nifi-random.result}"
    container_port   = 2181
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.zkC-lbtg2.arn
    container_name   = "${var.name_prefix}-zk3-${random_string.tf-nifi-random.result}"
    container_port   = 2888
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.zkC-lbtg3.arn
    container_name   = "${var.name_prefix}-zk3-${random_string.tf-nifi-random.result}"
    container_port   = 3888
  }
  network_configuration {
    subnets          = [aws_subnet.tf-nifi-prinet3.id]
    security_groups  = [aws_security_group.zk-prisg.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn     = aws_service_discovery_service.zk-svcdiscoveryC.arn
  }
}
