provider "aws" {
  region = "ap-northeast-1"
}

data "aws_ssm_parameter" "github_token" {
  name = "GitHub_token_yukidoi921031"
}

provider "github" {
  token = data.aws_ssm_parameter.github_token.value
}

module "plan" {
  source = "../modules/codebuild"

  github_token           = data.aws_ssm_parameter.github_token.value
  codebuild_role_name    = "codebuild_role_plan"
  codebuild_name         = "codebuild_plan"
  buildspec_file_name    = "terraform-plan"
  repository_url         = "https://github.com/yukidoi921031/terraform_codepipeline.git"
  environment            = "dev"
  webhook_filter_pattern = "PULL_REQUEST_CREATED"
  tf_version             = "1.0.9"
}

module "apply" {
  source = "../modules/codebuild"

  github_token           = data.aws_ssm_parameter.github_token.value
  codebuild_role_name    = "codebuild_role_apply"
  codebuild_name         = "codebuild_apply"
  buildspec_file_name    = "terraform-apply"
  repository_url         = "https://github.com/yukidoi921031/terraform_codepipeline.git"
  environment            = "dev"
  webhook_filter_pattern = "PULL_REQUEST_MERGED"
  tf_version             = "1.0.9"
}