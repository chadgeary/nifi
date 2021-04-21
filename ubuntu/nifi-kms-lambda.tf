resource "aws_kms_key" "tf-nifi-kmscmk-lambda" {
  description             = "Key for tf-nifi lambda"
  key_usage               = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation     = "true"
  tags                    = {
    Name                  = "tf-nifi-kmscmk-lambda"
  }
  policy                  = <<EOF
{
  "Id": "tf-nifi-kmskeypolicy-lambda",
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
      "Sid": "Allow access through Lambda",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.tf-nifi-lambda-iam-role.arn}"
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
          "kms:ViaService": "lambda.${var.aws_region}.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "tf-nifi-kmscmk-lambda-alias" {
  name                    = "alias/tf-nifi-ksmcmk-lambda"
  target_key_id           = aws_kms_key.tf-nifi-kmscmk-lambda.key_id
}
