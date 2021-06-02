resource "aws_iam_service_linked_role" "tf-nifi-autoscale-slr" {
  aws_service_name = "autoscaling.amazonaws.com"
  custom_suffix    = "nifi${random_string.tf-nifi-random.result}"
}

resource "aws_iam_policy" "tf-nifi-autoscale-snspolicy-1" {
  name        = "${var.name_prefix}-autoscale-sns-policy-${random_string.tf-nifi-random.result}"
  path        = "/"
  description = "Provides Autoscaling permission to SNS"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SNSCMK",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.tf-nifi-kmscmk-sns.arn}"]
    },
    {
      "Sid": "SNSPublish",
      "Effect": "Allow",
      "Action": [
        "kms:ListKeys"
      ],
      "Resource": ["*"]
    },
    {
      "Sid": "SNSTopic",
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": ["${aws_sns_topic.tf-nifi-sns-scaledown.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "tf-nifi-autoscale-snsrole" {
  name               = "${var.name_prefix}-autoscale-sns-role-${random_string.tf-nifi-random.result}"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
             "Service": "autoscaling.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-autoscale-sns-1" {
  role       = aws_iam_role.tf-nifi-autoscale-snsrole.name
  policy_arn = aws_iam_policy.tf-nifi-autoscale-snspolicy-1.arn
}
