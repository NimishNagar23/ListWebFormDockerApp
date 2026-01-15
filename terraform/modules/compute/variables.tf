variable "project_name" {
  type = string
}

variable "subnet_id" {
  description = "Subnet ID to launch instance in"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile name"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH Key Name (Make sure this exists in AWS console)"
  type        = string
  default     = "" # Optional, leave blank if relying on Session Manager or no SSH needed immediately
}
