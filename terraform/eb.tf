
resource "aws_elastic_beanstalk_application" "main" {
  name        = var.app_name
  description = var.app_description

}

resource "aws_elastic_beanstalk_application_version" "main" {
  name        = var.app_version
  application = aws_elastic_beanstalk_application.main.id
  description = var.app_version_description
  bucket      = aws_s3_bucket.source_bundle.id
  key         = aws_s3_object.source_bundle_zip.key

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elastic_beanstalk_environment" "main" {
  name                = var.app_name
  application         = aws_elastic_beanstalk_application.main.name
  solution_stack_name = var.solution_stack_name
  tier                = var.environment_tier

  version_label = aws_elastic_beanstalk_application_version.main.name

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = tostring(var.asg_min_size)
  }


  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = tostring(var.asg_max_size)
  }

  # Force Elastic Beanstalk to use an NLB instead of Classic LB
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "network"
  }

  # Listener on port from variable
  setting {
    namespace = "aws:elbv2:listener:${var.listener_port}"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:listener:${var.listener_port}"
    name      = "Protocol"
    value     = "TCP"
  }


  # Forward traffic to the default process
  setting {
    namespace = "aws:elbv2:listener:${var.listener_port}"
    name      = "DefaultProcess"
    value     = "default"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = var.listener_port
  }

  # (optional) set the instance protocol if needed
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "TCP"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.default.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = data.aws_subnets.default_vpc_subnets.ids[0]
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.eb_service_role.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST"
    value     = aws_db_instance.main.address
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PORT"
    value     = var.db_port
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USER"
    value     = var.db_username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASS"
    value     = local.db_password != "" ? local.db_password : var.db_password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_NAME"
    value     = var.db_name
  }
}