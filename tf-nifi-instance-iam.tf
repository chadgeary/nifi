data "aws_iam_policy" "tf-nifi-instance-policy-ssm" {
  arn                     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "tf-nifi-instance-policy-s3" {
  name                    = "tf-nifi-instance-policy"
  path                    = "/"
  description             = "Provides tf-nifi instances access to endpoint, s3 objects, SSM bucket, and EFS"
  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListObjectsinBucket",
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}"]
    },
    {
      "Sid": "GetObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}/zookeepers/*"]
    },
    {
      "Sid": "PutObjectsinBucketPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": ["${aws_s3_bucket.tf-nifi-bucket.arn}/ssm/*"]
    },
    {
      "Sid": "EFSMountWrite",
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientRootAccess"
      ],
      "Resource": ["${aws_efs_file_system.tf-nifi-efs.arn}"]
    },
    {
      "Sid": "KMSforCMK",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_alias.tf-nifi-kmscmk-alias.arn}","${aws_kms_key.tf-nifi-kmscmk.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "tf-nifi-instance-iam-role" {
  name                    = "tf-nifi-instance-profile"
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

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-ssm" {
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn              = data.aws_iam_policy.tf-nifi-instance-policy-ssm.arn
}

resource "aws_iam_role_policy_attachment" "tf-nifi-iam-attach-s3" {
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
  policy_arn              = aws_iam_policy.tf-nifi-instance-policy-s3.arn
}

resource "aws_iam_instance_profile" "tf-nifi-instance-profile" {
  name                    = "tf-nifi-instance-profile"
  role                    = aws_iam_role.tf-nifi-instance-iam-role.name
}
