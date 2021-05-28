provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_profile
}

variable "name_prefix" {
  type                     = string
}

variable "aws_profile" {
  type                     = string
}

variable "aws_region" {
  type                     = string
}

variable "kms_manager" {
  type                     = string
  description              = "An IAM user for management of KMS key"
}

data "aws_caller_identity" "zk-aws-account" {
}

# aws, gov, or cn
data "aws_partition" "zk-aws-partition" {
}

data "aws_iam_user" "zk-kmsmanager" {
  user_name                = var.kms_manager
}

data "aws_availability_zones" "zk-azs" {
  state                    = "available"
}

variable "aws_az" {
  type                     = number
  default                  = 0
}

variable "vpc_cidr" {
  type                     = string
}

variable "subnetA_cidr" {
  type                     = string
}

variable "subnetB_cidr" {
  type                     = string
}

variable "subnetC_cidr" {
  type                     = string
}

variable "subnetD_cidr" {
  type                     = string
}

resource "random_string" "zk-random" {
  length                  = 5
  upper                   = false
  special                 = false
}

variable "service_cpu" {
  type                    = number
}

variable "service_memory" {
  type                    = number
}

variable "service_port" {
  type                    = number
}

variable "zk_port" {
  type                    = number
  default                 = "2181"
}

variable "service_protocol" {
  type                    = string
}

variable "service_count" {
  type                    = number
}

variable "client_cidrs" {
  type                     = list
  description              = "List of subnets (in CIDR notation) granted load balancer port and protocol ingress"
  default                  = []
}
