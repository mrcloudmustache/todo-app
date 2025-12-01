output "application_url" {
  value = aws_elastic_beanstalk_environment.main.cname
}

output "environment_id" {
  value = aws_elastic_beanstalk_environment.main.id
}

output "environment_name" {
  value = aws_elastic_beanstalk_environment.main.name
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}