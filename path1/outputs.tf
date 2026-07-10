output "ec2_instance_id" {
  value = aws_instance.app.id
}

output "ec2_public_ip" {
  value = aws_eip.app_eip.public_ip
}

output "ec2_iam_role_name" {
  value = aws_iam_role.ec2_role.name
}

output "artifacts_bucket_name" {
  value = aws_s3_bucket.artifact_bucket.bucket
}

output "artifacts_bucket_arn" {
  value = aws_s3_bucket.artifact_bucket.arn
}

output "codebuild_project_name" {
  value = aws_codebuild_project.codebuild_project.name
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}
output "codestar_connection_arn" {
  value = aws_codestarconnections_connection.codestar_github_connection.arn
}

output "codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}
