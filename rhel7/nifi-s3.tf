# s3 bucket
resource "aws_s3_bucket" "tf-nifi-bucket" {
  bucket                  = "${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}"
  acl                     = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.tf-nifi-kmscmk-s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  force_destroy           = true
  policy                  = <<POLICY
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
        "arn:aws:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}",
        "arn:aws:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/*"
      ]
    },
    {
      "Sid": "Instance and Lambda getnifi List",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.tf-nifi-instance-iam-role.arn}","arn:aws:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-lambda-getnifi-role-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-getnifi-${random_string.tf-nifi-random.result}"]
      },
      "Action": [
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": ["arn:aws:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}","arn:aws:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/downloads/*"]
    },
    {
      "Sid": "Instance Get",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.tf-nifi-instance-iam-role.arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": ["arn:aws:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/*"]
    },
    {
      "Sid": "Instance Put",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.tf-nifi-instance-iam-role.arn}"]
      },
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/*",
        "arn:aws:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/ssm/*"
      ]
    },
    {
      "Sid": "Lambda getnifi Put",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["arn:aws:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-lambda-getnifi-role-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-getnifi-${random_string.tf-nifi-random.result}"]
      },
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:AbortMultipartUpload"
      ],
      "Resource": [
        "arn:aws:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/downloads/*"
      ]
    },
    {
      "Sid": "Instance Delete",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.tf-nifi-instance-iam-role.arn}"]
      },
      "Action": [
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": ["arn:aws:s3:::${var.name_prefix}-bucket-${random_string.tf-nifi-random.result}/nifi/cluster/*"]
    }
  ]
}
POLICY
}

# s3 block all public access to bucket
resource "aws_s3_bucket_public_access_block" "tf-nifi-bucket-pubaccessblock" {
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# s3 objects (zookeeper playbook)
resource "aws_s3_bucket_object" "tf-nifi-zookeepers-files" {
  for_each                = fileset("playbooks/zookeepers/", "*")
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  key                     = "nifi/zookeepers/${each.value}"
  content_base64          = base64encode(file("${path.module}/playbooks/zookeepers/${each.value}"))
  kms_key_id              = aws_kms_key.tf-nifi-kmscmk-s3.arn
}

# s3 objects (nodes playbook)
resource "aws_s3_bucket_object" "tf-nifi-nodes-files" {
  for_each                = fileset("playbooks/nodes/", "*")
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  key                     = "nifi/nodes/${each.value}"
  content_base64          = base64encode(file("${path.module}/playbooks/nodes/${each.value}")) 
  kms_key_id              = aws_kms_key.tf-nifi-kmscmk-s3.arn
}
