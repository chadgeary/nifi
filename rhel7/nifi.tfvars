# aws profile (e.g. from aws configure, usually "default")
aws_profile = "default"
aws_region = "us-east-1"

# existing aws iam user granted access to the kms key (for browsing KMS encrypted services like S3 or SNS).
kms_manager = "some_iam_user"

# the subnet permitted to browse nifi (port 443) via the AWS ELB
mgmt_cidr = "127.0.0.0/30"

# public ssh key
instance_key = "ssh-rsa AAAAB3NzaD2yc2EAAAADAQABAAABAQCNsxnMWfrG3SoLr4uJMavf43YkM5wCbdO7X5uBvRU8oh1W+A/Nd/jie2tc3UpwDZwS3w6MAfnu8B1gE9lzcgTu1FFf0us5zIWYR/mSoOFKlTiaI7Uaqkc+YzmVw/fy1iFxDDeaZfoc0vuQvPr+LsxUL5UY4ko4tynCSp7zgVpot/OppqdHl5J+DYhNubm8ess6cugTustUZoDmJdo2ANQENeBUNkBPXUnMO1iulfNb6GnwWJ0Z5TRRLGSu2gya2wMLeo1rBJ5cbZZgVLMVHiKgwBy/svUQreR8R+fpVW+Q4rx6sPAltLaOUONn0SF2BvvJUueqxpAIaA2rU4MS420P"

# size according to workloads, must be x86 based with at least 2GB of RAM (which is barely enough).
instance_type = "t3.small"

# the root block size of the instances (in GiB)
instance_vol_size = 15

# the name prefix for the AMI and instances (e.g. "tf-nifi" for "tf-nifi-encrypted-ami", "tf-nifi-zookeeper-1", ...)
name_prefix = "tf-nifi"

# the vendor supplying the AMI and the AMI name - default is official RHEL7
vendor_ami_account_number = "309956199498"
vendor_ami_name_string = "RHEL-7.*_HVM_GA-20*-x86_64-0-Hourly2-GP2"

# nifi/nifi-toolkit and zookeeper versions downloaded from https://archive.apache.org/dist/
nifi_version = "1.13.2"
zk_version = "3.7.0"

# vpc specific vars, modify these values if there would be overlap with existing resources.
vpc_cidr = "10.10.10.0/24"
pubnet1_cidr = "10.10.10.0/28"
pubnet2_cidr = "10.10.10.16/28"
pubnet3_cidr = "10.10.10.32/28"
prinet1_cidr = "10.10.10.64/26"
prinet2_cidr = "10.10.10.128/26"
prinet3_cidr = "10.10.10.192/26"
zk1_ip = "10.10.10.71"
zk2_ip = "10.10.10.133"
zk3_ip = "10.10.10.197"

# RHEL requires an AMI be created from an EC2 instance ( RHEL AMI -> EC2 Instance -> Encrypted AMI ), instead of a direct AMI-to-AMI copy.
# To simplify the codebase, Ubuntu will use the same method, the instance is does not stay powered on.
# This is the IP of the instance.
encrypted_ami_ip = "10.10.10.72"

# the initial size (min) and max count of non-zookeeper nifi nodes.
# scale is based on CPU load (see tf-nifi-scaling.tf)
minimum_node_count = 0
maximum_node_count = 3
