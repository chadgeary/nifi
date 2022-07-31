# secret
resource "aws_ssm_parameter" "tf-nifi-secret" {
  name   = "${var.name_prefix}-nifi-secret-${random_string.tf-nifi-random.result}"
  type   = "SecureString"
  key_id = aws_kms_key.tf-nifi-kmscmk-ssm.key_id
  value  = var.nifi_secret
}

# document
resource "aws_ssm_document" "tf-nifi-ssm-playbook-doc" {
  name          = "${var.name_prefix}-ssm-playbook-doc-${random_string.tf-nifi-random.result}"
  document_type = "Command"
  content       = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Ansible Playbooks via SSM - installs/executes Ansible properly on RHEL7",
    "parameters": {
    "SourceType": {
      "description": "(Optional) Specify the source type.",
      "type": "String",
      "allowedValues": [
      "GitHub",
      "S3"
      ]
    },
    "SourceInfo": {
      "description": "Specify 'path'. Important: If you specify S3, then the IAM instance profile on your managed instances must be configured with read access to Amazon S3.",
      "type": "StringMap",
      "displayType": "textarea",
      "default": {}
    },
    "PlaybookFile": {
      "type": "String",
      "description": "(Optional) The Playbook file to run (including relative path). If the main Playbook file is located in the ./automation directory, then specify automation/playbook.yml.",
      "default": "hello-world-playbook.yml",
      "allowedPattern": "[(a-z_A-Z0-9\\-)/]+(.yml|.yaml)$"
    },
    "ExtraVariables": {
      "type": "String",
      "description": "(Optional) Additional variables to pass to Ansible at runtime. Enter key/value pairs separated by a space. For example: color=red flavor=cherry",
      "default": "SSM=True",
      "displayType": "textarea",
      "allowedPattern": "^$|^\\w+\\=[^\\s|:();&]+(\\s\\w+\\=[^\\s|:();&]+)*$"
    },
    "Verbose": {
      "type": "String",
      "description": "(Optional) Set the verbosity level for logging Playbook executions. Specify -v for low verbosity, -vv or vvv for medium verbosity, and -vvvv for debug level.",
      "allowedValues": [
      "-v",
      "-vv",
      "-vvv",
      "-vvvv"
      ],
      "default": "-v"
    }
    },
    "mainSteps": [
    {
      "action": "aws:downloadContent",
      "name": "downloadContent",
      "inputs": {
      "SourceType": "{{ SourceType }}",
      "SourceInfo": "{{ SourceInfo }}"
      }
    },
    {
      "action": "aws:runShellScript",
      "name": "runShellScript",
      "inputs": {
      "runCommand": [
        "#!/bin/bash",
        "# Ensure ansible and unzip are installed",
        "sudo apt-get update",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python3-pip unzip",
        "sudo pip3 install ansible",
        "sudo ansible-galaxy collection install community.crypto",
        "echo \"Running Ansible in `pwd`\"",
        "for zip in $(find -iname '*.zip'); do",
        "  unzip -o $zip",
        "done",
        "PlaybookFile=\"{{PlaybookFile}}\"",
        "if [ ! -f  \"$${PlaybookFile}\" ] ; then",
        "   echo \"The specified Playbook file doesn't exist in the downloaded bundle. Please review the relative path and file name.\" >&2",
        "   exit 2",
        "fi",
        "export AWS_DEFAULT_REGION=${var.aws_region} && export AWS_REGION=${var.aws_region} && ansible-playbook -i \"localhost,\" -c local -e \"{{ExtraVariables}}\" \"{{Verbose}}\" \"$${PlaybookFile}\""
      ]
      }
    }
    ]
  }
DOC
}

# zookeepers
resource "aws_ssm_association" "tf-nifi-zookeepers-ssm-assoc" {
  association_name = "${var.name_prefix}-zk-ssm-assoc-${random_string.tf-nifi-random.result}"
  name             = aws_ssm_document.tf-nifi-ssm-playbook-doc.name
  targets {
    key    = "tag:Name"
    values = ["zk1.${var.name_prefix}${random_string.tf-nifi-random.result}.internal", "zk2.${var.name_prefix}${random_string.tf-nifi-random.result}.internal", "zk3.${var.name_prefix}${random_string.tf-nifi-random.result}.internal"]
  }
  output_location {
    s3_bucket_name = aws_s3_bucket.tf-nifi-bucket.id
    s3_key_prefix  = "ssm"
  }
  parameters = {
    ExtraVariables = "SSM=True zk_version=${var.zk_version} nifi_version=${var.nifi_version} lb_dns=${aws_lb.tf-nifi-node-nlb.dns_name} s3_bucket=${aws_s3_bucket.tf-nifi-bucket.id} kms_key_id=${aws_kms_key.tf-nifi-kmscmk-s3.key_id} name_prefix=${var.name_prefix} name_suffix=${random_string.tf-nifi-random.result} web_port=${var.web_port} aws_region=${var.aws_region} enable_zk1=${var.enable_zk1} enable_zk2=${var.enable_zk2} enable_zk3=${var.enable_zk3}"
    PlaybookFile   = "zookeepers.yml"
    SourceInfo     = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.tf-nifi-bucket.id}/nifi/zookeepers/\"}"
    SourceType     = "S3"
    Verbose        = "-v"
  }
  depends_on = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3, aws_s3_object.tf-nifi-zookeepers-files]
}

# nodes
resource "aws_ssm_association" "tf-nifi-nodes-ssm-assoc" {
  association_name = "${var.name_prefix}-node-ssm-assoc-${random_string.tf-nifi-random.result}"
  name             = aws_ssm_document.tf-nifi-ssm-playbook-doc.name
  targets {
    key    = "tag:Name"
    values = ["node.${var.name_prefix}${random_string.tf-nifi-random.result}.internal"]
  }
  output_location {
    s3_bucket_name = aws_s3_bucket.tf-nifi-bucket.id
    s3_key_prefix  = "ssm"
  }
  parameters = {
    ExtraVariables = "SSM=True nifi_version=${var.nifi_version} lb_dns=${aws_lb.tf-nifi-node-nlb.dns_name} s3_bucket=${aws_s3_bucket.tf-nifi-bucket.id} kms_key_id=${aws_kms_key.tf-nifi-kmscmk-s3.key_id} name_prefix=${var.name_prefix} name_suffix=${random_string.tf-nifi-random.result} web_port=${var.web_port} aws_region=${var.aws_region}"
    PlaybookFile   = "nodes.yml"
    SourceInfo     = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.tf-nifi-bucket.id}/nifi/nodes/\"}"
    SourceType     = "S3"
    Verbose        = "-v"
  }
  depends_on = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3, aws_s3_object.tf-nifi-nodes-files]
}
