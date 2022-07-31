resource "aws_kms_key" "tf-nifi-kmscmk-ssm" {
  description              = "Key for tf-nifi ssm"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.name_prefix}-kmscmk-ssm-${random_string.tf-nifi-random.result}"
  }
  policy = <<EOF
{
  "Id": "tf-nifi-kmskeypolicy-ssm",
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
      "Sid": "Allow access through EC2",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.tf-nifi-instance-iam-role.arn}"
      },
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.tf-nifi-aws-account.account_id}",
          "kms:ViaService": "ssm.${var.aws_region}.amazonaws.com"
        }
      }
    },
    {
      "Sid": "Allow access through Lambda certs",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.tf-nifi-iam-role-lambda-certs.arn}"
      },
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.tf-nifi-aws-account.account_id}",
          "kms:ViaService": "ssm.${var.aws_region}.amazonaws.com"
        }
      }
    },
    {
      "Sid": "Allow access through Lambda health",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.tf-nifi-iam-role-lambda-health.arn}"
      },
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.tf-nifi-aws-account.account_id}",
          "kms:ViaService": "ssm.${var.aws_region}.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "tf-nifi-kmscmk-ssm-alias" {
  name          = "alias/${var.name_prefix}-ksmcmk-ssm-${random_string.tf-nifi-random.result}"
  target_key_id = aws_kms_key.tf-nifi-kmscmk-ssm.key_id
}
