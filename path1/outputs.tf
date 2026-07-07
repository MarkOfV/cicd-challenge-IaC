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