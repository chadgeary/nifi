output "zk-output" {
  value                   = <<OUTPUT
Code Pipeline: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${var.name_prefix}-codepipe-${random_string.zk-random.result}/view?region=${var.aws_region}
Cluster Service: https://console.aws.amazon.com/ecs/home?region=${var.aws_region}#/clusters/${var.name_prefix}-ecscluster-${random_string.zk-random.result}/services/${var.name_prefix}-ecsservice-${random_string.zk-random.result}/tasks
Load Balancer Target Group: https://console.aws.amazon.com/ec2/v2/home?region=${var.aws_region}#TargetGroup:targetGroupArn=${aws_lb_target_group.zk-lbtgSVC.arn}
OUTPUT
}
