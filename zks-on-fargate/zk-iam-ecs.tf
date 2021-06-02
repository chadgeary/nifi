resource "aws_iam_role" "zk-ecs-role" {
  name               = "${var.name_prefix}-ecsrole-${random_string.tf-nifi-random.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": "ECS"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "zk-ecs-policy" {
  name   = "${var.name_prefix}-ecs-policy-${random_string.tf-nifi-random.result}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "zk-ecs-iam-attach-1" {
  role       = aws_iam_role.zk-ecs-role.name
  policy_arn = aws_iam_policy.zk-ecs-policy.arn
}
