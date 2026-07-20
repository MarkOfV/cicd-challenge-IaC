resource "aws_codestarconnections_connection" "github_connection" {
  name = "cicd-challenge-github"
  provider_type = "GitHub"

  tags = {
    Path = var.path
  }
}