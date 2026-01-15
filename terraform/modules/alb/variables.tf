variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Public subnets for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

