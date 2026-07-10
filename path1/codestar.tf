resource "aws_codestarconnections_connection" "codestar_github_connection" {
  name = "cicd-challenge-github"
  provider_type = "GitHub"

  tags = {
    Path = "path1"
  }
}