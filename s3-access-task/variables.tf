
variable "cloudtrail_logs_bucket" {
  type    = string
  default = "jack-infra-bucket"
}

variable "cloudwatch_log_group" {
  type    = string
  default = "/aws/cloudtrail/s3-security-monitoring"
}

variable "emails" {
  type    = list(string)
  default = ["mahdiibouaziz@gmail.com"]
}

variable "bucket_names" {
  type    = list(string)
  default = ["mahdi-test-object-jack2", "mahdi-test-jack-bucket"]
}
