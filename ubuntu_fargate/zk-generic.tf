variable "zk_cpu" {
  type = number
}

variable "zk_memory" {
  type = number
}

variable "zk_portnifi" {
  type    = number
  default = 2181
}

variable "zkA_port2" {
  type    = number
  default = 2182
}

variable "zkA_port3" {
  type    = number
  default = 2183
}

variable "zkB_port2" {
  type    = number
  default = 2184
}

variable "zkB_port3" {
  type    = number
  default = 2185
}

variable "zkC_port2" {
  type    = number
  default = 2186
}

variable "zkC_port3" {
  type    = number
  default = 2187
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
