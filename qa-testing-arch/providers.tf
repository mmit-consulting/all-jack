terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "jack-infra"
    key    = "qa-mobile/terraform.tfstate"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = "eu-west-3"
}
