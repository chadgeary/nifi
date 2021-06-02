data "aws_iam_policy" "tf-nifi-iam-policy-lambda-scaledown-1" {
  arn = "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:iam::aws:policy/AmazonSSMFullAccess"
}

data "aws_iam_policy" "tf-nifi-iam-policy-lambda-scaledown-2" {
  arn = "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "tf-nifi-iam-policy-lambda-scaledown-3" {
  name        = "${var.name_prefix}-iam-policy-lambda-scaledown-${random_string.tf-nifi-random.result}"
  path        = "/"
  description = "Provides lambda KMS and Autoscaledown permission"
  policy      = <<EOF
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
        "autoscaledown:CompleteLifecycleAction"
      ],
      "Resource": ["${aws_autoscaling_group.tf-nifi-autoscalegroup.arn}","${aws_autoscaling_group.tf-nifi-zk1-autoscalegroup.arn}","${aws_autoscaling_group.tf-nifi-zk2-autoscalegroup.arn}","${aws_autoscaling_group.tf-nifi-zk3-autoscalegroup.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "tf-nifi-iam-role-lambda-scaledown" {
  name               = "${var.name_prefix}-iam-role-lambda-scaledown-${random_string.tf-nifi-random.result}"
  path               = "/"
  assume_role_policy = <<EOF
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
  role       = aws_iam_role.tf-nifi-iam-role-lambda-scaledown.name
  policy_arn = data.aws_iam_policy.tf-nifi-iam-policy-lambda-scaledown-1.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-lambda-2" {
  role       = aws_iam_role.tf-nifi-iam-role-lambda-scaledown.name
  policy_arn = data.aws_iam_policy.tf-nifi-iam-policy-lambda-scaledown-2.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-lambda-3" {
  role       = aws_iam_role.tf-nifi-iam-role-lambda-scaledown.name
  policy_arn = aws_iam_policy.tf-nifi-iam-policy-lambda-scaledown-3.arn
}
