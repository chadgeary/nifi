# down
# sns topic called by lifecycle hooks
resource "aws_sns_topic" "tf-nifi-sns-scaledown" {
  name              = "${var.name_prefix}-sns-scaledown-${random_string.tf-nifi-random.result}"
  kms_master_key_id = aws_kms_key.tf-nifi-kmscmk-sns.arn
  delivery_policy   = <<EOF
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

# sns subscription for lambda
resource "aws_sns_topic_subscription" "tf-nifi-lambda-sub-sns-scaledown" {
  topic_arn = aws_sns_topic.tf-nifi-sns-scaledown.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.tf-nifi-lambda-scaledown.arn
}

# ssm document run by the lambda function, executes scale-down shell script, then notifies lifecycle hook complete
resource "aws_ssm_document" "tf-nifi-ssmdoc-scaledown" {
  name          = "${var.name_prefix}-ssmdoc-scaledown-${random_string.tf-nifi-random.result}"
  document_type = "Command"
  content       = <<DOC
{
 "schemaVersion": "2.2",
 "description": "Autoscaling for NiFi",
 "parameters": {
  "ASGNAME": {
   "type":"String",
   "description":"ASG Name"
  },
  "LIFECYCLEHOOKNAME": {
   "type":"String",
   "description":"LCH Name"
  }
 },
 "mainSteps": [
  {
   "action": "aws:runShellScript",
   "name": "runShellScript",
   "inputs": {
    "timeoutSeconds": "900",
    "runCommand": [
     "#!/bin/bash",
     "su - nifi",
     "export LIFECYCLEHOOKNAME='{{ LIFECYCLEHOOKNAME }}'",
     "export ASGNAME='{{ ASGNAME }}'",
     "/usr/local/bin/scale-down"
    ]
   }
  }
 ]
}
DOC
}
