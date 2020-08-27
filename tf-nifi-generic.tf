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

variable "node1_ip" {
  type                     = string
  description              = "An ip from prinet1_cidr for the first nifi node, which runs zookeeper"
}

variable "node2_ip" {
  type                     = string
  description              = "An ip from prinet2_cidr for the second nifi node, which runs zookeeper"
}

variable "node3_ip" {
  type                     = string
  description              = "An ip from prinet3_cidr for the third nifi node, which runs zookeeper"
}

variable "encrypted_ami_ip" {
  type                     = string
  description              = "An ip from prinet1_cidr for the instance used to create an encrypted AMI with a custom KMS CMK"
}

variable "mgmt_cidr" {
  type                     = string
  description              = "Subnet CIDR allowed to access NiFi instance(s) via ELB, e.g. 172.16.10.0/30"
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

variable "bucket_name" {
  type                     = string
  description              = "A unique bucket name to store playbooks and output of SSM"
}

variable "mirror_host" {
  type                     = string
  description              = "Mirror host for NiFi and Zookeeper installation files, e.g. mirror.cogentco.com"
}

variable "nifi_version" {
  type                     = string
  description              = "The version of Apache NiFi, e.g. 1.11.4"
}

variable "zk_version" {
  type                     = string
  description              = "The version of Apache Zookeeper, e.g. 3.6.1"
}

variable "minimum_node_count" {
  type                     = number
  description              = "The minimum number of non-zookeeper NiFi nodes in the Autoscaling Group"
}

variable "maximum_node_count" {
  type                     = number
  description              = "The maximum number of non-zookeeper NiFi nodes in the Autoscaling Group"
}

variable "ec2_name_prefix" {
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
