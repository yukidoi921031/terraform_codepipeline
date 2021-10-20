module "dev" {
  source = "../"

  github_token_ssm_key = "GitHub_token_yukidoi921031"
  codebuild_role_name = "codebuild_role"
  codebuild_name = "codebuild"
  buildspec_file_name = "terraform-plan.yml"
  terraform_image_tag = "light"
  codepipeline_role_name = "codepipeline_role"
  artifact_bucket_name = "yukidoi921031-artifact-test"
  codepipeline_name = "codepipeline"
  remote_state_bucket = "test"
  remote_state_bucket_key = "key"
  repository_name = "terraform_codepipeline"
  repository_owner = "yukidoi921031"
  github_event = "pull_request"
  webhook_jsonpath = "$.action"
  webhook_match_equal = "opened"
}