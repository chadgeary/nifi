# lifecycle hook to terminate
resource "aws_autoscaling_lifecycle_hook" "tf-nifi-lch-node-down" {
  name                    = "tf-nifi-lch-node-down"
  autoscaling_group_name  = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  default_result          = "ABANDON"
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = aws_sns_topic.tf-nifi-sns-node-down.arn
  role_arn                = aws_iam_role.tf-nifi-autoscale-snsrole.arn
}

# sns topic called by lifecycle hook
resource "aws_sns_topic" "tf-nifi-sns-node-down" {
  name                    = "tf-nifi-sns-node-down"
  kms_master_key_id       = aws_kms_key.tf-nifi-kmscmk.arn
  delivery_policy         = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

# lambda function
data "archive_file" "tf-nifi-lambda-file-node-down" {
  type                    = "zip"
  source_file             = "tf-nifi-lambda-node-down.js"
  output_path             = "tf-nifi-lambda-node-down.zip"
}

# lambda called by sns topic
resource "aws_lambda_function" "tf-nifi-lambda-node-down" {
  filename                = "tf-nifi-lambda-node-down.zip"
  source_code_hash        = data.archive_file.tf-nifi-lambda-file-node-down.output_base64sha256
  function_name           = "tf-nifi-lambda-node-down"
  role                    = aws_iam_role.tf-nifi-lambda-iam-role.arn
  handler                 = "tf-nifi-lambda-node-down.handler"
  runtime                 = "nodejs12.x"
  timeout                 = 60
  environment {
    variables               = {
      SNSTARGET               = aws_sns_topic.tf-nifi-sns-node-down.arn
      SSMDOCUMENTNAME         = aws_ssm_document.tf-nifi-ssmdoc-node-down.name
    }
  }
}

# lambda called by sns permission
resource "aws_lambda_permission" "tf-nifi-lambda-permission-node-down" {
  statement_id            = "AllowExecutionFromSNS"
  action                  = "lambda:InvokeFunction"
  function_name           = aws_lambda_function.tf-nifi-lambda-node-down.function_name
  principal               = "sns.amazonaws.com"
  source_arn              = aws_sns_topic.tf-nifi-sns-node-down.arn
}

# ssm document
resource "aws_ssm_document" "tf-nifi-ssmdoc-node-down" {
  name                    = "tf-nifi-ssmdoc-node-down"
  document_type           = "Command"
  content                 = <<DOC
{
 "schemaVersion": "1.2",
 "description": "Autoscaling for NiFi",
 "parameters": {
  "ASGNAME": {
   "type":"String",
   "description":"ASG Name"
  },
  "LIFECYCLEHOOKNAME": {
   "type":"String",
   "description":"LCH Name"
  },
  "SNSTARGET": {
   "type":"String",
   "description":"SNS Target"
  }
 },
 "runtimeConfig": {
  "aws:runShellScript": {
   "properties": [{
    "id": "0.aws:runShellScript",
    "runCommand": [
     "",
     "#!/bin/bash",
     "INSTANCEID=$(curl http://169.254.169.254/latest/meta-data/instance-id)",
     "HOOKRESULT='CONTINUE'",
     "REGION=$(curl -s 169.254.169.254/latest/meta-data/placement/availability-zones | sed 's/.$//')",
     "/bin/pip install --user awscli",
     "/usr/local/bin/scale-down",
     "/usr/local/bin/aws autoscaling complete-lifecycle-action --lifecycle-hook-name {{LIFECYCLEHOOKNAME}} --auto-scaling-group-name {{ASGNAME}} --lifecycle-action-result $${HOOKRESULT} --instance-id $${INSTANCEID} --region $${REGION}"
    ]
   }]
  }
 }
}
DOC
}
