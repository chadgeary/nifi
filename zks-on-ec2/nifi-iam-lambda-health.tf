data "aws_iam_policy" "tf-nifi-iam-policy-lambda-health-1" {
  arn = "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:iam::aws:policy/AmazonSSMFullAccess"
}

data "aws_iam_policy" "tf-nifi-iam-policy-lambda-health-2" {
  arn = "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "tf-nifi-iam-policy-lambda-health-3" {
  name        = "${var.name_prefix}-iam-policy-lambda-health-${random_string.tf-nifi-random.result}"
  path        = "/"
  description = "Provides lambda EC2 and InstanceHealth permission"
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
      "Sid": "SSMCMK",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": ["${aws_kms_key.tf-nifi-kmscmk-ssm.arn}"]
    },
    {
      "Sid": "LambdaEC2",
      "Effect": "Allow",
      "Action": [
        "kms:ListKeys",
        "ec2:DescribeInstances",
        "ec2:DescribeTags"
      ],
      "Resource": ["*"]
    },
    {
      "Sid": "S3CMK",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.tf-nifi-kmscmk-s3.arn}"]
    },
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
        "s3:GetObjectAcl"
      ],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}/nifi/certificates/admin/admin_cert.pem","${aws_s3_bucket.tf-nifi-bucket.arn}/nifi/certificates/admin/private_key.key"]
    },
    {
      "Sid": "SetInstanceHealth",
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetInstanceHealth"
      ],
      "Resource": ["${aws_autoscaling_group.tf-nifi-autoscalegroup.arn}","${aws_autoscaling_group.tf-nifi-zk1-autoscalegroup.arn}","${aws_autoscaling_group.tf-nifi-zk2-autoscalegroup.arn}","${aws_autoscaling_group.tf-nifi-zk3-autoscalegroup.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "tf-nifi-iam-role-lambda-health" {
  name               = "${var.name_prefix}-iam-role-lambda-health-${random_string.tf-nifi-random.result}"
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

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-health-lambda-1" {
  role       = aws_iam_role.tf-nifi-iam-role-lambda-health.name
  policy_arn = data.aws_iam_policy.tf-nifi-iam-policy-lambda-health-1.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-health-lambda-2" {
  role       = aws_iam_role.tf-nifi-iam-role-lambda-health.name
  policy_arn = data.aws_iam_policy.tf-nifi-iam-policy-lambda-health-2.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-health-lambda-3" {
  role       = aws_iam_role.tf-nifi-iam-role-lambda-health.name
  policy_arn = aws_iam_policy.tf-nifi-iam-policy-lambda-health-3.arn
}
