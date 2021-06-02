resource "aws_codebuild_project" "zk-codebuild" {
  name           = "${var.name_prefix}-codebuild-${random_string.tf-nifi-random.result}"
  description    = "Codebuild for CodePipe to ECS"
  build_timeout  = "10"
  service_role   = aws_iam_role.zk-codebuild-role.arn
  encryption_key = aws_kms_key.zk-kmscmk-code.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  # https://github.com/hashicorp/terraform-provider-aws/issues/10195
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = "true"
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.tf-nifi-aws-account.account_id
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.zk-repo.name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }
  source {
    type = "CODEPIPELINE"
  }
  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.zk-bucket.id}/build-log"
    }
  }
  vpc_config {
    vpc_id             = aws_vpc.tf-nifi-vpc.id
    subnets            = [aws_subnet.tf-nifi-prinet1.id, aws_subnet.tf-nifi-prinet2.id, aws_subnet.tf-nifi-prinet3.id]
    security_group_ids = [aws_security_group.zk-prisg.id]
  }
  depends_on = [aws_iam_role_policy_attachment.zk-codebuild-policy-role-attach, aws_cloudwatch_log_group.tf-nifi-cloudwatch-log-group-codebuild, aws_s3_bucket_object.zk-s3-codebuild-object, aws_autoscaling_group.tf-nifi-autoscalegroup]
}
