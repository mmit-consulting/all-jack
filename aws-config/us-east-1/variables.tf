variable "config_logs_bucket" {
  type = string
}

variable "notification_emails" {
  type = list(string)
}

variable "excluded_accounts" {
  type    = list(string)
  default = []
}
