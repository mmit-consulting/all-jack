terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta2"
      configuration_aliases = [
        aws.us-east-1,
        aws.us-west-2
      ]
    }
  }
}
