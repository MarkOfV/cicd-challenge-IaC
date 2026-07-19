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

variable "task_desired_count" {
  description = "Number of running tasks"
  type        = number
  default     = 1
}