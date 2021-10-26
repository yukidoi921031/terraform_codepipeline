data "aws_ssm_parameter" "github_token" {
  name = var.github_token_ssm_key
}

data "aws_iam_policy" "codebuild" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

module "codebuild_role" {
  source     = "./modules/iam_role"
  name       = var.codebuild_role_name
  identifier = "codebuild.amazonaws.com"
  policy     = data.aws_iam_policy.codebuild.policy
}

data "template_file" "buildspec" {
  template = file("${path.module}/${var.buildspec_file_name}.yml")

  vars = {
    env = var.environment
  }
}

resource "aws_codebuild_source_credential" "example" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = data.aws_ssm_parameter.github_token.value
}

resource "aws_codebuild_project" "codebuild" {
  name         = var.codebuild_name
  service_role = module.codebuild_role.iam_role_arn

  source {
    type            = "GITHUB"
    buildspec       = data.template_file.buildspec.rendered
    location        = "https://github.com/yukidoi921031/terraform_codepipeline.git"
    git_clone_depth = 0
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "public.ecr.aws/hashicorp/terraform:latest"
    privileged_mode = true
  }
}

resource "aws_codebuild_webhook" "example" {
  project_name = aws_codebuild_project.codebuild.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "master"
    }
  }
}