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

resource "aws_codebuild_project" "codebuild" {
  name         = var.codebuild_name
  service_role = module.codebuild_role.iam_role_arn

  source {
    type            = "CODEPIPELINE"
    buildspec       = data.template_file.buildspec.rendered
    git_clone_depth = 0
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "public.ecr.aws/hashicorp/terraform:latest"
    privileged_mode = true
  }
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:*",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "iam:PassRole",
      "codestar-connections:UseConnection",
    ]
  }
}

module "codepipeline_role" {
  source     = "./modules/iam_role"
  name       = var.codepipeline_role_name
  identifier = "codepipeline.amazonaws.com"
  policy     = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_s3_bucket" "artifact" {
  bucket = var.artifact_bucket_name

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

resource "aws_codestarconnections_connection" "codestar" {
  name          = "github-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "codepipeline" {
  name     = var.codepipeline_name
  role_arn = module.codepipeline_role.iam_role_arn

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = 1
      output_artifacts = ["Source"]
      namespace        = "SourceVariables"

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.codestar.arn
        FullRepositoryId = "${var.repository_owner}/${var.repository_name}"
        BranchName       = "main"
        DetectChanges    = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.id
        "EnvironmentVariables" : "[{\"name\":\"Branch\",\"value\":\"#{SourceVariables.BranchName}\",\"type\":\"PLAINTEXT\"}]",
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.artifact.id
    type     = "S3"
  }
}

resource "random_id" "sample" {
  keepers = {
    codepipeline_name = aws_codepipeline.codepipeline.name
  }

  byte_length = 32
}

resource "aws_codepipeline_webhook" "terraform_plan" {
  name            = var.codepipeline_name
  target_pipeline = aws_codepipeline.codepipeline.name
  target_action   = "Source"
  authentication  = "GITHUB_HMAC"

  authentication_configuration {
    secret_token = random_id.sample.hex
  }

  filter {
    json_path    = var.webhook_jsonpath
    match_equals = var.webhook_match_equal
  }
}

resource "github_repository_webhook" "github_webhook" {
  repository = var.repository_name

  configuration {
    url          = aws_codepipeline_webhook.terraform_plan.url
    secret       = random_id.sample.hex
    content_type = "json"
    insecure_ssl = false
  }

  events = [var.github_event]
}
