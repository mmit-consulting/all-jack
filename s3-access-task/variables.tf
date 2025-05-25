
variable "cloudtrail_logs_bucket" {
  type = string
}

variable "cloudwatch_log_group" {
  type = string
}

variable "emails" {
  type = list(string)
}

variable "bucket_names" {
  type = list(string)
}
