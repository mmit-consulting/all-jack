variable "config_logs_bucket" {
  type = string
}

variable "notification_emails" {
  type        = list(string)
  description = "List of emails to subscribe to AWS Config rule compliance notifications"
}

variable "excluded_accounts" {
  type    = list(string)
  default = []
}
