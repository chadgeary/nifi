# aws profile (e.g. from aws configure, usually "default")
aws_profile = "default"
aws_region  = "us-east-1"

# existing aws iam user granted access to the kms key (for browsing KMS encrypted services like S3 or SNS).
kms_manager = "some_iam_user"

# additional aws tags
aws_default_tags = {
  Environment = "Development"
}

# the secret for nifi private keys
nifi_secret = "changeme"

# the subnet(s) permitted to browse nifi (port 2170 or web_port) via the AWS NLB
mgmt_cidrs = ["127.0.0.0/32"]

# the subnet(s) permitted to send traffic to service ports
client_cidrs = []

# management port for HTTPS (and inter-cluster communication) via mgmt NLB
web_port = 2170

# service ports for traffic inbound via service NLB - e.g. [3334, 3335]
tcp_service_ports    = []
udp_service_ports    = []
tcpudp_service_ports = []

# public ssh key
instance_key = "ssh-rsa AAAAB3NzaD2yc2EAAAADAQABAAABAQCNsxnMWfrG3SoLr4uJMavf43YkM5wCbdO7X5uBvRU8oh1W+A/Nd/jie2tc3UpwDZwS3w6MAfnu8B1gE9lzcgTu1FFf0us5zIWYR/mSoOFKlTiaI7Uaqkc+YzmVw/fy1iFxDDeaZfoc0vuQvPr+LsxUL5UY4ko4tynCSp7zgVpot/OppqdHl5J+DYhNubm8ess6cugTustUZoDmJdo2ANQENeBUNkBPXUnMO1iulfNb6GnwWJ0Z5TRRLGSu2gya2wMLeo1rBJ5cbZZgVLMVHiKgwBy/svUQreR8R+fpVW+Q4rx6sPAltLaOUONn0SF2BvvJUueqxpAIaA2rU4MS420P"

# size according to workloads, must be x86 based with at least 2GB of RAM (which is barely enough).
instance_type = "r5.large"

# the root block size of the instances (in GiB)
instance_vol_size = 15

# zookeeper (fargate) CPU and RAM (MiB)
zk_cpu    = 256
zk_memory = 512

# node cluster size - on first run always start with one node and test web authentication. This allows cluster bootstrapping and prevents split-brain.
# scale is based on CPU load (see nifi-scaling-nodes.tf)
minimum_node_count = 1
maximum_node_count = 1

# enable (or disable) zookeepers in each AZ/Subnet 1 = enabled, 0 = disabled
enable_zk1 = 1
enable_zk2 = 1
enable_zk3 = 1

# the name prefix for various resources (e.g. "nifi" for "nifi-encrypted-ami", "nifi-zk1-", ...)
name_prefix = "nifi"

# the vendor supplying the AMI and the AMI name - default is official Ubuntu 20.04 x86_64
# official Ubuntu ARM instances/amis are supported
vendor_ami_account_number = "099720109477"
vendor_ami_name_string    = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210415"

# days to retain logs in cloudwatch
log_retention_days = 30

# health check frequency - if an instance fails a health check it is terminated and replaced
health_check_enable = true
health_check_unit   = "minutes"
health_check_count  = 10

# nifi/nifi-toolkit and zookeeper versions downloaded from urls below
nifi_version = "1.13.2"

# urls for a lambda function to fetch nifi and nifi toolkit and put to s3
nifi_url    = "https://apache.osuosl.org/nifi/1.13.2/nifi-1.13.2-bin.tar.gz"
toolkit_url = "https://apache.osuosl.org/nifi/1.13.2/nifi-toolkit-1.13.2-bin.tar.gz"

# zk version of docker container - https://hub.docker.com/_/zookeeper/?tab=tags&page=1&ordering=last_updated
zk_version = "latest"

# vpc specific vars, modify these values if there would be overlap with existing resources.
vpc_cidr     = "10.10.10.0/24"
pubnet1_cidr = "10.10.10.0/28"
pubnet2_cidr = "10.10.10.16/28"
pubnet3_cidr = "10.10.10.32/28"
prinet1_cidr = "10.10.10.64/26"
prinet2_cidr = "10.10.10.128/26"
prinet3_cidr = "10.10.10.192/26"
