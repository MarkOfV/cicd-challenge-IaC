resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/cicd-challenge-build"
  retention_in_days = 14

  tags = {
    Path = "path1"
  }
}