terraform {
  required_version = "1.0.7"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.17.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
    }
  }

  backend "s3" {
    bucket = "yukidoi921031-tfstate"
    key    = "test"
    region = "ap-northeast-1"
  }
}
