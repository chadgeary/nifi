import boto3
import json
import os
from urllib.request import urlopen
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def lambda_handler(event, context):

    # Admin Certificate
    s3 = boto3.client('s3')
    with open('/tmp/admin_cert.pem', 'wb') as data:
        s3.download_fileobj(os.environ['PREFIX'] + '-bucket-' + os.environ['SUFFIX'],'nifi/certificates/admin/admin_cert.pem', data)
    with open('/tmp/private_key.key', 'wb') as data:
        s3.download_fileobj(os.environ['PREFIX'] + '-bucket-' + os.environ['SUFFIX'],'nifi/certificates/admin/private_key.key', data)

    # Get key's secret via ssm
    ssm = boto3.client("ssm", region_name=os.environ["REGION"])
    ssm_secret = ssm.get_parameter(
        Name=os.environ["PREFIX"] + "-nifi-secret-" + os.environ["SUFFIX"],
        WithDecryption=True,
    )
    secret = ssm_secret["Parameter"]["Value"]

    # EC2 instances
    ec2 = boto3.client('ec2')
    http = urllib3.PoolManager(cert_reqs='CERT_NONE', cert_file='/tmp/admin_cert.pem', key_file='/tmp/private_key.key', key_password=secret)
    cluster_filter = [
        {
            'Name': 'tag:Cluster',
            'Values': [os.environ['PREFIX'] + '_' + os.environ['SUFFIX']]
        },
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]
    response = ec2.describe_instances(Filters=cluster_filter)

    # Autoscaling group(s)
    asg = boto3.client('autoscaling')

    health = []
    try:
        for reservation in response['Reservations']:
            if len(reservation['Instances']) < 1:
                print("No instances, skipping")
            else:
                for instance in reservation['Instances']:
                    for interface in instance['NetworkInterfaces']:
                        try:
                            health_check = http.request('GET', 'https://' + interface['PrivateDnsName'] + ':' + os.environ['WEB_PORT'] + '/nifi', preload_content=False)
                            health.append({instance['InstanceId']: health_check.status})

                        except:
                            print(instance['InstanceId'] + ': UNHEALTHY')
                            set_health = asg.set_instance_health(
                                HealthStatus='Unhealthy',
                                InstanceId=instance['InstanceId'],
                                ShouldRespectGracePeriod=True
                            )

                        else:
                            print(instance['InstanceId'] + ': HEALTHY')
                            set_health = asg.set_instance_health(
                                HealthStatus='Healthy',
                                InstanceId=instance['InstanceId'],
                                ShouldRespectGracePeriod=True
                            )
                        
    except Exception as e:
        print(e)
                        
    return {
        'statusCode': 200,
        'body': json.dumps(health)
    }
