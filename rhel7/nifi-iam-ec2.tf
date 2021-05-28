data "aws_iam_policy" "tf-nifi-instance-policy-ssm" {
  arn = "arn:${data.aws_partition.tf-nifi-aws-partition.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "tf-nifi-instance-policy-s3" {
  name        = "${var.name_prefix}-instance-policy-s3-${random_string.tf-nifi-random.result}"
  path        = "/"
  description = "Provides tf-nifi instances access to endpoint, s3 objects/bucket"
  policy      = <<EOF
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
      "Sid": "S3CMK",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.tf-nifi-kmscmk-s3.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:CreateLogGroup"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "tf-nifi-instance-policy-lifecycle" {
  name        = "${var.name_prefix}-instance-policy-lifecycle-${random_string.tf-nifi-random.result}"
  path        = "/"
  description = "Provides tf-nifi instances complete autoscale lifecycle"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CompleteAutoScale",
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

resource "aws_iam_policy" "tf-nifi-instance-policy-route53" {
  name        = "${var.name_prefix}-instance-policy-route53-${random_string.tf-nifi-random.result}"
  path        = "/"
  description = "Provides tf-nifi instances update route53 records"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "UpdateRoute53",
      "Effect": "Allow",
      "Action": ["route53:ChangeResourceRecordSets"],
      "Resource": ["arn:${data.aws_partition.tf-nifi-aws-partition.partition}:route53:::hostedzone/${aws_route53_zone.tf-nifi-r53-zone.zone_id}"]
    },
    {
      "Sid": "ListRoute53",
      "Effect": "Allow",
      "Action": ["route53:ListHostedZonesByName","route53:ListHostedZones","route53:ListResourceRecordSets"],
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "tf-nifi-instance-iam-role" {
  name               = "${var.name_prefix}-instance-role-${random_string.tf-nifi-random.result}"
  path               = "/"
  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-ssm" {
  role       = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn = data.aws_iam_policy.tf-nifi-instance-policy-ssm.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-s3" {
  role       = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn = aws_iam_policy.tf-nifi-instance-policy-s3.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-lifecycle" {
  role       = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn = aws_iam_policy.tf-nifi-instance-policy-lifecycle.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-route53" {
  role       = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn = aws_iam_policy.tf-nifi-instance-policy-route53.arn
}

resource "aws_iam_instance_profile" "tf-nifi-instance-profile" {
  name = "${var.name_prefix}-instance-profile-${random_string.tf-nifi-random.result}"
  role = aws_iam_role.tf-nifi-instance-iam-role.name
}
