module "plan" {
  source = "../"

  github_token_ssm_key   = "GitHub_token_yukidoi921031"
  codebuild_role_name    = "codebuild_role_plan"
  codebuild_name         = "codebuild_plan"
  buildspec_file_name    = "terraform-plan"
  repository_url         = "https://github.com/yukidoi921031/terraform_codepipeline.git"
  environment            = "dev"
  webhook_filter_pattern = "PULL_REQUEST_CREATED"
}

module "apply" {
  source = "../"

  github_token_ssm_key   = "GitHub_token_yukidoi921031"
  codebuild_role_name    = "codebuild_role_apply"
  codebuild_name         = "codebuild_apply"
  buildspec_file_name    = "terraform-apply"
  repository_url         = "https://github.com/yukidoi921031/terraform_codepipeline.git"
  environment            = "dev"
  webhook_filter_pattern = "PULL_REQUEST_MERGED"
}