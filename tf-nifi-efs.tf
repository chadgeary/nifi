resource "aws_efs_file_system" "tf-nifi-efs" {
  creation_token          = "tf-nifi-efs"
  encrypted               = "true"
  kms_key_id              = aws_kms_key.tf-nifi-kmscmk-efs.arn
  tags                    = {
    Name                    = "tf-nifi-efs"
  }
}

resource "aws_efs_file_system_policy" "tf-nifi-efs-policy" {
  file_system_id          = aws_efs_file_system.tf-nifi-efs.id
  policy                  = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "tf-nifi-efs-policy",
  "Statement": [
    {
      "Sid": "tf-nifi-mountwrite",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.tf-nifi-instance-iam-role.arn}"
      },
      "Resource": "${aws_efs_file_system.tf-nifi-efs.arn}",
      "Action": "elasticfilesystem:Client*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "true"
        },
        "StringEquals": {
          "elasticfilesystem:AccessPointArn":"${aws_efs_access_point.tf-nifi-efs-accesspoint.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_efs_access_point" "tf-nifi-efs-accesspoint" {
  file_system_id          = aws_efs_file_system.tf-nifi-efs.id
}

resource "aws_efs_mount_target" "tf-nifi-efs-mounttarget-1" {
  file_system_id          = aws_efs_file_system.tf-nifi-efs.id
  subnet_id               = aws_subnet.tf-nifi-prinet1.id
  security_groups         = [aws_security_group.tf-nifi-prisg1.id]
  ip_address              = var.efs1_ip
}

resource "aws_efs_mount_target" "tf-nifi-efs-mounttarget-2" {
  file_system_id          = aws_efs_file_system.tf-nifi-efs.id
  subnet_id               = aws_subnet.tf-nifi-prinet2.id
  security_groups         = [aws_security_group.tf-nifi-prisg1.id]
  ip_address              = var.efs2_ip
}

resource "aws_efs_mount_target" "tf-nifi-efs-mounttarget-3" {
  file_system_id          = aws_efs_file_system.tf-nifi-efs.id
  subnet_id               = aws_subnet.tf-nifi-prinet3.id
  security_groups         = [aws_security_group.tf-nifi-prisg1.id]
  ip_address              = var.efs3_ip
}
