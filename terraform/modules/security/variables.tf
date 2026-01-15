variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for IAM role"
  type        = string
}
