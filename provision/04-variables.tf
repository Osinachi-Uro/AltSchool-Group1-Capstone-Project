variable "access_key" {
  description = "The Access Key"
  default     = [{}]
}

variable "secret_key" {
  description = "The Secret Key"
  default     = [{}]
}

variable "region" {
  type    = string
  default = "eu-west-1"
}
