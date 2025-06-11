variable "aws_region" {
  description = "The AWS region to deploy into"
  type = string
  default = "us-east-1"
}

variable "key_name" {
  description = "Name of the existing AWS EC2 Key pair to use for SSH access"
  type = string
}

variable "vpc_id" {
    description = "The ID of the VPC where the instance will be deployed"
    type = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance into"
  type = string
}

variable "private_key_path" {
  description = "Path to your private key file"
  type = string
}
