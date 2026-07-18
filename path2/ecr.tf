resource "aws_ecr_repository" "container_repo" {
  name                 = "${var.name_prefix}-container-repo-${var.path}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}


data "aws_ecr_lifecycle_policy_document" "container_repo_lifecycle_policy" {

  rule {
    priority = 1
    description = "Expire old images after more than 5 in repo"

    selection {
      tag_status = "any"
      count_type = "imageCountMoreThan"
      count_number = 5
    }

    action {
      type = "expire"
    }
  }
}
resource "aws_ecr_lifecycle_policy" "container_repo_lifecycle_policy" {
  repository = aws_ecr_repository.container_repo.name

  policy = data.aws_ecr_lifecycle_policy_document.container_repo_lifecycle_policy.json
}