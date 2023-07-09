variable "access_key" {}

variable "secret_key" {}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr_block" {}

variable "private_subnet_cidr_blocks" {}

variable "public_subnet_cidr_blocks" {}

# variable "kube_config" {
#   type    = string
#   default = "~/.kube/config"
# }

#variable "access_key" {}

#variable "secret_key" {}

#variable "region" {
#  type    = string
#  default = "eu-west-1"
#}
