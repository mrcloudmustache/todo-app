# Get the default VPC in the account
data "aws_vpc" "default" {
  default = true
}

# Get subnets in the default VPC to create RDS the subnet group
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get all availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

// Get the Elastic Beanstalk instances security group for RDS access
data "aws_security_groups" "eb_instance_sg" {
  filter {
    name   = "group-name"
    values = ["awseb-${aws_elastic_beanstalk_environment.main.id}-stack-AWSEBSecurityGroup*"]
  }
}

data "aws_iam_policy" "eb_web_tier" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy" "eb_worker_tier" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

data "aws_iam_policy" "eb_multi_container_docker" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

data "aws_iam_policy" "eb_enhanced_health" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

data "aws_iam_policy" "eb_managed_updates" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

// Get the DB password from Secrets Manager if a secret name is provided
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_secret_name
}