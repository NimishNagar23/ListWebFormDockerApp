variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "backend_image_url" {
  type = string
}

variable "frontend_image_url" {
  type = string
}

variable "db_endpoint" {
  type = string
}

variable "db_username" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "alb_target_group_arn_backend" {
  type = string
}

variable "alb_target_group_arn_frontend" {
  type = string
}

variable "backend_security_group_id" {
  type = string
}
