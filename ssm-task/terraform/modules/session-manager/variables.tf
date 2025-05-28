variable "vpc_id" {
  description = "VPC ID where endpoints will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for interface endpoints"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "ec2_cidr" {
  description = "CIDR block for EC2 access to endpoints"
  type        = string
}
