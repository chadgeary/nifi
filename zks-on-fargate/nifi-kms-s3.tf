resource "aws_kms_key" "tf-nifi-kmscmk-s3" {
  description              = "Key for tf-nifi s3"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.name_prefix}-kmscmk-s3-${random_string.tf-nifi-random.result}"
  }
  policy = <<EOF
{
  "Id": "tf-nifi-kmskeypolicy-s3",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.tf-nifi-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow EC2 Encrypt",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.tf-nifi-instance-iam-role.arn}"
      },
      "Action": [
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.tf-nifi-aws-account.account_id}",
          "kms:ViaService": "ec2.${var.aws_region}.amazonaws.com"
        }
      }
    },
    {
      "Sid": "Allow Lambda getnifi",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-iam-role-lambda-getnifi-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-getnifi-${random_string.tf-nifi-random.result}"
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
          "kms:CallerAccount": "${data.aws_caller_identity.tf-nifi-aws-account.account_id}"
        }
      }
    },
    {
      "Sid": "Allow Lambda certs",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-iam-role-lambda-certs-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-certs-${random_string.tf-nifi-random.result}"
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
          "kms:CallerAccount": "${data.aws_caller_identity.tf-nifi-aws-account.account_id}"
        }
      }
    },
    {
      "Sid": "Allow Lambda health",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:sts::${data.aws_caller_identity.tf-nifi-aws-account.account_id}:assumed-role/${var.name_prefix}-iam-role-lambda-health-${random_string.tf-nifi-random.result}/${var.name_prefix}-lambda-health-${random_string.tf-nifi-random.result}"
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
          "kms:CallerAccount": "${data.aws_caller_identity.tf-nifi-aws-account.account_id}"
        }
      }
    },
    {
      "Sid": "Allow access through S3",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.tf-nifi-instance-iam-role.arn}"
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
          "kms:CallerAccount": "${data.aws_caller_identity.tf-nifi-aws-account.account_id}",
          "kms:ViaService": "s3.${var.aws_region}.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "tf-nifi-kmscmk-s3-alias" {
  name          = "alias/${var.name_prefix}-ksmcmk-s3-${random_string.tf-nifi-random.result}"
  target_key_id = aws_kms_key.tf-nifi-kmscmk-s3.key_id
}
