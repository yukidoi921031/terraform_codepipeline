module "plan" {
  source = "../"

  github_token_ssm_key   = "GitHub_token_yukidoi921031"
  codebuild_role_name    = "codebuild_role_plan"
  codebuild_name         = "codebuild_plan"
  buildspec_file_name    = "terraform-plan.yml"
  terraform_image_tag    = "light"
  codepipeline_role_name = "codepipeline_role_plan"
  artifact_bucket_name   = "yukidoi921031-artifact-test-plan"
  codepipeline_name      = "codepipeline_plan"
  repository_name        = "terraform_codepipeline"
  repository_owner       = "yukidoi921031"
  github_event           = "pull_request"
  webhook_jsonpath       = "$.action"
  webhook_match_equal    = "opened"
  environment            = "dev"
}

module "apply" {
  source = "../"

  github_token_ssm_key   = "GitHub_token_yukidoi921031"
  codebuild_role_name    = "codebuild_role_apply"
  codebuild_name         = "codebuild_apply"
  buildspec_file_name    = "terraform-apply.yml"
  terraform_image_tag    = "light"
  codepipeline_role_name = "codepipeline_role_apply"
  artifact_bucket_name   = "yukidoi921031-artifact-test-apply"
  codepipeline_name      = "codepipeline_apply"
  repository_name        = "terraform_codepipeline"
  repository_owner       = "yukidoi921031"
  github_event           = "pull_request"
  webhook_jsonpath       = "$.test"
  webhook_match_equal    = "test"
  environment            = "dev"
}