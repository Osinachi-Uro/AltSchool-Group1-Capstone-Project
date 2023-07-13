#variable "access_key" {}

#variable "secret_key" {}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr_block" {
  vpc_cidr_block = "10.0.0.0/16"
}

variable "private_subnet_cidr_blocks" {
  private_subnet_cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidr_blocks" {
  public_subnet_cidr_blocks = ["10.0.5.0/24", "10.0.6.0/24"]
}

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
