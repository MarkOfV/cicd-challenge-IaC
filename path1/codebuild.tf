resource "aws_codebuild_project" "codebuild_project" {
  name          = "cicd-challenge-codebuild-project"
  description   = "CodeBuild project for the CI/CD challenge"
  build_timeout = 30

  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "ARTIFACT_BUCKET"
      value = aws_s3_bucket.artifact_bucket.bucket
    }

    environment_variable {
      name  = "EC2_INSTANCE_ID"
      value = aws_instance.app.id
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name         = aws_cloudwatch_log_group.codebuild_log_group.name
      status             = "ENABLED"
    }
  }

  tags = {
    Name = "cicd-challenge-codebuild-project"
    Path = "path1"
  }
}