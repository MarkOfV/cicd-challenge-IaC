output "web_sg_id" {
  value = aws_security_group.web_sg.id
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "ecr_repo_url" {
  value = aws_ecr_repository.container_repo.repository_url
}