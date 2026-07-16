data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "cicd-challenge-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Path = "path1"
  }  
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role   = aws_iam_role.ec2_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "ec2_s3_read_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.artifact_bucket.arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.artifact_bucket.arn]
  }
}

resource "aws_iam_role_policy" "ec2_s3_read_policy" {
  name   = "cicd-challenge-ec2-s3-read-policy"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.ec2_s3_read_policy.json
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "cicd-challenge-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
  
  tags = {
    Path = "path1"
  }
}


# CodeBuild IAM resource

data "aws_iam_policy_document" "codebuild_trust_policy"{
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "cicd-challenge-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_trust_policy.json
  tags = {
    Path = "path1"
  }  
}



data "aws_iam_policy_document" "codebuild_logs_policy" {
  
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
    ]
    resources = [
      aws_cloudwatch_log_group.codebuild_log_group.arn,
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.codebuild_log_group.arn}:*",
    ]
  }
  
}

resource "aws_iam_role_policy" "codebuild_logs_policy" {
  name   = "cicd-challenge-codebuild-logs-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_logs_policy.json
}


data "aws_iam_policy_document" "codebuild_s3_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
    ]
    resources = [
      aws_s3_bucket.artifact_bucket.arn,
    ]
  }
  statement {
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.artifact_bucket.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_s3_policy" {
  name   = "cicd-challenge-codebuild-s3-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_s3_policy.json
}


data "aws_iam_policy_document" "codebuild_ssm_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = [
      aws_instance.app.arn,
      "arn:aws:ssm:eu-west-1::document/AWS-RunShellScript"
      ]
  }

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetCommandInvocation"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_ssm_policy" {
  name   = "cicd-challenge-codebuild-ssm-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_ssm_policy.json
}


# CodePipeline

data "aws_iam_policy_document" "codepipeline_trust_policy"{
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "cicd-challenge-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_trust_policy.json
  tags = {
    Path = "path1"
  }  
}

data "aws_iam_policy_document" "codepipeline_s3_policy" {
  statement {
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.artifact_bucket.arn}/*"]
  }

   statement {
    effect    = "Allow"
    actions   = [
      "s3:GetBucketVersioning"
    ]
    resources = [aws_s3_bucket.artifact_bucket.arn]
  }
}

resource "aws_iam_role_policy" "codepipeline_s3_policy" {
  name   = "cicd-challenge-codepipeline-s3-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_s3_policy.json
}


data "aws_iam_policy_document" "codepipeline_codestar_policy" {
  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [
      aws_codestarconnections_connection.codestar_github_connection.arn
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline_codestar_policy" {
  name   = "cicd-challenge-codepipeline-codestar-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_codestar_policy.json
}



data "aws_iam_policy_document" "codepipeline_codebuild_policy" {
  statement {
    effect    = "Allow"
    actions   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
    resources = [
      aws_codebuild_project.codebuild_project.arn
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline_codebuild_policy" {
  name   = "cicd-challenge-codepipeline-codebuild-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_codebuild_policy.json
}

