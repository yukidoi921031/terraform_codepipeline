variable "github_token" {
  type        = string
  description = "The value of github token."
}

variable "codebuild_role_name" {
  type        = string
  description = "The name of codebuild's iam role."
}

variable "codebuild_name" {
  type        = string
  description = "The name of codebuild."
}

variable "buildspec_file_name" {
  type        = string
  description = "The name of buildspec file."

  validation {
    condition     = contains(["terraform-plan", "terraform-apply"], var.buildspec_file_name)
    error_message = "ERROR valid values: terraform-plan, terraform-apply."
  }
}

variable "repository_url" {
  type        = string
  description = "The url of GitHub repository."
}

variable "environment" {
  type        = string
  description = "The name of environment."

  validation {
    condition     = contains(["dev", "prd"], var.environment)
    error_message = "ERROR valid values: dev, prd."
  }
}

variable "webhook_filter_pattern" {
  type        = string
  description = "The event type of codebuild's webhook filter."
  default     = null
}

variable "tf_version" {
  type        = string
  description = "Terraform version of docker hub image."
}
