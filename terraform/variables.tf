variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"

}

variable "app" {
  default = "cdc"
}

variable "public_subnets_cidr" {
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]

}

variable "private_subnets_cidr" {
  default = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
}

variable "instance-type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "cdc"
}