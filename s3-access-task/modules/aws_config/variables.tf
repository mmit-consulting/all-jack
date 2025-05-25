variable "config_logs_bucket" {
  type        = string
  description = "bucket to write logs of config"
}

variable "bucket_names" {
  type = list(string)
}
