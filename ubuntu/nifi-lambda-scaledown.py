import boto3
import json
import os

def lambda_handler(event, context):

    # message from SNS
    message = json.loads(event['Records'][0]['Sns']['Message'])
    print(message)

    ssm = boto3.client('ssm')

    try:
        response = ssm.send_command(
            InstanceIds=[message['EC2InstanceId']],
            DocumentName=os.environ['SSMDOCUMENTNAME'],
            Parameters={
                'ASGNAME': [message['AutoScalingGroupName']],
                'LIFECYCLEHOOKNAME': [message['LifecycleHookName']]
            },
            TimeoutSeconds=900
        )
        print(response)
    except Exception as e:
        print(e)
        return {
            'statusCode': 400,
            'body': json.dumps(message)
        }
    else:
        print(response)
        return {
            'statusCode': 200,
            'body': json.dumps(message)
        }
