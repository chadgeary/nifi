# Reference
Terraform with Ansible to create/manage a fullstack AWS-based secure Apache NiFi cluster.

# Deploy
```
# Set vars in .tfvars file - mgmt_cidr is granted WebUI access.
vi tf-nifi.tfvars

# Initialize terraform
terraform init

# Apply terraform
terraform apply -var-file="tf-nifi.tfvars"
```

# WebUI Access
```
# Import to browser
/mnt/tf-nifi-efs/admin-certificates/keystore.pkcs12

# with keyStorePassword in
/mnt/tf-nifi-efs/admin-certificates/tls.json
```

# Todo
- Autoscaling

# Notes
- AMI for nodes is RHEL7
- Zookeepers/ is the Ansible playbook for NiFi (w/ Zookeeper)
- Watch [SSM State Manager](https://console.aws.amazon.com/systems-manager/state-manager) and/or [ELB Instances](https://console.aws.amazon.com/ec2/v2/home?LoadBalancers%3Asort=loadBalancerName#LoadBalancers:sort=loadBalancerName) for Node status. 
