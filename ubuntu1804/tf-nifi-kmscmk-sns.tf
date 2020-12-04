resource "aws_kms_key" "tf-nifi-kmscmk-sns" {
  description             = "Key for tf-nifi sns"
  key_usage               = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation     = "true"
  tags                    = {
    Name                  = "tf-nifi-kmscmk-sns"
  }
  policy                  = <<EOF
{
  "Id": "tf-nifi-kmskeypolicy-sns",
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
      "Sid": "Allow access through sns",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
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
          "kms:ViaService": "sns.${var.aws_region}.amazonaws.com",
          "aws:PrincipalArn": "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.tf-nifi-aws-account.account_id}:tf-nifi-sns-node-down"
        }
      }
    },
    {
      "Sid": "Allow encrypt through Autoscaling Lifecycle",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.tf-nifi-autoscale-snsrole.arn}"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "tf-nifi-kmscmk-sns-alias" {
  name                    = "alias/tf-nifi-ksmcmk-sns"
  target_key_id           = aws_kms_key.tf-nifi-kmscmk-sns.key_id
}
