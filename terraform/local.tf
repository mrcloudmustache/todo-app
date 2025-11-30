locals {
  // Database credentials from AWS Secrets Manager
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["db_password"]
}