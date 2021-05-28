resource "aws_iam_policy" "zk-codebuild-policy" {
  name              = "${var.name_prefix}-codebuild-policy-${random_string.zk-random.result}"
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
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.zk-aws-account.account_id}:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": [
            "${aws_subnet.zk-netC.arn}",
            "${aws_subnet.zk-netD.arn}"
          ],
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    },
    {
        "Sid": "ObjectsinBucketPrefix",
        "Effect": "Allow",
        "Action": [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:PutObject"
        ],
        "Resource": ["${aws_s3_bucket.zk-bucket.arn}","${aws_s3_bucket.zk-bucket.arn}/*"]
    },
    {
        "Sid": "CodeKMSCMK",
        "Effect": "Allow",
        "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
        ],
        "Resource": ["${aws_kms_key.zk-kmscmk-code.arn}"]
    },
    {
        "Sid": "S3KMSCMK",
        "Effect": "Allow",
        "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
        ],
        "Resource": ["${aws_kms_key.zk-kmscmk-s3.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "zk-codebuild-role" {
  name                        = "${var.name_prefix}-codebuild-${random_string.zk-random.result}"
  assume_role_policy          = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "Codebuild"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "zk-codebuild-policy-role-attach" {
  role                    = aws_iam_role.zk-codebuild-role.name
  policy_arn              = aws_iam_policy.zk-codebuild-policy.arn
}

