variable "cloudwatch_log_group" {
  type = string
}

variable "sns_email_list" {
  description = "List of emails to subscribe to the SNS topic"
  type        = list(string)
}

variable "cloudtrail_logs_bucket" {
  description = "bucket to write logs of cloudtrail"
  type        = string
}

variable "bucket_names_to_monitor" {
  type = list(string)
}
