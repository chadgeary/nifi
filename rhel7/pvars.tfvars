# aws profile (e.g. from aws configure, usually "default")
aws_profile = "default"
aws_region = "us-east-1"

# existing aws iam user granted access to the kms key (for browsing KMS encrypted services like S3 or SNS).
kms_manager = "chad_geary"

# the subnet permitted to browse nifi (port 443) via the AWS ELB
mgmt_cidr = "143.59.135.164/32"

# public ssh key
instance_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCNsxnMWfrG3SoLr4uJMavf43YkM5wCbdO7X5uBvRU8oh1W+A/Nd/jie2tc3UpwDZwS3w6MAfnu8B1gE9lzcgTu1FFf0us5zIWYR/mSoOFKlTiaI7Uaqkc+YzmVw/fy1iFxDDeaZfoc0vuQvPr+LsxUL5UY4ko4tynCSp7zgVpot/OppqdHl5J+DYhNubm8ess6cugTustUZoDmJdo2ANQENeBUNkBPXUnMO1iulfNb6GnwWJ0Z5TRRLGSu1gya2wMLeo1rBJFcb6ZgVLMVHiKgwBy/svUQreR8R+fpVW+Q4rx6RSAltLROUONn0SF2BvvJUueqxpAIaA2rU4MSI69P"

# size according to workloads, t3a.small is -just- enough
instance_type = "t3a.small"

# the root block size of the instances (in GiB)
instance_vol_size = 15

# a short alpha-numeric and hyphens name prefix for various resources (e.g. AMI, instances, roles)
name_prefix = "nifi"

# the vendor supplying the AMI and the AMI name - RHEL7 Latest
vendor_ami_account_number = "309956199498"
vendor_ami_name_string = "RHEL-7.*_HVM_GA-20*-x86_64-0-Hourly2-GP2"

# nifi/nifi-toolkit and zookeeper versions downloaded from https://archive.apache.org/dist/
nifi_version = "1.13.0"
zk_version = "3.6.2"

# vpc specific vars, modify these values if there would be overlap with existing resources.
vpc_cidr = "10.10.19.0/24"
pubnet1_cidr = "10.10.19.0/28"
pubnet2_cidr = "10.10.19.16/28"
pubnet3_cidr = "10.10.19.32/28"
prinet1_cidr = "10.10.19.64/26"
prinet2_cidr = "10.10.19.128/26"
prinet3_cidr = "10.10.19.192/26"
zk1_ip = "10.10.19.71"
zk2_ip = "10.10.19.133"
zk3_ip = "10.10.19.197"

# RHEL requires an AMI be created from an EC2 instance ( RHEL AMI -> EC2 Instance -> Encrypted AMI ), instead of a direct AMI-to-AMI copy.
# This is the IP of the instance we create to re-encrypt the AMI for our own use.
encrypted_ami_ip = "10.10.19.72"

# the initial size (min) and max count of non-zookeeper Autoscaling Group NiFi nodes, scale is based on CPU load (see tf-nifi-scaling.tf)
minimum_node_count = 0
maximum_node_count = 0
