data "aws_iam_policy" "tf-nifi-lambda-policy-1" {
  arn                     = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

data "aws_iam_policy" "tf-nifi-lambda-policy-2" {
  arn                     = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "tf-nifi-lambda-policy-3" {
  name                    = "${var.name_prefix}-lambda-kms-scaling-policy-${random_string.tf-nifi-random.result}"
  path                    = "/"
  description             = "Provides lambda KMS and Autoscaling permission"
  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LambdaCMK",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.tf-nifi-kmscmk-lambda.arn}"]
    },
    {
      "Sid": "LambdaAutoscale",
      "Effect": "Allow",
      "Action": [
        "kms:ListKeys"
      ],
      "Resource": ["*"]
    },
    {
      "Sid": "AutoscaleLifecycle",
      "Effect": "Allow",
      "Action": [
        "autoscaling:CompleteLifecycleAction"
      ],
      "Resource": ["${aws_autoscaling_group.tf-nifi-autoscalegroup.arn}","${aws_autoscaling_group.tf-nifi-zk1-autoscalegroup.arn}","${aws_autoscaling_group.tf-nifi-zk2-autoscalegroup.arn}","${aws_autoscaling_group.tf-nifi-zk3-autoscalegroup.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "tf-nifi-lambda-iam-role" {
  name                    = "${var.name_prefix}-lambda-role-${random_string.tf-nifi-random.result}"
  path                    = "/"
  assume_role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
             "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-lambda-1" {
  role                    = aws_iam_role.tf-nifi-lambda-iam-role.name
  policy_arn              = data.aws_iam_policy.tf-nifi-lambda-policy-1.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-lambda-2" {
  role                    = aws_iam_role.tf-nifi-lambda-iam-role.name
  policy_arn              = data.aws_iam_policy.tf-nifi-lambda-policy-2.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-lambda-3" {
  role                    = aws_iam_role.tf-nifi-lambda-iam-role.name
  policy_arn              = aws_iam_policy.tf-nifi-lambda-policy-3.arn
}
