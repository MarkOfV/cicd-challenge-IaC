resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.name_prefix}-artifacts-${var.path}-vladan-m"
  force_destroy = true

  tags = {
    Path = var.path
  }
}

resource "aws_s3_bucket_public_access_block" "artifact_bucket" {
  bucket                  = aws_s3_bucket.artifact_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}