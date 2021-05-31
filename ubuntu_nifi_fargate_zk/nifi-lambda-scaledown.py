import boto3
import json
import os

def lambda_handler(event, context):

    # message from SNS
    message = json.loads(event['Records'][0]['Sns']['Message'])
    print(message)

    # Send scaledown document via SSM to instance
    ssm = boto3.client('ssm')
    try:
        ssmresponse = ssm.send_command(
            InstanceIds=[message['EC2InstanceId']],
            DocumentName=os.environ['SSMDOCUMENTNAME'],
            Parameters={
                'ASGNAME': [message['AutoScalingGroupName']],
                'LIFECYCLEHOOKNAME': [message['LifecycleHookName']]
            },
            TimeoutSeconds=900
        )
        print(ssmresponse)
    except Exception as e:
        print(e)
        return {
            'statusCode': 400,
            'body': json.dumps(message)
        }

    else:
        return {
            'statusCode': 200,
            'body': json.dumps(message)
        }
