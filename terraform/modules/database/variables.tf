variable "project_name" {
  type = string
}

variable "vpc_security_group_ids" {
  description = "Security groups for the RDS instance"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnets for the RDS instance"
  type        = list(string)
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "userdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "user" # Matches your local docker-compose
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  default     = "password" # Matches your local docker-compose (Ideally pass this in via secret)
}
