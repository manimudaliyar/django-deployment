variable "environment" {
  description = "Environment in which the infra is provisioned for"
  type = string
}

variable "project-owner" {
  description = "Owner of this project"
  type = string
}

variable "github-repo" {
  description = "GitHub Reposiroty name"
  type = string
}