resource "aws_codepipeline" "cicd_challenge_pipeline" {
  name     = "cicd-challenge-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn = aws_codestarconnections_connection.codestar_github_connection.arn
        FullRepositoryId = "MarkOfV/cicd-challenge-app" # Replace with your GitHub username and repository name
        BranchName       = "main" # Replace with your desired branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }
}