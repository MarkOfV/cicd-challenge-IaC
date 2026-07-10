terraform {
  required_version = ">= 1.12.0"
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket       = "cicd-challenge-state"
    key          = "path1/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.region
}