# Reference
Terraform to create/manage an AWS-based Apache NiFi stack from scratch.

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
