data "aws_iam_policy" "codebuild" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

module "codebuild_role" {
  source     = "../iam_role"
  name       = var.codebuild_role_name
  identifier = "codebuild.amazonaws.com"
  policy     = data.aws_iam_policy.codebuild.policy
}

#data "template_file" "buildspec" {
#  template = file("${path.module}/${var.buildspec_file_name}.yml")
#
#  vars = {
#    env = var.environment
#  }
#}

resource "aws_codebuild_source_credential" "example" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}

resource "aws_codebuild_project" "codebuild" {
  name         = var.codebuild_name
  service_role = module.codebuild_role.iam_role_arn

  source {
    type      = "GITHUB"
    buildspec = file("${path.module}/${var.buildspec_file_name}.yml")
    location  = var.repository_url
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "hashicorp/terraform:${var.tf_version}"
    privileged_mode = true

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }
}

resource "aws_codebuild_webhook" "example" {
  count        = var.webhook_filter_pattern == null ? 0 : 1
  project_name = aws_codebuild_project.codebuild.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = var.webhook_filter_pattern
    }
  }
}
