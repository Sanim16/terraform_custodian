variable "name" {
  description = "The name of the resource"
  default     = "custodian-poc"
}

variable "vpc_name" {
  description = "The name of the vpc"
  default     = "custodian-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "cidr block for the vpc"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "cidr block for the subnet"
  default     = "10.0.1.0/24"
}

variable "region" {
  default = "us-east-1"
}

variable "kubernetes_version" {
  default = "1.33"
}
