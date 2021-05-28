resource "aws_codebuild_project" "zk-codebuild" {
  name                    = "${var.name_prefix}-codebuild-${random_string.zk-random.result}"
  description             = "Codebuild for CodePipe to ECS"
  build_timeout           = "10"
  service_role            = aws_iam_role.zk-codebuild-role.arn
  encryption_key          = aws_kms_key.zk-kmscmk-code.arn
  artifacts {
    type                    = "CODEPIPELINE"
  }
  # https://github.com/hashicorp/terraform-provider-aws/issues/10195
  environment {
    compute_type            = "BUILD_GENERAL1_SMALL"
    image                   = "aws/codebuild/standard:5.0"
    type                    = "LINUX_CONTAINER"
    privileged_mode         = "true"
    environment_variable {
      name                    = "AWS_DEFAULT_REGION"
      value                   = var.aws_region
    }
    environment_variable {
      name                    = "AWS_ACCOUNT_ID"
      value                   = data.aws_caller_identity.zk-aws-account.account_id
    }
    environment_variable {
      name                    = "IMAGE_REPO_NAME"
      value                   = aws_ecr_repository.zk-repo.name
    }
    environment_variable {
      name                    = "IMAGE_TAG"
      value                   = "latest"
    }
  }  
  source {
    type                      = "CODEPIPELINE"
  }
  logs_config {
    s3_logs {
      status                  = "ENABLED"
      location                = "${aws_s3_bucket.zk-bucket.id}/build-log"
    }
  }
  vpc_config {
    vpc_id                    = aws_vpc.zk-vpc.id
    subnets                   = [
      aws_subnet.zk-netC.id,
      aws_subnet.zk-netD.id
    ]
    security_group_ids        = [aws_security_group.zk-sg-private.id]
  }
  depends_on                = [aws_security_group_rule.zk-sg-private-tcp-out, aws_security_group_rule.zk-sg-private-udp-out, aws_nat_gateway.zk-natgwAC, aws_nat_gateway.zk-natgwBD, aws_vpc_endpoint.zk-vpc-s3-endpointABCD, aws_iam_role_policy_attachment.zk-codebuild-policy-role-attach]
}
