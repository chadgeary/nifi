# Reference
Terraform with Ansible to create/manage a full AWS-based secure Apache NiFi cluster/stack.

# Requirements
- Terraform installed.
- AWS credentials (e.g. `aws configure` if awscli is installed)
- Customized variables (see Variables section).

# Variables
Edit the vars file (.tfvars) to customize the deployment, especially:
- bucket_name
  - a unique bucket name, terraform will create the bucket to store various resources.
- mgmt_cidr
  - an IP range granted NiFi webUI and EC2 SSH access via the ELB hostname.
  - deploying from home? `dig +short myip.opendns.com @resolver1.opendns.com | awk '{ print $1"/32" }'`
- kms_manager
  - an AWS user account (not root) that will be granted access to the KMS key (to read S3 objects).
- instance_key
  - a public SSH key for SSH access to instances.

# Deploy
```
# Initialize terraform
terraform init

# Apply terraform - the first apply takes a while creating an encrypted AMI.
terraform apply -var-file="tf-nifi.tfvars"

# Wait for SSM Ansible Playbook, watch:
https://console.aws.amazon.com/systems-manager/state-manager
```

# WebUI Access
WebUI access is permitted to the mgmt_cidr defined in tf-nifi.tfvars. Authentication requires the admin password-protected certificate generated by the Ansible playbook:
- Gather keystore.pkcs12 and tls.json from either:
  - An EC2 instance (via ssh) under /mnt/tf/nifi/efs/admin-certificates/, or
  - S3 under <bucket_name defined in tf-nifi.tfvars>/admin-certificates/
- Import keystore.pkcs12 as certificate into Web Browser
  - Use tls.json's keyStorePassword value when prompted for password

# Notes
- AMI is [Latest Official RHEL7](https://access.redhat.com/solutions/15356), but takes a considerable amount of time to clone. This method may change in the future, or Ubuntu may be used.
- The RedHat AMI [has this misconfiguration](https://bugzilla.redhat.com/show_bug.cgi?id=1865991).
