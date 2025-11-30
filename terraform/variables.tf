variable "aws_region" {
  type = string
}

variable "db_name" {
  type        = string
  description = "Name of the database to create"
}

variable "db_username" {
  type        = string
  description = "Master DB username"
}

variable "db_password" {
  type        = string
  description = "Master DB password. If empty, Terraform will generate one."
  sensitive   = true
  default     = ""

}

variable "db_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret that contains the DB password"
  default     = ""

  validation {
    condition     = length(trimspace(var.db_secret_name)) > 0 || length(trimspace(var.db_password)) > 0
    error_message = "Either db_secret_name or db_password must be provided."
  }
}

variable "db_port" {
  type        = string
  default     = "5432"
  description = "Port on which the database listens"

}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class (choose free-tier eligible if available)"
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Storage in GB"
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "If true, DB will be publicly accessible (not recommended for production)"
}

variable "allowed_cidr" {
  type        = string
  default     = ""
  description = "Optional CIDR that can access the DB (e.g., your laptop IP/32). Leave empty to not add a CIDR rule."
}

variable "allowed_security_group_id" {
  type        = string
  default     = ""
  description = "Optional security group ID (e.g., Elastic Beanstalk EC2 SG). If set, the DB SG will allow inbound from this SG."
}

variable "engine_version" {
  type        = string
  default     = "15"
  description = "Postgres engine version (major). You can use e.g. '15' or '15.13'"
}

variable "app_name" {
  type        = string
  description = "Elastic Beanstalk application name"

}

variable "app_description" {
  type        = string
  description = "Description for the Elastic Beanstalk application"
  default     = "My application deployed with Terraform"
}

variable "app_version" {
  type        = string
  description = "Version of the Elastic Beanstalk application"
}

variable "app_version_description" {
  type        = string
  description = "Description for the Elastic Beanstalk application version"
  default     = "Application version created by Terraform"

}

variable "solution_stack_name" {
  type        = string
  description = "Elastic Beanstalk solution stack name"
  default     = "64bit Amazon Linux 2023 v4.5.0 running Go 1"
}

variable "environment_tier" {
  type        = string
  description = "Elastic Beanstalk environment tier"
  default     = "WebServer"
}

variable "listener_port" {
  type        = number
  description = "Port on which the application listens"
}

variable "asg_min_size" {
  type        = number
  description = "Minimum size of the Auto Scaling Group"
  default     = 1
}

variable "asg_max_size" {
  type        = number
  description = "Maximum size of the Auto Scaling Group"
  default     = 3
}

variable "environment" {
  type        = string
  description = "Name of the environment variable to set in the Elastic Beanstalk environment"
  default     = "dev"

// Validate environment name is dev or prod or stage
validation {
  condition = var.environment == "dev" || var.environment == "prod" || var.environment == "stage"
  error_message = "Environment name must be dev, prod, or stage."
}

}