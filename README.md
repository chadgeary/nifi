# Reference
Terraform to create/manage an AWS-based Apache NiFi stack from scratch.

# Deploy
```
# Set vars in .tfvars file
vi tf-nifi.tfvars

# Initialize terraform
terraform init

# Apply terraform
terraform apply -var-file="tf-nifi.tfvars"
```
