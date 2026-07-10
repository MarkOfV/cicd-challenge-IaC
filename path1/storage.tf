resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "cicd-challenge-artifact-bucket-vladan-m"
  force_destroy = true
  tags = {
    Path = "path1"
  }
}

resource "aws_s3_bucket_versioning" "artifact_bucket" {
  bucket = aws_s3_bucket.artifact_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_encryption" {
  bucket = aws_s3_bucket.artifact_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}  

resource "aws_s3_bucket_public_access_block" "artifact_bucket_block_public_access" {
  bucket = aws_s3_bucket.artifact_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "artifact_bucket_lifecycle" {
  bucket = aws_s3_bucket.artifact_bucket.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    
    filter  {}
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    id     = "expire-codepipeline-artifacts"
    status = "Enabled"
    
    filter  {
      prefix = "cicd-challenge-pipel/" #Need to name it like this, since CodePipeline truncates the prefix to this name when it creates the artifacts in the S3 bucket.
    }
    
    expiration {
      days = 3
    }
  }
}