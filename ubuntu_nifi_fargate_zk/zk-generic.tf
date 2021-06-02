variable "zk_version" {
  type    = string
  default = "latest"
}

variable "zk_cpu" {
  type = number
}

variable "zk_memory" {
  type = number
}

variable "enable_zk1" {
  type    = number
  default = 1
}

variable "enable_zk2" {
  type    = number
  default = 1
}

variable "enable_zk3" {
  type    = number
  default = 1
}
