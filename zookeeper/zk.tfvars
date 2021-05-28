# Region to create/deploy resources
aws_region = "us-east-1"

# A label prefixed to various components' names
# A unique suffix is randomly generated
# e.g. 'zk1'
name_prefix = "zk1"

# The AWSCLI profile to use, generally default
aws_profile = "default"

# A non-root IAM user for managing/owning KMS keys
kms_manager = "some_user"

# networking
vpc_cidr = "10.10.20.0/24"
subnetA_cidr = "10.10.20.0/26"
subnetB_cidr = "10.10.20.64/26"
subnetC_cidr = "10.10.20.128/26"
subnetD_cidr = "10.10.20.192/26"

# service_port can be changed if something other than 2181 is desired
service_port = 2181
service_protocol = "TCP"

# the port zookeeper containers listen on
zk_port = 2181

# node(s)
service_count = 1
service_cpu = 256
service_memory = 512

# service clients - a list of subnets allowed to reach service port/protocol
client_cidrs = ["127.0.0.1/32","127.0.0.1/32"]
