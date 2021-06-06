resource "aws_kms_key" "tf-nifi-kmscmk-cloudwatch" {
  description              = "Key for tf-nifi cloudwatch"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.name_prefix}-kms-cloudwatch-${random_string.tf-nifi-random.result}"
  }
  policy = <<EOF
{
  "Id": "tf-nifi-kmskeypolicy-cloudwatch",
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
      "Sid": "Allow access through cloudwatch",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.aws_region}.amazonaws.com"
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
        "ArnEquals": {
          "kms:EncryptionContext:aws:logs:arn": ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.tf-nifi-aws-account.account_id}:log-group:/aws/ec2/${var.name_prefix}_${random_string.tf-nifi-random.result}","arn:${data.aws_partition.tf-nifi-aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.tf-nifi-aws-account.account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-getnifi-${random_string.tf-nifi-random.result}","arn:${data.aws_partition.tf-nifi-aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.tf-nifi-aws-account.account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-health-${random_string.tf-nifi-random.result}","arn:${data.aws_partition.tf-nifi-aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.tf-nifi-aws-account.account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-scaledown-${random_string.tf-nifi-random.result}","arn:${data.aws_partition.tf-nifi-aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.tf-nifi-aws-account.account_id}:log-group:/aws/lambda/${var.name_prefix}-ecs-zookeepers-${random_string.tf-nifi-random.result}","arn:${data.aws_partition.tf-nifi-aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.tf-nifi-aws-account.account_id}:log-group:/aws/codebuild/${var.name_prefix}-codebuild-${random_string.tf-nifi-random.result}","arn:${data.aws_partition.tf-nifi-aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.tf-nifi-aws-account.account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-certs-${random_string.tf-nifi-random.result}"]
        }
      }
    },
    {
      "Sid": "Allow access through Lambda",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.tf-nifi-iam-role-lambda-health.arn}"
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

resource "aws_kms_alias" "tf-nifi-kmscmk-cloudwatch-alias" {
  name          = "alias/${var.name_prefix}-kms-cloudwatch-${random_string.tf-nifi-random.result}"
  target_key_id = aws_kms_key.tf-nifi-kmscmk-cloudwatch.key_id
}
