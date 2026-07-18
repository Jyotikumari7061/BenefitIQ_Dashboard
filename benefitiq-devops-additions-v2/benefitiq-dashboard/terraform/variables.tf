variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short name used as a prefix for all resources"
  type        = string
  default     = "benefitiq"
}

variable "backend_image" {
  description = "Full image URI for the backend container (set after first ECR push)"
  type        = string
  default     = ""
}

variable "frontend_image" {
  description = "Full image URI for the frontend container (set after first ECR push)"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repo in owner/name form, used to scope the OIDC trust policy (e.g. Jyotikumari7061/benefitiq-dashboard)"
  type        = string
}
