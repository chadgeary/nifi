output "tf-nifi-output" {
  value = <<OUTPUT

# NiFi can take 15+ minutes to initialize a cluster, please be patient.
# State Manager Association will show Status: Complete, then
# NLB Target Group will show Status: healthy

## NiFi ##
State Manager Association:
  https://console.aws.amazon.com/systems-manager/state-manager/${aws_ssm_association.tf-nifi-nodes-ssm-assoc.association_id}/executionhistory
Cloudwatch Logs:
  https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/$252Faws$252Fec2$252F${var.name_prefix}_${random_string.tf-nifi-random.result}
Admin Certificate:
  https://s3.console.aws.amazon.com/s3/object/${aws_s3_bucket.tf-nifi-bucket.id}?region=${var.aws_region}&prefix=nifi/certificates/admin/keystore.p12
WebUI:
  https://${aws_lb.tf-nifi-node-nlb.dns_name}:${var.web_port}/nifi
Maintenance:
  Instance IDs in Cluster:
    AWS_PROFILE=${var.aws_profile} aws ec2 describe-instances --region ${var.aws_region} --query 'Reservations[].Instances[*].[InstanceId, LaunchTime, [Tags[?Key==`Name`].Value][0][0]]' --filters Name=tag:Cluster,Values=${var.name_prefix}_${random_string.tf-nifi-random.result} Name=instance-state-name,Values=pending,running --output text
  Connecting via SSM, append an instance id from the previous command:
    AWS_PROFILE=${var.aws_profile} aws ssm start-session --region ${var.aws_region} --target 
  Re-run Ansible on NiFi Nodes, e.g.: update playbook files, re-run terraform apply, then run below command to re-apply ansible.
    AWS_PROFILE=${var.aws_profile} aws ssm start-associations-once --region ${var.aws_region} --association-ids ${aws_ssm_association.tf-nifi-nodes-ssm-assoc.association_id}

## Zookeeper ##
Code Pipeline:
  https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${var.name_prefix}-codepipe-${random_string.tf-nifi-random.result}/view?region=${var.aws_region}
Cloudwatch Logs:
  https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/$252Faws$252Fecs$252F${var.name_prefix}_${random_string.tf-nifi-random.result}
Cluster Service(s):
  https://console.aws.amazon.com/ecs/home?region=${var.aws_region}#/clusters/${var.name_prefix}-ecscluster-${random_string.tf-nifi-random.result}/tasks

OUTPUT
}
