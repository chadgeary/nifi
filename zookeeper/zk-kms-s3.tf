resource "aws_kms_key" "zk-kmscmk-s3" {
  description             = "KMS CMK for S3"
  key_usage               = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation     = "true"
  tags                    = {
    Name                  = "${var.name_prefix}-kmscmk-s3-${random_string.zk-random.result}"
  }
  policy                  = <<EOF
{
  "Id": "zk-kmscmk-s3",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable S3 Build",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.zk-codebuild-role.arn}"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.zk-aws-account.account_id}"
        }
      }
    },
    {
      "Sid": "Enable S3 Pipe",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.zk-codepipe-role.arn}"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.zk-aws-account.account_id}"
        }
      }
    },
    {
      "Sid": "Enable KMS Manager Use",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.zk-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "zk-kmscmk-s3-alias" {
  name                    = "alias/${var.name_prefix}-kmscmk-s3-${random_string.zk-random.result}"
  target_key_id           = aws_kms_key.zk-kmscmk-s3.key_id
}
