resource "aws_s3_bucket" "zk-bucket" {
  bucket = "${var.name_prefix}-zk-bucket-${random_string.tf-nifi-random.result}"
  acl    = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.zk-kmscmk-s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  force_destroy = true
  policy        = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KMS Manager",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${data.aws_iam_user.tf-nifi-kmsmanager.arn}"]
      },
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-zk-bucket-${random_string.tf-nifi-random.result}",
        "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-zk-bucket-${random_string.tf-nifi-random.result}/*"
      ]
    },
    {
      "Sid": "Codepipe",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.zk-codepipe-role.arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:PutObjectACL"
      ],
      "Resource": ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-zk-bucket-${random_string.tf-nifi-random.result}","arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-zk-bucket-${random_string.tf-nifi-random.result}/*"]
    },
    {
      "Sid": "Codebuild",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.zk-codebuild-role.arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:PutObjectACL"
      ],
      "Resource": ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-zk-bucket-${random_string.tf-nifi-random.result}","arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-zk-bucket-${random_string.tf-nifi-random.result}/*"]
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "zk-bucket-pub-access" {
  bucket                  = aws_s3_bucket.zk-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "null_resource" "zk-s3-codebuild-checksum" {
  triggers = {
    buildspec  = filebase64sha256("zk-files/buildspec.yml")
    dockerfile = filebase64sha256("zk-files/Dockerfile")
  }
}

data "archive_file" "zk-s3-codebuild-archive" {
  type        = "zip"
  source_dir  = "zk-files/"
  output_path = "zookeeper.zip"
  depends_on  = [null_resource.zk-s3-codebuild-checksum]
}

resource "aws_s3_bucket_object" "zk-s3-codebuild-object" {
  bucket         = aws_s3_bucket.zk-bucket.id
  key            = "zk-files/zookeeper.zip"
  content_base64 = filebase64("zookeeper.zip")
}
