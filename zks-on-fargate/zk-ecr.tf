resource "aws_ecr_repository" "zk-repo" {
  name                 = "${var.name_prefix}-repo-${random_string.tf-nifi-random.result}"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.zk-kmscmk-ecr.arn
  }
}
