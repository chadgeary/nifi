resource "aws_codepipeline" "zk-codepipe" {
  name     = "${var.name_prefix}-codepipe-${random_string.tf-nifi-random.result}"
  role_arn = aws_iam_role.zk-codepipe-role.arn
  artifact_store {
    location = aws_s3_bucket.zk-bucket.bucket
    type     = "S3"
    encryption_key {
      id   = aws_kms_key.zk-kmscmk-s3.arn
      type = "KMS"
    }
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      output_artifacts = ["source_output"]
      version          = "1"
      configuration = {
        S3Bucket             = aws_s3_bucket.zk-bucket.bucket
        S3ObjectKey          = "zk-files/zookeeper.zip"
        PollForSourceChanges = "Yes"
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.zk-codebuild.name
      }
    }
  }
  depends_on = [aws_iam_role_policy_attachment.zk-codepipe-policy-role-attach]
}
