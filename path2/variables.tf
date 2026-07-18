variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "cicd-challenge"
}

variable "path" {
  description = "Path for resource names"
  type        = string
  default     = "path2"
}