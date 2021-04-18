# SSM Managed Policy
data "aws_iam_policy" "tf-nifi-instance-policy-ssm" {
  arn                     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Policy S3
resource "aws_iam_policy" "tf-nifi-instance-policy-s3" {
  name                    = "${var.name_prefix}-instance-policy-s3-${random_string.tf-nifi-random.result}"
  path                    = "/"
  description             = "Provides tf-nifi instances access to endpoint, s3 objects/bucket"
  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListObjectsinBucket",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts"
      ],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}"]
    },
    {
      "Sid": "GetObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}/*"]
    },
    {
      "Sid": "PutObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}/nifi/*","${aws_s3_bucket.tf-nifi-bucket.arn}/ssm/*"]
    },
    {
      "Sid": "DelObjectsinClusterPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}/nifi/cluster/*"]
    },
    {
      "Sid": "S3CMK",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.tf-nifi-kmscmk-s3.arn}"]
    }
  ]
}
EOF
}

# Instance Policy Lifecycle
resource "aws_iam_policy" "tf-nifi-instance-policy-lifecycle" {
  name                    = "${var.name_prefix}-instance-policy-lifecycle-${random_string.tf-nifi-random.result}"
  path                    = "/"
  description             = "Provides tf-nifi instances complete autoscale lifecycle"
  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CompleteAutoScale",
      "Effect": "Allow",
      "Action": [
        "autoscaling:CompleteLifecycleAction"
      ],
      "Resource": ["${aws_autoscaling_group.tf-nifi-autoscalegroup.arn}"]
    }
  ]
}
EOF
}

# Instance Role
resource "aws_iam_role" "tf-nifi-instance-iam-role" {
  name                    = "${var.name_prefix}-instance-role-${random_string.tf-nifi-random.result}"
  path                    = "/"
  assume_role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
             "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF
}

# Instance Role Attachments
resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-ssm" {
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn              = data.aws_iam_policy.tf-nifi-instance-policy-ssm.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-s3" {
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn              = aws_iam_policy.tf-nifi-instance-policy-s3.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-lifecycle" {
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn              = aws_iam_policy.tf-nifi-instance-policy-lifecycle.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "tf-nifi-instance-profile" {
  name                    = "${var.name_prefix}-instance-profile-${random_string.tf-nifi-random.result}"
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
}

# Autoscaling Role
resource "aws_iam_service_linked_role" "tf-nifi-autoscale-slr" {
  aws_service_name        = "autoscaling.amazonaws.com"
  custom_suffix           = "tfnifi"
}

# Lambda Managed Policies
data "aws_iam_policy" "tf-nifi-lambda-policy-1" {
  arn                     = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

data "aws_iam_policy" "tf-nifi-lambda-policy-2" {
  arn                     = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Custom Policy
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
      "Resource": ["${aws_autoscaling_group.tf-nifi-autoscalegroup.arn}"]
    }
  ]
}
EOF
}

# Lambda Role
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

# Lambda Role Attachments
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

# Autoscale Lifecycle Custom Policy
resource "aws_iam_policy" "tf-nifi-autoscale-snspolicy-1" {
  name                    = "${var.name_prefix}-autoscale-sns-policy-${random_string.tf-nifi-random.result}"
  path                    = "/"
  description             = "Provides Autoscaling permission to SNS"
  policy                  = <<EOF
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
      "Resource": ["${aws_sns_topic.tf-nifi-sns-node-down.arn}"]
    }
  ]
}
EOF
}

# Autoscale Lifecycle Role
resource "aws_iam_role" "tf-nifi-autoscale-snsrole" {
  name                    = "${var.name_prefix}-autoscale-sns-role-${random_string.tf-nifi-random.result}"
  path                    = "/"
  assume_role_policy      = <<EOF
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

# ASGLifecycle Role Attachments
resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-autoscale-sns-1" {
  role                    = aws_iam_role.tf-nifi-autoscale-snsrole.name
  policy_arn              = aws_iam_policy.tf-nifi-autoscale-snspolicy-1.arn
}
