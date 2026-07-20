# IAM

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.name_prefix}-codebuild-role-${var.path}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = {
    Path = var.path
  }
}

data "aws_iam_policy_document" "codebuild_permissions" {

  statement {
    sid       = "AllowEcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowImagePush"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = [aws_ecr_repository.container_repo.arn]
  }

  statement {
    sid    = "AllowBuildLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.codebuild_logs.arn}:*"]
  }

  statement {
    sid    = "AllowArtifactBucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.artifact_bucket.arn}/*"]
  }
}

resource "aws_iam_role_policy" "codebuild_permissions" {
  name   = "${var.name_prefix}-codebuild-permissions-${var.path}"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_permissions.json
}

# Log Group

resource "aws_cloudwatch_log_group" "codebuild_logs" {
  name              = "/aws/codebuild/${var.name_prefix}-codebuild-${var.path}"
  retention_in_days = 14

  tags = {
    Path = var.path
  }
}

# Codebuild project

resource "aws_codebuild_project" "codebuild" {
  name         = "${var.name_prefix}-codebuild-${var.path}"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-path2.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "ECR_REPO_URL"
      value = aws_ecr_repository.container_repo.repository_url
    }

    environment_variable {
      name  = "ECR_REGISTRY"
      value = split("/", aws_ecr_repository.container_repo.repository_url)[0]
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.region
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_logs.name
    }
  }

  tags = {
    Path = var.path
  }
}