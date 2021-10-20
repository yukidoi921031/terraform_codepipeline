provider "aws" {
  region = "ap-northeast-1"
}

provider "github" {
  token = data.aws_ssm_parameter.github_token.value
}
