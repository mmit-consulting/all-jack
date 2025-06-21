# variable "vpc_id" {
#   type        = string
#   description = "Target VPC ID"
# }

# variable "subnet_ids" {
#   type        = list(string)
#   description = "Subnets ID for the SSM"
# }

# variable "region" {
#   type        = string
#   description = "region to work on"
# }

# variable "ec2_cidr" {
#   type        = string
#   description = "CIDR Block to open for EC2"
# }

variable "ssm" {
  type    = map(any)
  default = {}
}
