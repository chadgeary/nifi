# s3 bucket
resource "aws_s3_bucket" "tf-nifi-bucket" {
  bucket                  = var.bucket_name
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
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    },
    {
      "Sid": "Instance List",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.tf-nifi-instance-iam-role.arn}"]
      },
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": ["arn:aws:s3:::${var.bucket_name}"]
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
      "Resource": ["arn:aws:s3:::${var.bucket_name}/*"]
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
        "arn:aws:s3:::${var.bucket_name}/nifi/*",
        "arn:aws:s3:::${var.bucket_name}/ssm/*"
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
      "Resource": ["arn:aws:s3:::${var.bucket_name}/nifi/cluster/*"]
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
  for_each                = fileset("zookeepers/", "*")
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  key                     = "nifi/zookeepers/${each.value}"
  content_base64          = base64encode(file("${path.module}/zookeepers/${each.value}"))
  kms_key_id              = aws_kms_key.tf-nifi-kmscmk-s3.arn
}

# s3 objects (nodes playbook)
resource "aws_s3_bucket_object" "tf-nifi-nodes-files" {
  for_each                = fileset("nodes/", "*")
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  key                     = "nifi/nodes/${each.value}"
  content_base64          = base64encode(file("${path.module}/nodes/${each.value}")) 
  kms_key_id              = aws_kms_key.tf-nifi-kmscmk-s3.arn
}
