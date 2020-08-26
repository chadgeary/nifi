const AWS = require('aws-sdk');
const ssm = new AWS.SSM();

// from lambda environment vars
const SSMDOCUMENTNAME = process.env.SSMDOCUMENTNAME;

// construct sendcommand with document to instance via ssm
const sendCommand = (instanceId, autoScalingGroup, lifecycleHook) => {
  var params = {
    DocumentName: SSMDOCUMENTNAME,
    InstanceIds: [instanceId],
    Parameters: {
      'ASGNAME': [autoScalingGroup],
      'LIFECYCLEHOOKNAME': [lifecycleHook]
    },
    TimeoutSeconds: 900
  };
  return ssm.sendCommand(params).promise();
}

// logging / checking - must be SNS-triggered EC2_INSTANCE_TERMINATING
exports.handler = async (event) => {
  console.log('Received event ', JSON.stringify(event));
  try {
    const records = event.Records;
    if (!records || !records.length) {
      return;
    }
    for (const record of records) {
      if (record.EventSource !== 'aws:sns') {
        console.log('PROBLEM: EventSource is not aws:sns');
        continue;
      }
      const message = JSON.parse(record.Sns.Message);
      if (message.LifecycleTransition !== 'autoscaling:EC2_INSTANCE_TERMINATING') {
        console.log('PROBLEM: LifecycleTransition is not autoscaling:EC2_INSTANCE_TERMINATING');
        continue;
      }
      console.log("OK: Executing sendCommand");
      const autoScalingGroup = message.AutoScalingGroupName;
      const instanceId = message.EC2InstanceId;
      const lifecycleHook = message.LifecycleHookName;
      await sendCommand(instanceId, autoScalingGroup, lifecycleHook);
      console.log('sent command');
    }
  } catch (error) {
      throw error;
  }
}
