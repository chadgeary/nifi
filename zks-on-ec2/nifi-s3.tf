# bucket
resource "aws_s3_bucket" "tf-nifi-bucket" {
  bucket        = "${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}"
  force_destroy = true
}

# acl
resource "aws_s3_bucket_acl" "tf-nifi-bucket" {
  bucket = aws_s3_bucket.tf-nifi-bucket.id
  acl    = "private"
}

# versioning
resource "aws_s3_bucket_versioning" "tf-nifi-bucket" {
  bucket = aws_s3_bucket.tf-nifi-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tf-nifi-bucket" {
  bucket = aws_s3_bucket.tf-nifi-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf-nifi-kmscmk-s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# access policy
resource "aws_s3_bucket_policy" "tf-nifi-bucket" {
  bucket = aws_s3_bucket.tf-nifi-bucket.id
  policy = data.aws_iam_policy_document.tf-nifi-bucket.json
}

# public access policy
resource "aws_s3_bucket_public_access_block" "tf-nifi-bucket" {
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# policy
data "aws_iam_policy_document" "tf-nifi-bucket" {
  statement {
    sid     = "KMS Manager"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}",
      "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.tf-nifi-kmsmanager.arn]
    }
  }
  statement {
    sid    = "Instance Lambda getnifi Lambda certs List"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    resources = ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}", "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.tf-nifi-instance-iam-role.arn, "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-iam-role-lambda-getnifi-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-getnifi-${random_string.tf-nifi-random.result}", "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-iam-role-lambda-certs-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-certs-${random_string.tf-nifi-random.result}"]
    }
  }

  statement {
    sid    = "Instance Get"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}", "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.tf-nifi-instance-iam-role.arn]
    }
  }

  statement {
    sid    = "Instance Put"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/*",
      "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/ssm/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.tf-nifi-instance-iam-role.arn]
    }
  }

  statement {
    sid    = "Lambda getnifi Put"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/downloads/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-iam-role-lambda-getnifi-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-getnifi-${random_string.tf-nifi-random.result}"]
    }
  }

  statement {
    sid    = "Lambda certs Put"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/certificates/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-iam-role-lambda-certs-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-certs-${random_string.tf-nifi-random.result}"]
    }
  }

  statement {
    sid    = "Lambda health Get"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = [
      "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/certificates/admin/admin_cert.pem",
      "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/certificates/admin/private_key.key"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-iam-role-lambda-health-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-health-${random_string.tf-nifi-random.result}"]
    }
  }

}

# s3 objects (zookeeper playbook)
resource "aws_s3_object" "tf-nifi-zookeepers-files" {
  for_each       = fileset("playbooks/zookeepers/", "*")
  bucket         = aws_s3_bucket.tf-nifi-bucket.id
  key            = "nifi/zookeepers/${each.value}"
  content_base64 = base64encode(file("${path.module}/playbooks/zookeepers/${each.value}"))
  kms_key_id     = aws_kms_key.tf-nifi-kmscmk-s3.arn
}

# s3 objects (nodes playbook)
resource "aws_s3_object" "tf-nifi-nodes-files" {
  for_each       = fileset("playbooks/nodes/", "*")
  bucket         = aws_s3_bucket.tf-nifi-bucket.id
  key            = "nifi/nodes/${each.value}"
  content_base64 = base64encode(file("${path.module}/playbooks/nodes/${each.value}"))
  kms_key_id     = aws_kms_key.tf-nifi-kmscmk-s3.arn
}
