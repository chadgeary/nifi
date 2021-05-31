resource "aws_iam_policy" "zk-codepipe-policy" {
  name   = "${var.name_prefix}-codepipe-policy-${random_string.tf-nifi-random.result}"
  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": ["arn:aws:iam::*:role/${var.name_prefix}-codepipe-${random_string.tf-nifi-random.result}"],
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "codepipeline.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "${aws_codebuild_project.zk-codebuild.arn}",
            "Effect": "Allow"
        },
        {
            "Sid": "ObjectsinBucketPrefix",
            "Effect": "Allow",
            "Action": [
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
                "kms:ReEncrypt*",
                "kms:Decrypt",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": ["${aws_kms_key.zk-kmscmk-s3.arn}"]
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role" "zk-codepipe-role" {
  name               = "${var.name_prefix}-codepipe-${random_string.tf-nifi-random.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "Codepipeline"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "zk-codepipe-policy-role-attach" {
  role       = aws_iam_role.zk-codepipe-role.name
  policy_arn = aws_iam_policy.zk-codepipe-policy.arn
}
