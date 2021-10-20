terraform {
  required_version = ">= 1.0.7"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }

  backend "s3" {
#    bucket = var.remote_state_bucket
    bucket = "yukidoi921031-tfstate"
#    key    = var.remote_state_bucket_key
    key    = "test"
    region = "ap-northeast-1"
  }
}
