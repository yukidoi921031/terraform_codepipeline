variable "name" {
  type        = string
  description = "The name of iam role."
}

variable "policy" {
  type        = string
  description = "The json of iam policy."
}

variable "identifier" {
  type        = string
  description = "The id of principal."
}
