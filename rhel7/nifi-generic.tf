variable "aws_region" {
  type                     = string
}

variable "aws_profile" {
  type                     = string
}

variable "vpc_cidr" {
  type                     = string
}

variable "pubnet1_cidr" {
  type                     = string
}

variable "prinet1_cidr" {
  type                     = string
}

variable "pubnet2_cidr" {
  type                     = string
}

variable "prinet2_cidr" {
  type                     = string
}

variable "pubnet3_cidr" {
  type                     = string
}

variable "prinet3_cidr" {
  type                     = string
}

variable "mgmt_cidrs" {
  type                     = list
  description              = "Management CIDRs allowed to reach web_port"
}

variable "client_cidrs" {
  type                     = list
  description              = "Client CIDRs allowed to reach service_port(s)"
}

variable "instance_type" {
  type                     = string
  description              = "The type of EC2 instance to deploy"
}

variable "instance_key" {
  type                     = string
  description              = "A public key for SSH access to instance(s)"
}

variable "instance_vol_size" {
  type                     = number
  description              = "The volume size of the instances' root block device"
}

variable "kms_manager" {
  type                     = string
  description              = "An IAM user for management of KMS key"
}

variable "nifi_version" {
  type                     = string
  description              = "The version of Apache NiFi, e.g. 1.11.4"
}

variable "zk_version" {
  type                     = string
  description              = "The version of Apache Zookeeper, e.g. 3.6.1"
}

variable "enable_zk1" {
  type                     = number
  description              = "Whether to enable zk1 (1) or not (0)"
}

variable "enable_zk2" {
  type                     = number
  description              = "Whether to enable zk2 (1) or not (0)"
}

variable "enable_zk3" {
  type                     = number
  description              = "Whether to enable zk3 (1) or not (0)"
}

variable "minimum_node_count" {
  type                     = number
  description              = "The minimum number of non-zookeeper NiFi nodes in the Autoscaling Group"
}

variable "maximum_node_count" {
  type                     = number
  description              = "The maximum number of non-zookeeper NiFi nodes in the Autoscaling Group"
}

variable "name_prefix" {
  type                     = string
  description              = "A friendly name prefix for the AMI and EC2 instances, e.g. 'tf-nifi' or 'dev'"
}

variable "vendor_ami_account_number" {
  type                     = string
  description              = "The account number of the vendor supplying the base AMI"
}

variable "vendor_ami_name_string" {
  type                     = string
  description              = "The search string for the name of the AMI from the AMI Vendor"
}

provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_profile
}

# region azs
data "aws_availability_zones" "tf-nifi-azs" {
  state                    = "available"
}

# account id
data "aws_caller_identity" "tf-nifi-aws-account" {
}

# kms cmk manager - granted read access to KMS CMKs
data "aws_iam_user" "tf-nifi-kmsmanager" {
  user_name               = var.kms_manager
}

# aws, gov, or cn
data "aws_partition" "tf-nifi-aws-partition" {
}

# random string as suffix
resource "random_string" "tf-nifi-random" {
  length                            = 5
  upper                             = false
  special                           = false
}

variable "zk_url" {
  type                   = string
}

variable "nifi_url" {
  type                   = string
}

variable "toolkit_url" {
  type                   = string
}

variable "tcp_service_ports" {
  type                   = list
  default                = []
}

variable "udp_service_ports" {
  type                   = list
  default                = []
}

variable "tcpudp_service_ports" {
  type                   = list
  default                = []
}

variable "web_port" {
  type                   = number
  default                = 2170
}

variable "log_retention_days" {
  type                   = number
  default                = 30
}

variable "health_check_unit" {
  type                   = string
  default                = "minutes"
}

variable "health_check_count" {
  type                   = string
  default                = "5"
}
