variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/MarkOfV/cicd-challenge-app.git"
}
